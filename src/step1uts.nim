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

proc newHostName(): string =
  let suits = @["swords", "wands", "pentacles", "cups"]
  let minors = @["ace", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "page", "knight", "queen", "king"]
  let majors = @["fool", "magician", "high-priestess", "empress", "emperor",
                          "hierophant", "lovers", "chariot", "strength", "hermit",
                          "wheel", "justice", "hanged-man", "death", "temperance",
                          "devil", "tower", "star", "moon", "sun", "judgment", "world"]
  let suit = suits.rand()
  let minor = minors.rand()
  let major = majors.rand()

  echo "NEW HOSTNAME: " & fmt("{suit}_{major}_{minor}")
  return fmt("{suit}_{major}_{minor}")



when isMainModule:
  # STEP 1 normal fork/exec affects parent.
  # var pid = fork() 
  # if pid == 0:
  #   # child
  #   echo "CHILD: " & execCmdEx("hostname")[0]
  #   discard execCmd("hostname dmdm")
  #   echo "CHILD: " & execCmdEx("hostname")[0]
  # else:
  #   echo "PARENT: " & execCmdEx("hostname")[0]
  #   var exitcode: cint
  #   discard waitpid(pid, exitcode, WNOHANG )
  #   echo "PARENT AFTER CHILD DONE: " & execCmdEx("hostname")[0]


  # STEP 2 (change hostname without affecting parent.)
  # const stackSize = 65536
  # let stackEnd = cast[clong](alloc(stackSize))
  # let stack = cast[pointer](stackEnd + stackSize)
  # var cfg =  ChildConfig(argc:1, hostname:"dmdmhost", uid:0 )
  # let newnsFlags :cint =  CLONE_NEWUTS or SIGCHLD
  # var sockets : array[2, cint]
  # if (socketpair(1, SOCK_SEQPACKET, 0, sockets) < 0):
  #   echo("opening stream socket pair");
  #   quit(3)
  # discard fcntl(sockets[0], F_SETFD, FD_CLOEXEC)

  # proc childAction(cnf: ptr ChildConfig) :  cint  =  
  #   discard execCmd("hostname dmdmreally")
  #   echo "CHILD HOST NOW: " & execCmdEx("hostname")[0] 
  #   # execv(cstring("echo"), allocCStringArray(["hello", "world"]))
  #   let exe = findExe("touch")
  #   echo "EXE: ", exe
  #   var args = allocCStringArray(@[exe, "/tmp/childworked"])
  #   var env = allocCStringArray(@[""])
  #   discard execve(exe, args, env) 
  #   # discard write(sockets[0], cstring(msg), 1024)

  # let fn : pointer = childAction
  # echo cfg.hostname
  # var pid = clone(fn, stack, cint(newnsFlags), pointer(addr cfg), nil, nil, nil)
  # if pid > 0:
  #   var exitcode: cint
  #   discard waitpid(pid, exitcode, WNOHANG )
  #   echo "PARENT AFTER CHILD DONE: " & execCmdEx("hostname")[0]





  # STEP 3 (change hostname without affecting parent.) with NEWUSER and NEWNS
#   const stackSize = 65536
#   let stackEnd = cast[clong](alloc(stackSize))
#   let stack = cast[pointer](stackEnd + stackSize)
#   var cfg =  ChildConfig(argc:1, hostname:"dmdmhost", uid:0 )
#   let newnsFlags :cint =  CLONE_NEWNS or  CLONE_NEWCGROUP or CLONE_NEWPID or CLONE_NEWIPC or CLONE_NEWNET or CLONE_NEWUTS or CLONE_NEWUSER or SIGCHLD
#   var sockets : array[2, cint]
#   if (socketpair(1, SOCK_SEQPACKET, 0, sockets) < 0):
#     echo("opening stream socket pair");
#     quit(3)
#   discard fcntl(sockets[0], F_SETFD, FD_CLOEXEC)
#   cfg.fd = sockets[1]
  
#   let MS_PRIVATE = 1 shl 18
#   let MS_REC = 16384
#   let MS_BIND = 4096
#   let MNTFLAGS  = MS_PRIVATE or MS_REC

#   proc mount*(source, target, filesystemtype: cstring, mountflags: clong, data: pointer): cint {.importc, header: "<sys/mount.h>".}
#   proc mkdtemp*(temlatestring: cstring): ptr cstring {.importc, header: "<stdlib.h>".}
#   proc syscall*(fnid: clong, a, b: cstring): clong  {.importc, header:"<sys/syscall.h>".}
#   proc umount2*(target: cstring, mountflags: cint): cint {.importc, header: "<sys/mount.h>".}

#   proc pivot_root*(new_root, old_root: string) =
#     # 217 -> SYS_pivot_root
#     discard syscall(217, cstring(new_root), cstring(old_root))


#   proc mounts(cfg: ptr ChildConfig) = 
#     echo "CHILD PWD: " & execCmdEx("pwd")[0]
#     echo "LS PWD " & execCmdEx("ls")[0]
#     echo "whoami " & execCmdEx("whoami")[0]
#     echo "id " & execCmdEx("id")[0]
#     # echo "CHILD MOUNTS NOW: " & execCmdEx("mount")[0]


#     echo "=> remounting everything with MS_PRIVATE..."
#     discard mount(nil, "/", nil, MNTFLAGS, nil)
#     echo "remounted"
  
#     echo "=> making a temp directory and a bind mount there..."
#     let mountDir = getTempDir() / "rooty"
#     echo "MOUNTDIR: " & mountDir
#     createDir(mountDir)
#     discard mount(cstring(cfg.mountDir), cstring(mountDir), nil, MS_BIND or MS_PRIVATE, nil)
  
#     let inner_mount_dir = mountDir / "oldroot.XXXXXX"
#     echo "INNERT MOUNTDIR: " & inner_mount_dir
#     createDir(inner_mount_dir)

#     echo "done."
    
#     echo "=> pivoting root..."
#     pivot_root(mount_dir, inner_mount_dir)
#     echo "done."
    
#     let oldroot =  $basename(inner_mount_dir)
#     echo " OLD ROOT : " & oldroot
#     echo "=> unmounting %s...", oldroot

#     setCurrentDir("/")
#     # 2 MNT DETACH
#     discard umount2(oldroot, 2)
#     removeDir($oldroot)
#     echo "CHILD PWD: " & execCmdEx("pwd")[0]
#     # echo "CHILD MOUNTS NOW: " & execCmdEx("mount")[0]
#     echo "LS PWD" & execCmdEx("ls")[0]
#     echo "LS /home" & execCmdEx("ls /home")[0]
#     echo "whoami " & execCmdEx("whoami")[0]
#     echo "id " & execCmdEx("id")[0]

#     echo "done.\n"



#   proc childAction(cnf: ptr ChildConfig) :  cint  =  
#     discard execCmd("hostname "&newHostName())
#     echo "CHILD HOST NOW: " & execCmdEx("hostname")[0] 
#     # execv(cstring("echo"), allocCStringArray(["hello", "world"]))
#     discard execCmd("whoami ")
#     discard execCmd("id ")
#     mounts(cnf)



#   #   if (sethostname(config->hostname, strlen(config->hostname))
#   #   || mounts(config)
#   #   || userns(config)
#   #   || capabilities()
#   #   || syscalls()) {
#   # close(config->fd);
#   # return -1;
# # }
# # if (close(config->fd)) {
# #   fprintf(stderr, "close failed: %m\n");
# #   return -1;
# # }

#     let exe = findExe("touch")
#     echo "EXE: ", exe
#     var args = allocCStringArray(@[exe, "/tmp/childworked"])
#     var env = allocCStringArray(@[""])
#     discard execve(exe, args, env) 


#     # # discard write(sockets[0], cstring(msg), 1024)

#   let fn : pointer = childAction
#   echo cfg.hostname
#   var pid = clone(fn, stack, cint(newnsFlags), pointer(addr cfg), nil, nil, nil)
#   if pid > 0:
#     var exitcode: cint
#     discard waitpid(pid, exitcode, WNOHANG )
#     echo "PARENT AFTER CHILD DONE: " & execCmdEx("hostname")[0]




  # STEP 3 (change hostname without affecting parent.) with NEWUSER and NEWNS
  const stackSize = 65536
  let stackEnd = cast[clong](alloc(stackSize))
  let stack = cast[pointer](stackEnd + stackSize)
  var cfg =  ChildConfig(argc:1, hostname:"dmdmhost", uid:0, mountDir:"/home/striky/alpinerootfs")
  let newnsFlags :cint =  CLONE_NEWNS or  CLONE_NEWCGROUP or CLONE_NEWPID or CLONE_NEWIPC or CLONE_NEWNET or CLONE_NEWUTS or CLONE_NEWUSER or SIGCHLD
  var sockets : array[2, cint]

  discard socketpair(1, SOCK_SEQPACKET, 0, sockets)
  discard fcntl(sockets[0], F_SETFD, FD_CLOEXEC)
  cfg.fd = sockets[1]
  
  let MS_PRIVATE = 1 shl 18
  let MS_REC = 16384
  let MS_BIND = 4096
  let MNTFLAGS  = MS_PRIVATE or MS_REC

  proc mount*(source, target, filesystemtype: cstring, mountflags: clong, data: pointer): cint {.importc, header: "<sys/mount.h>".}
  proc mkdtemp*(temlatestring: cstring): ptr cstring {.importc, header: "<stdlib.h>".}
  proc syscall*(fnid: clong, a, b: cstring): clong  {.importc, header:"<sys/syscall.h>".}
  proc umount2*(target: cstring, mountflags: cint): cint {.importc, header: "<sys/mount.h>".}
  proc unshare*(flags: cint): cint {.importc, header: "<sched.h>".}
  proc setgroups*(size: cint, list: ptr cint): cint {.importc, header: "<unistd.h>".}
  proc setresuid*(ruid, euid, suid: cint): cint {.importc, header: "<unistd.h>".}
  proc setresgid*(rgid, egid, sgid: cint): cint {.importc, header: "<unistd.h>".}
  proc chroot*(path: cstring): cint {.importc, header: "<unistd.h>".}


  proc pivot_root*(new_root, old_root: string) =
    # 217 -> SYS_pivot_root
    discard syscall(217, cstring(new_root), cstring(old_root))


  proc mounts(cfg: ptr ChildConfig) = 
    echo "====MOUNTS===="
    echo "CHILD PWD: " & execCmdEx("pwd")[0]
    echo "LS /root: " & execCmdEx("ls /root -al")[0]
    echo "whoami " & execCmdEx("whoami")[0] & "id " & execCmdEx("id")[0]
    # echo "CHILD MOUNTS NOW: " & execCmdEx("mount")[0]


    # echo "=> remounting everything with MS_PRIVATE..."
    # discard mount(nil, "/", nil, MNTFLAGS, nil)
    # echo "remounted"
  
    # echo "=> making a temp directory and a bind mount there..."
    # let mountDir = getTempDir() / "rooty"
    # echo "MOUNTDIR: " & mountDir
    # createDir(mountDir)
    # discard mount(cstring(cfg.mountDir), cstring(mountDir), nil, MS_BIND or MS_PRIVATE, nil)
  
    # let inner_mount_dir = mountDir / "oldroot.XXXXXX"
    # echo "INNERT MOUNTDIR: " & inner_mount_dir
    # createDir(inner_mount_dir)
    # echo "done."
    
    # echo "=> pivoting root..."
    # pivot_root(mount_dir, inner_mount_dir)
    # echo "done."
  
    # let oldroot =  $basename(inner_mount_dir)
    # echo " OLD ROOT : " & oldroot
    # echo "=> unmounting %s...", oldroot

    discard chroot(cstring(cfg.mountDir))
    setCurrentDir("/")
    # 2 MNT DETACH
    # discard umount2(oldroot, 2)
    # removeDir($oldroot)
    echo "CHILD PWD: " & execCmdEx("pwd")[0]
    # echo "CHILD MOUNTS NOW: " & execCmdEx("mount")[0]
    echo "LS /root" & execCmdEx("ls /root -al" )[0]
    echo "whoami " & execCmdEx("whoami")[0] & "id " & execCmdEx("id")[0]

    echo "done.\n"

  proc userns(cnf: ptr ChildConfig) =
    echo  "====userns======"
    var has_userns = 0
    let resunshare = unshare(CLONE_NEWNS)
    if resunshare == 0:
      has_userns = 1
    discard posix.write(cint(cfg.fd), addr has_userns, sizeof(has_userns)) 

    var result = 0;
    discard read(cint(cfg.fd), addr result, sizeof(result))

    if has_userns == 1: 
      echo "done. userns"

    echo fmt("=> switching to uid {cnf.uid} / {cnf.uid} ...")

    var gidslist = cast[ptr cint]([cnf.uid])
    discard setgroups(1, gidslist )
    discard setresuid(cint(cnf.uid), cint(cnf.uid), cint(cnf.uid))
    discard setresgid(cint(cnf.uid), cint(cnf.uid), cint(cnf.uid))
    echo "done userns"


  proc childAction(cnf: ptr ChildConfig) :  cint  =  
    echo "CHILD started @ " & execCmdEx("hostname")[0] & " whoami " & execCmdEx("whoami")[0] & " id " & execCmdEx("id")[0] 
    echo "Changing hostname... "
    discard execCmd("hostname "&newHostName())
    echo "CHILD is now @ " & execCmdEx("hostname")[0] 

    mounts(cnf)
    userns(cnf)

    echo "After mounts and userns =>  whoami " & execCmdEx("whoami")[0] & " id " & execCmdEx("id")[0] 

    let exe = findExe("ls")
    echo "execve ls on /  ..."
    var args = allocCStringArray(@[exe, "/"])
    var env = allocCStringArray(@[""])

    discard execve(exe, args, env) 


  let USERNS_OFFSET = 10000
  let USERNS_COUNT = 2000

  proc prepare_child_uidmap(child_pid: Pid, fd: int) =
    var has_userns = -1
    
    discard read(cint(fd), addr has_userns, sizeof(has_userns))
    let files = @[fmt("/proc/{child_pid}/uid_map"), fmt("/proc/{child_pid}/gid_map")]

    for f in files:
      writeFile(f, fmt("0 {USERNS_OFFSET} {USERNS_COUNT}\n"))
    
    var data = cint(0)
    discard write(cint(fd), addr data, sizeof(data))

  let fn : pointer = childAction
  echo cfg.hostname
  cfg.mountDir = "/home/striky/alpinerootfs"
  var pid = clone(fn, stack, cint(newnsFlags), pointer(addr cfg), nil, nil, nil)
  if pid > 0:
    # handle child uidmap 
    prepare_child_uidmap(pid, sockets[0])
    var exitcode: cint
    discard waitpid(pid, exitcode, WNOHANG )
    echo "PARENT AFTER CHILD DONE: " & execCmdEx("hostname")[0]