#!/bin/bash
set -e -u

RESCUE_ROOT=/run/rescue
RESCUE_SSH_PORT=11122
RESCUE_SSH_PASSWORD=rescueme

mkdir -p $RESCUE_ROOT
mount none -t tmpfs -o size=1G $RESCUE_ROOT
debootstrap trusty $RESCUE_ROOT
echo "rescue_system" > $RESCUE_ROOT/etc/debian_chroot
mkdir -p $RESCUE_ROOT/old_root

gcc --static -o fakeinit fakeinit.c
strip fakeinit
cp fakeinit $RESCUE_ROOT/

chroot $RESCUE_ROOT apt-get -y install lvm2 psmisc openssh-server openssh-client openssh-blacklist openssh-blacklist-extra --no-install-recommends
sed -i "s/^Port .*$/Port $RESCUE_SSH_PORT/" $RESCUE_ROOT/etc/ssh/sshd_config
sed -i 's/^PermitRootLogin .*$/PermitRootLogin yes/' $RESCUE_ROOT/etc/ssh/sshd_config
chroot $RESCUE_ROOT bash -c "echo root:$RESCUE_SSH_PASSWORD|chpasswd"
tar -C $RESCUE_ROOT -czf ./rescue-image.tgz .
umount $RESCUE_ROOT
