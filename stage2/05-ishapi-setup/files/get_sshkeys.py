#!/usr/bin/python

import sys
import urllib2

try:
    req = urllib2.urlopen("http://localhost:8080/getkey?key=ssh_key")
    print req.read()
except Exception:
    print ""

