# NimJail

Simple try to implement [linux containers in 500LOC](https://blog.lizzie.io/linux-containers-in-500-loc.html#org0aee542) in nim and to learn about namespaces, cgroups and capabilities 

# rootfs
```
/tmp/myrootfs
├── dmdmdmfile
├── lib64
└── usr
    ├── bin
    │   ├── bash
    │   ├── busybox
    │   ├── cat
    │   └── redis-cli
    ├── lib
    │   ├── libc.so.6
    │   ├── libdl.so.2
    │   ├── libgcc_s.so.1
    │   ├── libjemalloc.so.2
    │   ├── libm.so.6
    │   ├── libncursesw.so.6
    │   ├── libpthread.so.0
    │   ├── libreadline.so.7
    │   └── libstdc++.so.6
    └── lib64
        └── ld-linux-x86-64.so.2
```

# execution
```sudo ./nimjail -u=0 -m=/tmp/myrootfs --cmd=busybox echo hello world```

# TODO
- cgroups
- caps
- network
- TBD