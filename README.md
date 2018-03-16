> Partitioning
sudo cfisk /dev/sda

sudo mount -t btrfs /dev/sda1 /mnt

sudo mkdir -v /mnt/boot

sudo mount -t ext4 /dev/sda3 /mnt/boot

sudo swapon /dev/sda2

sudo mkdir -pv /usr/src/sources

sudo mkdir -v /mnt/tools

sudo ln -s /mnt/tools /tools

sudo chown -R 1000:1000 /mnt/tools /mnt/usr/src

now you can start the installation


> Install temp system
first you need to edit config.sh (in the example upside i assume $LFS = /mnt)

./ft_linux.sh

> Install

sudo ./lfs.sh


> End
for now that's all, you will ne to finish the configuration by yourself,
i'm still working on this project.t
