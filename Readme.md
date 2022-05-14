# PS3 Kernel cross-compilation

This project help the cross compilation of a ps3 linus otheros++ compatible kernel and initramfs.
It helped me learn how to cross compile initramfs and custom kernels.

## HOW TO

In order to compile, i used the Debian 11 cross compiler for ppc64 (Big Endian).

If you are on Debian 11 you can install it using the following commant: 

```shell
sudo apt-get install gcc-10-powerpc64-linux-gnu
```

You can then simply run 
```shell
make
```

If Everything went fine, you should end-up with an arch file containing a root file system and a custom initramfs to play with.
