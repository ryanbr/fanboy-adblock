# b.py - Distributed Bug Tracker Extention for Mercurial
#
# Copyright 2010-2011 Michael Diamond <michael@digitalgemstones.com>
#
# This software may be used and distributed according to the terms of the
# GNU General Public License version 2 or any later version.
# http://www.gnu.org/licenses/licenses.html
# http://www.gnu.org/licenses/gpl.html

""" A lightweight distributed bug tracker for Mercurial based projects

"The only way to make your bug list prettier is to fix some damn bugs."

b is a lightweight distributed bug tracker.  Stripped of many of the
enterprise level bloat features common in larger bug systems, b
lets you track issues, bugs, and features without being bogged down
in extra metadata that is ultimately completely unhelpful.

b has functionality to add, rename, list, resolve and reopen bugs
and keep everything as simple as a single line of text describing each one.

But if and when you need more than that, b scales cleanly to allow
you to add details that can't be properly contained in a concise title
such as stack traces, line numbers, and the like, and allows you to
add comments to bugs as time goes on.

b also works with teams, allowing you to assign bugs to different users
and keep track of bugs assigned to you.

However, b is a lightweight tool, and if there are additional features
you know you need but aren't described here, it may not be the tool for you.
See the README file for more details on what you can, and can't, do with b.
"""

#
# Imports
#
import os, errno, re, hashlib, sys, subprocess, tempfile, time
from operator import itemgetter
from datetime import datetime
from mercurial.i18n import _
from mercurial import hg,commands

#
# Version
#
version = _("b Version 0.6.1 - built 12-23-11")

#
# Static values / config settings
#
"""By default, IDs are made from title, time, and username when availible.
When true, only the title is used to make IDs."""
_simple_hash = False

#
# Exceptions
#
class InvalidDetailsFile(Exception):
    def __init__(self,prefix):
        """Raised when a bug's details file is invalid (is a dir)"""
        super(InvalidDetailsFile, self).__init__()
        self.prefix = prefix

class InvalidTaskfile(Exception):
    """Raised when the path to a task file already exists as a directory."""
    def __init__(self, reason=''):
        super(InvalidTaskfile, self).__init__()
        self.reason = reason

class AmbiguousPrefix(Exception):
    """Raised when trying to use a prefix that could identify multiple tasks."""
    def __init__(self, prefix):
        super(AmbiguousPrefix, self).__init__()
        self.prefix = prefix

class UnknownPrefix(Exception):
    """Raised when trying to use a prefix that does not match any tasks."""
    def __init__(self, prefix):
        super(UnknownPrefix, self).__init__()
        self.prefix = prefix

class AmbiguousUser(Exception):
    """Raised when trying to use a user prefix that could identify multiple users."""
    def __init__(self, user, matched):
        super(AmbiguousUser, self).__init__()
        self.user = user
        self.matched = matched

class UnknownUser(Exception):
    """Raised when trying to use a user prefix that does not match any users."""
    def __init__(self, user):
        super(UnknownUser, self).__init__()
        self.user = user

class InvalidInput(Exception):
    """Raised when the input to a command is somehow invalid - for example,
    a username with a | character will cause problems parsing the bugs file."""
    def __init__(self, reason):
        super(InvalidInput, self).__init__()
        self.reason = reason

class AmbiguousCommand(Exception):
    """Raised when trying to run a command by prefix that matches more than one command."""
    def __init__(self, cmd):
        super(AmbiguousCommand, self).__init__()
        self.cmd = cmd

class UnknownCommand(Exception):
    """Raised when trying to run an unknown command."""
    def __init__(self, cmd):
        super(UnknownCommand, self).__init__()
        self.cmd = cmd

class NonReadOnlyCommand(Exception):
    """Raised when user tries to run a destructive command against a read only issue db."""
    def __init__(self, cmd):
        super(NonReadOnlyCommand, self).__init__()
        self.cmd = cmd
#       
# Helper Methods - often straight from t
#
def _datetime(t = ''):
    """ Returns a formatted string of the time from a timestamp, or now if t is not set. """
    if t == '':
        t = datetime.now()
    else:
        t = datetime.fromtimestamp(float(t))
    return t.strftime("%A, %B %d %Y %I:%M%p")

def _hash(text):
    """Return a hash of the given text for use as an id.
    
    Currently SHA1 hashing is used.  It should be plenty for our purposes.
    
    """
    return hashlib.sha1(text.encode('utf-8')).hexdigest()

def _mkdir_p(path):
    """ race condition handling recursive mkdir -p call
    http://stackoverflow.com/questions/600268/mkdir-p-functionality-in-python
    """
    try:
        os.makedirs(path)
    except OSError, exc:
        if exc.errno == errno.EEXIST:
            pass
        else: raise

def _truth(str):
    """ Indicates the truth of a string """ 
    return str == 'True'

def _task_from_taskline(taskline):
    """Parse a taskline (from a task file) and return a task.
    
    A taskline should be in the format:
    
        summary text ... | meta1:meta1_value,meta2:meta2_value,...
    
    The task returned will be a dictionary such as:
    
        { 'id': <hash id>,
          'text': <summary text>,
           ... other metadata ... }
    
    A taskline can also consist of only summary text, in which case the id
    and other metadata will be generated when the line is read.  This is
    supported to enable editing of the taskfile with a simple text editor.
    """
    try:
        if '|' in taskline:
            text, meta = taskline.rsplit('|',1)
            task = { 'text': text.strip() }
            for piece in meta.strip().split(','):
                label, data = piece.split(':',1)
                task[label.strip()] = data.strip()
        else:
            text = taskline.strip()
            global _simple_hash
            task = { 'id': _hash(text) if _simple_hash else _hash(text+str(time.time())), 'text': text, 'owner': '', 'open': 'True', 'time': time.time() }
        return task
    except Exception:
        raise InvalidTaskfile(_("perhaps a missplaced '|'?\n"
                                "Line is: %s") % taskline)

def _tasklines_from_tasks(tasks):
    """Parse a list of tasks into tasklines suitable for writing to a file."""
    
    tasklines = []
    
    for task in tasks:
        meta = [m for m in task.items() if m[0] != 'text']
        meta_str = ', '.join('%s:%s' % m for m in meta)
        tasklines.append('%s | %s\n' % (task['text'].ljust(60), meta_str))
    
    return tasklines

def _prefixes(ids):
    """Return a mapping of ids to prefixes in O(n) time.
    
    This is much faster than the naitive t function, which
    takes O(n^2) time.
    
    Each prefix will be the shortest possible substring of the ID that
    can uniquely identify it among the given group of IDs.
    
    If an ID of one task is entirely a substring of another task's ID, the
    entire ID will be the prefix.
    """
    pre = {}
    for id in ids:
        id_len = len(id)
        for i in range(1, id_len+1):
            """ identifies an empty prefix slot, or a singular collision """
            prefix = id[:i]
            if (not prefix in pre) or (pre[prefix] != ':' and prefix != pre[prefix]):
                break
        if prefix in pre:
            """ if there is a collision """
            collide = pre[prefix]
            for j in range(i,id_len+1):
                if collide[:j] == id[:j]:
                    pre[id[:j]] = ':'
                else:
                    pre[collide[:j]] = collide
                    pre[id[:j]] = id
                    break
            else:
                pre[collide[:id_len+1]] = collide
                pre[id] = id
        else:
            """ no collision, can safely add """
            pre[prefix] = id
    pre = dict(zip(pre.values(),pre.keys()))
    if ':' in pre:
        del pre[':']
    return pre

def _describe_print(num,type,owner,filter):
    """ Helper function used by list to describe the data just displayed """
    typeName = 'open' if type else 'resolved'
    out = _("Found %s %s bug%s") % (num, typeName, '' if num==1 else 's')
    if owner != '*':
        out = out+(_(" owned by %s") % ('Nobody' if owner=='' else owner))
    if filter != '':
        out = out+_(" whose title contains %s") % filter
    return out

#
# Primary Class
#
class BugsDict(object):
    """A set of bugs, issues, and tasks, both finished and unfinished, for a given repository.
    
    The list's file is read from disk when initialized. The items
    can be written back out to disk with the write() function.
    
    You can specify any taskdir you want, but the intent is to work from the cwd
    and therefore anything calling this class ought to handle that change
    (normally to the repo root)
    """
    def __init__(self,bugsdir='.bugs',user='',fast_add=False):
        """Initialize by reading the task files, if they exist."""
        self.bugsdir = bugsdir
        self.user = user
        self.fast_add = fast_add
        self.file = 'bugs'
        self.detailsdir = 'details'
        self.last_added_id = None
        self.bugs = {}
        # this is the default contents of the bugs directory.  If you'd like, you can
        # modify this variable's contents.  Be sure to leave [comments] as the last field.
        # Remember that storing metadata like [reporter] in the details file is not secure.
        # it is recommended that you use Mercurial's excellent data-mining tools such as log
        # and annotate to get such information.
        self.init_details = '\n'.join([
        "# Lines starting with '#' and sections without content\n# are not displayed by a call to 'details'\n#",
        #"[reporter]\n# The user who created this file\n# This field can be edited, and is just a convenience\n%s\n" % self.user,
        "[Website]\n# If this applys to other websites, or other previous commits\n\n",
        "[filters]\n# Copy your Adblock filters here\n\n",
        "\n\n[other]\n# Any other details\n\n",
        #"[actual]\n# What happened instead\n\n",
        #"[stacktrace]\n# A stack trace or similar diagnostic info\n\n",
        #"[reproduce]\n# Reproduction steps\n\n",
        "[comments]\n# Leave your username"
        ])
        
        path = os.path.join(os.path.expanduser(self.bugsdir), self.file)
        if os.path.isdir(path):
            raise InvalidTaskfile(_("The path where the bugs database should be is blocked and cannot be created."))
        if os.path.exists(path):
            tfile = open(path, 'r')
            tlns = tfile.readlines()
            tls = [tl.strip() for tl in tlns if tl.strip()]
            tasks = map(_task_from_taskline, tls)
            for task in tasks:
                self.bugs[task['id']] = task
            tfile.close()
    
    def write(self):
        """Flush the finished and unfinished tasks to the files on disk."""
        _mkdir_p(self.bugsdir)
        path = os.path.join(os.path.expanduser(self.bugsdir), self.file)
        if os.path.isdir(path):
            raise InvalidTaskfile(_("The path where the bugs database should be is blocked and cannot be created."))
        tasks = sorted(self.bugs.values(), key=itemgetter('id'))
        tfile = open(path, 'w')
        for taskline in _tasklines_from_tasks(tasks):
            tfile.write(taskline)
        tfile.close()
    
    def __getitem__(self, prefix):
        """Return the task with the given prefix.
        
        If more than one task matches the prefix an AmbiguousPrefix exception
        will be raised, unless the prefix is the entire ID of one task.
        
        If no tasks match the prefix an UnknownPrefix exception will be raised.
        
        """
        matched = [item for item in self.bugs.keys() if item.startswith(prefix)]
        if len(matched) == 1:
            return self.bugs[matched[0]]
        elif len(matched) == 0:
            raise UnknownPrefix(prefix)
        else:
            matched = [item for item in self.bugs.keys() if item == prefix]
            if len(matched) == 1:
                return self.bugs[matched[0]]
            else:
                raise AmbiguousPrefix(prefix)
    
    def _get_details_path(self,full_id):
        """ Returns the directory and file path to the details specified by id """
        dirpath = os.path.join(self.bugsdir,self.detailsdir)
        path = os.path.join(dirpath,full_id+".txt")
        return (dirpath,path)
    
    def _make_details_file(self,full_id):
        """ Create a details file for the given id """
        (dirpath,path) = self._get_details_path(full_id)
        if not os.path.exists(dirpath):
            _mkdir_p(dirpath)
        if os.path.isdir(path):
            raise InvalidDetailsFile(full_id)
        if not os.path.exists(path):
            f = open(path, "w+")
            f.write(self.init_details)
            f.close()
        return path
    
    def _users_list(self):
        """ Returns a mapping of usernames to the number of open bugs assigned to that user """
        open = [item['owner'] for item in self.bugs.values() if _truth(item['open'])]
        closed = [item['owner'] for item in self.bugs.values() if not _truth(item['open'])]
        users = {}
        for user in open:
            if user in users:
                users[user] += 1
            else:
                users[user] = 1
        for user in closed:
            if not user in users:
                users[user] = 0
        
        if '' in users:
            users['Nobody'] = users['']
            del users['']
        return users
    
    def _get_user(self,user,force=False):
        """ Given a user prefix, returns the appropriate username, or fails if
        the correct user cannot be identified.
        
        'me' is a special username which maps to the username specified when
        constructing the BugsDict.
        'Nobody' (and prefixes of 'Nobody') is a special username which maps
        internally to the empty string, indicating no assignment.
        If force is true, the user 'Nobody' is used.  This is unadvisable,
        avoid forcing the username 'Nobody'.
        
        If force is true, it assumes user is not a prefix and should be
        assumed to exist already.
        """
        if user == 'me':
            return self.user
        if user == 'Nobody':
            return ''
        users = self._users_list().keys()
        if not force:
            if not user in users:
                usr = user.lower()
                matched = [u for u in users if u.lower().startswith(usr)]
                if len(matched) > 1:
                    raise AmbiguousUser(user,matched)
                if len(matched) == 0:
                    raise UnknownUser(user)
                user = matched[0]
            if user == 'Nobody': # needed twice, since users can also type a prefix to get it
                return ''
        else: # we're forcing a new username
            if '|' in user:
                raise InvalidInput(_("Usernames cannot contain '|'."))
        return user
            
    
    def id(self, prefix):
        """ Given a prefix, returns the full id of that bug """
        return self[prefix]['id']
    
    def add(self, text):
        """Adds a bug with no owner to the task list"""
        global _simple_hash
        task_id = _hash(text) if _simple_hash else _hash(text+self.user+str(time.time()))
        self.bugs[task_id] = {'id': task_id, 'open': 'True', 'owner': self.user, 'text': text, 'time': time.time()}
        self.last_added_id = task_id
        if not self.fast_add:
            prefix = _prefixes(self.bugs.keys())[task_id]
            prefix = "%s:%s" % (prefix, task_id[len(prefix):10])
        else:
            prefix = "%s..." % task_id[:10]
        return _("Added bug %s") % prefix
    
    def rename(self, prefix, text):
        """Renames the bug
        
        If more than one task matches the prefix an AmbiguousPrefix exception
        will be raised, unless the prefix is the entire ID of one task.
        
        If no tasks match the prefix an UnknownPrefix exception will be raised.
        
        """
        task = self[prefix]
        if text.startswith('s/') or text.startswith('/'):
            text = re.sub('^s?/', '', text).rstrip('/')
            find, _, repl = text.partition('/')
            text = re.sub(find, repl, task['text'])
        
        task['text'] = text
    
    def users(self):
        """ Prints a list of users along with the number of open bugs they have """
        users = self._users_list()
        if len(users) > 0:
            ulen = max([len(user) for user in users.keys()])+1
        else:
            ulen = 0
        out = _("Username: Open Bugs\n")
        for (user,count) in users.items():
            out += _("%s: %s\n") % (user,str(count).rjust(ulen-len(user)))
        return out
                
    def assign(self, prefix, user,force=False):
        """Specifies a new owner of the bug.  Tries to guess the correct user,
		or warns if it cannot find an appropriate user.
        
        Using the -f flag will create a new user with that exact name,
		it will not try to guess, or warn the user."""
        task = self[prefix]
        user = self._get_user(user,force)
        task['owner'] = user
        if user == '':
            user = 'Nobody'
        return _("Assigned %s: '%s' to %s" % (prefix, task['text'], user))
    
    def details(self, prefix):
        """ Provides additional details on the requested bug.
        
        Metadata (like owner, and creation time) which are
        not stored in the details file are displayed along with
        the details.
        
        Sections (denoted by a [text] line) with no content
        are not displayed.
        """
        task = self[prefix] # confirms prefix does exist
        path = self._get_details_path(task['id'])[1]
        if os.path.exists(path):
            if os.path.isdir(path):
                raise InvalidDetailsFile(prefix)
            
            f = open(path)
            text = f.read()
            f.close()
            
            text = re.sub("(?m)^#.*\n?", "", text)
            
            while True:
                oldtext = text
                retext = re.sub("\[\w+\]\s+\[", "[", text)
                text = retext
                if oldtext == retext:
                    break
            
            text = re.sub("\[\w+\]\s*$", "", text)
        else:
            text = _('No Details File Found.')
        
        header = _("Title: %s\nID: %s\n") % (task['text'],task['id'])
        if not _truth(task['open']):
            header = header + _("*Resolved* ")
        if task['owner'] != '':
            header = header + (_("Owned By: %s\n") % task['owner'])
        header = header + (_("Filed On: %s\n\n") % _datetime(task['time']))
        text = header + text
        
        return text.strip()
    
    def edit(self, prefix, editor='notepad'):
        """Allows the user to edit the details of the specified bug"""
        task = self[prefix] # confirms prefix does exist
        path = self._get_details_path(task['id'])[1]
        if not os.path.exists(path):
            self._make_details_file(task['id'])
        subprocess.call(editor.split() + [path])
        #subprocess.call()
        #print _timestamp()
    
    def comment(self, prefix, comment):
        """Allows the user to add a comment to the bug without launching an editor.
        
        If they have a username set, the comment will show who made it."""
        task = self[prefix] # confirms prefix does exist
        path = self._get_details_path(task['id'])[1]
        if not os.path.exists(path):
            self._make_details_file(task['id'])
        
        comment = _("On: %s\n%s") % (_datetime(),comment)
        
        if self.user != '':
            comment = _("By: %s\n%s") % (self.user,comment)
            
        f = open(path, "a")
        f.write("\n\n"+comment)
        f.close()
    
    def resolve(self, prefix):
        """Marks a bug as resolved"""
        task = self[prefix]
        task['open'] = 'False'
    
    def reopen(self, prefix):
        """Reopens a bug that was previously resolved"""
        task = self[prefix]
        task['open'] = 'True'
    
    def list(self,open=True,owner='*',grep='',alpha=False,chrono=False,truncate=0):
        """Lists all bugs, applying the given filters"""
        tasks = dict(self.bugs.items())
        
        prefixes = _prefixes(tasks).items()
        for task_id, prefix in prefixes:
            tasks[task_id]['prefix'] = prefix
        
        if owner != '*':
            owner = self._get_user(owner)
        
        small = [task for task in tasks.values() if _truth(task['open']) == open and 
                                                     (owner == '*' or owner == task['owner']) and 
                                                     (grep == '' or grep.lower() in task['text'].lower())]
        if len(small) > 0:
            plen = max([len(task['prefix']) for task in small])
        else:
            plen = 0
        out = ''
        if alpha:
            small = sorted(small, key=lambda x: x['text'].lower())
        if chrono:
            small = sorted(small, key=itemgetter('time'))
        for task in small:
            line = _('%s - %s') % (task['prefix'].ljust(plen),task['text'])
            if truncate > 0 and len(line) > truncate:
                line = line[:truncate-4]+'...'
            out += line+'\n'
        return out + _describe_print(len(small),open,owner,grep)
    
#
# Mercurial Extention Operations
# These are used to allow the tool to work as a Hg Extention
#
def _track(ui,repo,dir):
    """ Adds new files to Mercurial. """
    if os.path.exists(dir):
        ui.pushbuffer()
        commands.add(ui,repo,dir)
        ui.popbuffer()

def _cat(ui,repo,file,todir,rev=None):
    ui.pushbuffer()
    commands.cat(ui,repo,file,rev=rev,output=os.path.join(todir,file))
    ui.popbuffer()

#
# Command line processing
#
def cmd(ui,repo,cmd = 'list',*args,**opts):
    """ Distributed Bug Tracker For Mercurial
    
    List of Commands::
    
    add text [-e]
        Adds a new open bug to the database, if user is set in the config files, assigns it to user
        
        -e here and elsewhere launches the details editor for the issue upon successful execution of the command
        
    rename prefix text [-e]
        Renames The bug denoted by prefix to text.   You can use sed-style substitution strings if so desired.
        
    users [--rev rev]
        Displays a list of all users, and the number of open bugs assigned to each of them
        
    assign prefix username [-f] [-e]
        Assigns bug denoted by prefix to username.  Username can be a lowercase prefix of
        another username and it will be mapped to that username.  To avoid this functionality
        and assign the bug to the exact username specified, or if the user does not already
        exist in the bugs system, use the -f flag to force the name.
        
        Use 'me' to assign the bug to the current user,
        and 'Nobody' to remove its assignment.
        
    details [--rev rev] prefix [-e]
        Prints the extended details of the specified bug
        
    edit prefix
        Launches your specified editor to provide additional details 
        
    comment prefix comment [-e]
        Appends comment to the details of the bug, along with the date
        and, if specified, your username without needing to launch an editor
        
    resolve prefix [-e]
        Marks the specified bug as resolved
        
    reopen prefix [-e]
        Marks the specified bug as open
        
    list [--rev rev] [-r] [-o owner] [-g search] [-a|-c]
        Lists all bugs, with the following filters:
        
            -r list resolved bugs.
        
            -o list bugs assigned to owner.  '*' will list all bugs, 'me' will list all bugs assigned to the current user, and 'Nobody' will list all unassigned bugs.
        
            -g filter by the search string appearing in the title
            
            -a list bugs alphabetically
            
            -c list bugs chronologically
        
    id [--rev rev] prefix [-e]
        Takes a prefix and returns the full id of that bug
    
    version
        Outputs the version number of b being used in this repository
    """
    text = (' '.join(args)).strip();
    id = ''
    subtext = ''
    if len(args) > 0:
        id = args[0]
    if len(args) > 1:
        subtext = (' '.join(args[1:])).strip()
    
    try:
        bugsdir = ui.config("bugs","dir",".bugs")
        user = ui.config("bugs","user",'')
        fast_add = ui.configbool("bugs","fast_add",False)
        if user == 'hg.user':
            user = ui.username()
        path = repo.root
        os.chdir(path)

        # handle other revisions
        ## The methodology here is to use or create a directory
        ## in the user's /tmp directory for the given revision
        ## and store whatever files are being accessed there,
        ## then simply set path to the temporary repodir
        if opts['rev']:
            # TODO error on non-readonly command
            rev = str(repo[opts['rev']])
            tempdir = tempfile.gettempdir()
            revpath = os.path.join(tempdir,'b-'+rev)
            _mkdir_p(os.path.join(revpath,bugsdir))
            if not os.path.exists(os.path.join(revpath,bugsdir,'bugs')):
                _cat(ui,repo,os.path.join(bugsdir,'bugs'),revpath,rev)
            os.chdir(revpath)

        bd = BugsDict(bugsdir,user,fast_add)
        
        if opts['rev'] and 'details'.startswith(cmd):
            # if it's a details command, try to get the details file
            # if the lookup fails, we don't need to worry about it, the
            # standard error handling will catch it and warn the user
            fullid = bd.id(id)
            detfile = os.path.join(bugsdir,'details',fullid+'.txt')
            if not os.path.exists(os.path.join(revpath,detfile)):
                _mkdir_p(os.path.join(revpath,bugsdir,'details'))
                os.chdir(path)
                _cat(ui,repo,detfile,revpath,rev)
                os.chdir(revpath)
        
        def _add():
            ui.write(bd.add(text) + '\n')
            bd.write()

        def _rename():
            bd.rename(id, subtext)
            bd.write()

        def _users():
            ui.write(bd.users() + '\n')

        def _assign():
            ui.write(bd.assign(id, subtext, opts['force']) + '\n')
            bd.write()

        def _details():
            ui.write(bd.details(id) + '\n')

        def _edit():
            bd.edit(id, ui.geteditor())

        def _comment():
            bd.comment(id, subtext)

        def _resolve():
            bd.resolve(id)
            bd.write()

        def _reopen():
            bd.reopen(id)
            bd.write()

        def _list():
            ui.write(bd.list(not opts['resolved'], opts['owner'], opts['grep'],
                             opts['alpha'], opts['chrono'], ui.termwidth() if opts['truncate'] else 0) + '\n')

        def _id():
            ui.write(bd.id(id) + '\n')
            
        def _help():
            commands.help_(ui,'b')

        def _version():
            ui.write(version + '\n')

        readonly_cmds = set(['users','details','list','id'])
        cmds = {
                'add': _add,
                'rename': _rename,
                'users': _users,
                'assign': _assign,
                'details': _details,
                'edit': _edit,
                'comment': _comment,
                'resolve': _resolve,
                'reopen': _reopen,
                'list': _list,
                'id': _id,
                'help': _help,
                'version': _version,
               }

        candidates = [c for c in cmds if c.startswith(cmd)]
        real_candidate = [c for c in candidates if c == cmd]
        if real_candidate:
            pass # already valid command
        elif len(candidates) > 1:
            raise AmbiguousCommand(candidates)
        elif len(candidates) == 1:
            cmd = candidates[0]
        else:
            raise UnknownCommand(cmd)
        
        # ensure only read only commands can handle revision selection
        if opts['rev'] and cmd not in readonly_cmds:
            raise NonReadOnlyCommand(cmd)
        cmds[cmd]()
        
        # launch the editor - will fail on commands that don't have an issue prefix
        if cmd != 'edit' and opts['edit']:
            if opts['rev']:
                raise NonReadOnlyCommand('edit')
            if cmd == 'add':
                id = bd.last_added_id
            cmds['edit']()
            
        # Add all new files to Mercurial - does not commit
        if not opts['rev']:
            _track(ui,repo,bugsdir)
    
    except InvalidDetailsFile, e:
        ui.warn(_("The path where %s's details should be is blocked and cannot be created.  Are there directories in the details dir?\n"))
    except InvalidTaskfile, e:
        ui.warn(_("Invalid bugs database: %s\n") % e.reason)
    except InvalidInput, e:
        ui.warn(_("Invalid input: %s\n") % e.reason)
    except AmbiguousPrefix, e:
        if (id == ''):
            ui.warn(_("You need to provide an issue prefix.  Run list to get a unique prefix for the bug you are looking for.\n"))
        else:
            ui.warn(_("The provided prefix - %s - is ambiguous, and could point to multiple bugs.  Run list to get a unique prefix for the bug you are looking for.\n") % e.prefix)
    except UnknownPrefix, e:
        if (id == ''):
            ui.warn(_("You need to provide an issue prefix.  Run list to get a unique prefix for the bug you are looking for.\n"))
        else:
            ui.warn(_("The provided prefix - %s - could not be found in the bugs database.\n") % e.prefix)
    except AmbiguousUser, e:
        ui.warn(_("The provided user - %s - matched more than one user: %s\n") % (e.user, e.matched))
    except UnknownUser, e:
        ui.warn(_("The provided user - %s - did not match any users in the system.  Use -f to force the creation of a new user.\n") % e.user)
    except UnknownCommand, e:
        ui.warn(_("No such command '%s'\n") % e.cmd)
    except AmbiguousCommand, e:
        ui.warn(_("Command ambiguous between: %s\n") % (', '.join(e.cmd)))
    except NonReadOnlyCommand, e:
        ui.warn(_("'%s' is not a read-only command - cannot run against a past revision\n") % e.cmd)

    #open=True,owner='*',grep='',verbose=False,quiet=False):
cmdtable = {"b|bug|bugs": (cmd,[
                                ('f', 'force', False, _('Force this exact username')),
                                ('e', 'edit', False, _('Launch details editor after running command')),
                                ('r', 'resolved', False, _('List resolved bugs')),
                                ('o', 'owner', '*', _('Specify an owner to list by')),
                                ('g', 'grep', '', _('Filter titles by STRING')),
                                ('a', 'alpha', False, _('Sort list alphabetically')),
                                ('c', 'chrono', False, _('Sort list chronologically')),
                                ('T', 'truncate', False, _('Truncate list output to fit window')),
                                ('', 'rev', '', _('Run a read-only command against a different revision'))
                           ]
                           ,_("cmd [args]"))}
