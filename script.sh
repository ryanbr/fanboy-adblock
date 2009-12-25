#!/bin/bash
hg add .
hg commit -m "$1"
hg push
