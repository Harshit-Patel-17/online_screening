sudo rm -rf /sandbox
sudo mkdir /sandbox
sudo debootstrap --variant=buildd --arch amd64 --foreign trusty /sandbox/ http://mirror.cc.columbia.edu/pub/linux/ubuntu/archive/
sudo chroot /sandbox /debootstrap/debootstrap --second-stage
sudo cp /etc/apt/sources.list /sandbox/etc/apt/sources.list
sudo cp /etc/hosts /sandbox/etc/hosts
sudo mount proc /sandbox/proc -t proc
sudo mount sysfs /sandbox/sys -t sysfs
sudo mkdir /sandbox/test
sudo mkdir /sandbox/test/input
sudo mkdir /sandbox/test/output
sudo mkdir /sandbox/programs
sudo mkdir /sandbox/admin_programs
sudo cp dispatch.cpp /sandbox/admin_programs/
