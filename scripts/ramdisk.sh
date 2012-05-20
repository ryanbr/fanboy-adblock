# Make Ramdisk

# Creating a 30Mb ramdisk Temp storage...
#
if [ ! -d "/tmp/ramdisk/" ]; then
    rm -rf /tmp/ramdisk/
    mkdir /tmp/ramdisk; chmod 777 /tmp/ramdisk
    mount -t tmpfs -o size=30M tmpfs /tmp/ramdisk/
    mkdir /tmp/ramdisk/opera/
    mkdir /tmp/ramdisk/opera/test
fi
if [ ! -d "/tmp/ramdisk/opera/" ]; then
    mkdir /tmp/ramdisk/opera/
    mkdir /tmp/ramdisk/opera/test
fi