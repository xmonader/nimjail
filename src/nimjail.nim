import os, osproc, posix, linux,  strformat, strutils, strformat, parseopt2, ospaths, strtabs

import random


randomize()
# let newnsFlags =  CLONE_NEWUTS # or CLONE_NEWUSER or CLONE_NEWPID or CLONE_NEWNET or CLONE_NEWUTS or CLONE_NEWNS or CLONE_NEWCGROUP or CLONE_NEWIPC


type ChildConfig = object 
  argc*: int
  uid* : int
  fd* : int
  hostname*: string
  argv*: seq[string]
  env*: StringTableRef
  cmd* : string
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

  return fmt("{suit}_{major}_{minor}")

let MS_PRIVATE = 1 shl 18
let MS_REC = 16384
let MS_BIND = 4096
let MNTFLAGS  = MS_PRIVATE or MS_REC
let newnsFlags :cint =  CLONE_NEWNS or  CLONE_NEWCGROUP or CLONE_NEWPID or CLONE_NEWIPC or CLONE_NEWNET or CLONE_NEWUTS or CLONE_NEWUSER or SIGCHLD
const stackSize = 65536

proc mount*(source, target, filesystemtype: cstring, mountflags: clong, data: pointer): cint {.importc, header: "<sys/mount.h>".}
proc mkdtemp*(temlatestring: cstring): ptr cstring {.importc, header: "<stdlib.h>".}
proc syscall*(fnid: clong, a, b: cstring): clong  {.importc, header:"<sys/syscall.h>".}
proc umount2*(target: cstring, mountflags: cint): cint {.importc, header: "<sys/mount.h>".}
proc unshare*(flags: cint): cint {.importc, header: "<sched.h>".}
proc setgroups*(size: cint, list: ptr cint): cint {.importc, header: "<unistd.h>".}
proc setresuid*(ruid, euid, suid: cint): cint {.importc, header: "<unistd.h>".}
proc setresgid*(rgid, egid, sgid: cint): cint {.importc, header: "<unistd.h>".}
proc chroot*(path: cstring): cint {.importc, header: "<unistd.h>".}
proc perror*(msg: cstring)  {.importc, header: "<unistd.h>".}
proc gethostname(name: cstring, namelen: cint):int {.importc, header:"<unistd.h>".}
proc sethostname(name: cstring, namelen: cint):int {.importc, header:"<unistd.h>".}


proc pivot_root*(new_root, old_root: string) =
  # 217 -> SYS_pivot_root
  discard syscall(217, cstring(new_root), cstring(old_root))


proc mounts(cfg: ptr ChildConfig) = 
  # echo "CHILD PWD: " & execCmdEx("pwd")[0]
  # echo "LS /root: " & execCmdEx("ls /root -al")[0]
  # echo "whoami " & execCmdEx("whoami")[0] & "id " & execCmdEx("id")[0]
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
  
  #   echo "********MOUNTDIR: " & cfg.mountDir
  discard chroot(cstring(cfg.mountDir))
  perror("CHROOT")
  setCurrentDir("/")
  # 2 MNT DETACH
  # discard umount2(oldroot, 2)
  # removeDir($oldroot)
  # echo "CHILD PWD: " & execCmdEx("pwd")[0]
  # # echo "CHILD MOUNTS NOW: " & execCmdEx("mount")[0]
  # echo "LS /root" & execCmdEx("ls root -al" )[0]
  # echo "whoami " & execCmdEx("whoami")[0] & "id " & execCmdEx("id")[0]


proc userns(cfg: ptr ChildConfig) =
  var has_userns = 0
  let resunshare = unshare(CLONE_NEWUSER or CLONE_NEWNS)
  if resunshare == 0:
    has_userns = 1
  discard posix.write(cint(cfg.fd), addr has_userns, sizeof(has_userns)) 

  var result = 0;
  discard posix.read(cint(cfg.fd), addr result, sizeof(result))

  echo fmt("=> switching to uid {cfg.uid} / {cfg.uid} ...")

  var gidslist = cast[ptr cint]([cfg.uid])
  discard setgroups(1, gidslist )
  discard setresuid(cint(cfg.uid), cint(cfg.uid), cint(cfg.uid))
  discard setresgid(cint(cfg.uid), cint(cfg.uid), cint(cfg.uid))
  
proc childAction(cfg: ptr ChildConfig):cint  =  
  discard sethostname(cstring(cfg.hostname), cint(len(cfg.hostname)))
  mounts(cfg)
  userns(cfg)

  let exe = findExe(cfg.cmd)
  echo fmt("execve {exe}  ... argv: {$cfg.argv}")
  var args = allocCStringArray(@[exe] & cfg.argv)
  var env = allocCStringArray(@["""PS1=\u@\h $"""])
  execve(exe, args, env) 

  # let p =  startProcess(command="/usr/bin/busybox", args= @["ash"], options={poParentStreams})
  # discard p.waitForExit()

  # let p =  startProcess(exe, "", cfg.argv, nil, {poParentStreams})
  # let res = p.waitForExit()
  # return cint(res)

proc prepare_child_uidmap(child_pid: Pid, fd: int) =
  let USERNS_OFFSET = 10000
  let USERNS_COUNT = 2000
  var has_userns = -1
  
  discard posix.read(cint(fd), addr has_userns, sizeof(has_userns))
  let files = @[fmt("/proc/{child_pid}/uid_map"), fmt("/proc/{child_pid}/gid_map")]

  for f in files:
    writeFile(f, fmt("0 {USERNS_OFFSET} {USERNS_COUNT}\n"))
  
  var data = cint(0)
  discard posix.write(cint(fd), addr data, sizeof(data))

proc writeHelp() = 
  echo """
NimJail 0.1.0 (containerify easily)
Allowed arguments:
  -h | --help     : show help
  -v | --version  : show version
  -c | --cmd      : command to run in a separate namespace.
  -u | --uid      : uid 
  -m | --mountdir : rootfs
  """
proc writeVersion() =
  echo "NimJail version 0.1.0"

proc cli*() = 

  var 
    cmd, mountdir: string
    uid: int
    args: seq[string] = @[]
    hostname = newHostName()

  if paramCount() == 0:
    writeHelp()
    quit(0)

  for kind, key, val in getopt():
    echo "Kind: ", kind, " KEY: ", key, " VAL: ", val
    case kind
    of cmdLongOption, cmdShortOption:
        case key
        of "help", "h": 
            writeHelp()
            quit()
        of "version", "v":
            writeVersion()
            quit()
        of "cmd", "c": cmd = val
        of "mount", "m": mountdir = val
        of "uid", "u": uid = parseInt(val)
        of "name", "n": hostname=val
        else:
          discard
    of cmdArgument:
      args.add(key)
    else:
      discard

  var cfg =  ChildConfig(argc:len(args), hostname:hostname, uid:uid, mountDir:mountdir, cmd:cmd, argv:args, env:newStringTable({"LOVE":"OK"}))
  cfg.env["PS1"] = fmt(""" \h @ \w <nimjail> $ """)
  cfg.env["USER"] = "root"
  var sockets : array[2, cint]
  let stackEnd = cast[clong](alloc(stackSize))
  let stack = cast[pointer](stackEnd + stackSize)
  discard socketpair(1, SOCK_SEQPACKET, 0, sockets)
  discard fcntl(sockets[0], F_SETFD, FD_CLOEXEC)
  cfg.fd = sockets[1]

  let fn : pointer = childAction
  var pid = clone(fn, stack, cint(newnsFlags), pointer(addr cfg), nil, nil, nil)

  if pid > 0:
    # handle child uidmap 
    prepare_child_uidmap(pid, sockets[0])
    var exitcode: cint

    discard waitpid(pid, exitcode, 0)
    echo "PARENT AFTER CHILD DONE: " & execCmdEx("hostname")[0]


when isMainModule:
  cli()