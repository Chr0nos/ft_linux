# The project
this is a 42 school project, you can check the subjet here

> https://cdn.intra.42.fr/pdf/pdf/758/ft_linux.pdf

the global idea is to build a linux from scratch system by hand.

# Host system
i do the tests on an arch linux 64 bits inside a virtual machine with 12Gb ram

# Dependencies
the scripts requires the following dependencies on the host system:

> curl

> wget

> sudo

> glibc

> gcc

# Partitioning
> sudo cfisk /dev/sda

> sudo mount -t btrfs /dev/sda1 /mnt

> sudo mkdir -v /mnt/boot

> sudo mount -t ext4 /dev/sda3 /mnt/boot

> sudo swapon /dev/sda2

> sudo mkdir -pv /usr/src/sources

> sudo mkdir -v /mnt/tools

> sudo ln -s /mnt/tools /tools

> sudo chown -R 1000:1000 /mnt/tools /mnt/usr/src

> now you can start the installation

# Install temp system
first you need to edit config.sh (in the example upside i assume $LFS = /mnt)

> ./ft_linux.sh

# Install
> sudo ./lfs.sh

# End
for now that's all, you will ne to finish the configuration by yourself,
i'm still working on this project.t
