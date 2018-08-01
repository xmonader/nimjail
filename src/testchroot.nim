import os, osproc, posix, linux,  strformat, strutils, strformat, parseopt2, ospaths

import random


randomize()
# let newnsFlags =  CLONE_NEWUTS # or CLONE_NEWUSER or CLONE_NEWPID or CLONE_NEWNET or CLONE_NEWUTS or CLONE_NEWNS or CLONE_NEWCGROUP or CLONE_NEWIPC


type ChildConfig = object 
  argc*: int
  uid* : int
  fd* : int
  hostname*: string
  argv*: seq[string]
  mountDir*: string

proc chroot*(path: cstring): cint {.importc, header: "<unistd.h>".}
proc perror*(msg: cstring)  {.importc, header: "<unistd.h>".}

when isMainModule:
  var cfg =  ChildConfig(argc:1, hostname:"dmdmhost", uid:0, mountDir:"/home/striky/alpinerootfs")
  echo "********MOUNTDIR: " & cfg.mountDir

  discard chroot(cstring(cfg.mountDir))
  perror(cstring("CHROOT ::"))

  echo execCmdEx("/bin/ls /")[0]
  