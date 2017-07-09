#!/bin/bash

[ -z "$1" -o -z "$2" ] && echo "Usage: $(basename $0) rescue-image-url [user@]host" && exit

sed -e "s/RESCUE_IMAGE_URL/$1/"<<'SCRIPT'|ssh $2
set -e

RESCUE_ROOT=/run/rescue

mkdir -p $RESCUE_ROOT
mount none -t tmpfs -o size=1G $RESCUE_ROOT
cd $RESCUE_ROOT
wget -q -O - RESCUE_IMAGE_URL|tar xzf -

cat > etc/motd <<'MOTD'
To kill processes that use old root please run:
fuser -k -m /old_root

To unmount old root please run:
mount|grep /old_root|awk '{print $3}'|sort -r|while read x; do umount $x; done

After that you can check disks with fsck

MOTD

rm -f etc/mtab
ln -s /proc/mounts etc/mtab

mount -t tmpfs tmp tmp
mount -t proc proc proc
mount -t sysfs sys sys
if ! mount -t devtmpfs dev dev; then
    mount -t tmpfs dev dev
    cp -a /dev/* dev/
    rm -rf dev/pts
fi
mkdir -p dev/pts
mount -t devpts devpts dev/pts

OLD_INIT=$(readlink /proc/1/exe)
cat >tmp/${OLD_INIT##*/} <<EOF
#!/bin/bash
cd $RESCUE_ROOT
mount --make-rprivate /
pivot_root . old_root
chroot . mkdir -p /var/run/sshd
chroot . chmod 0700 /var/run/sshd
chroot . /usr/sbin/sshd
exec chroot . /fakeinit
EOF
chmod +x tmp/${OLD_INIT##*/}
mount --bind tmp/${OLD_INIT##*/} ${OLD_INIT}

telinit u
SCRIPT
echo "Now please use 'ssh -p 11122 root@host' command to get to the rescue environment"
