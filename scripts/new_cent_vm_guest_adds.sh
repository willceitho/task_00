# needed for built guest additions for VBox
yum -y install wget perl gcc dkms kernel-devel kernel-headers make bzip2 && \
mount /dev/cdrom /mnt && \
/mnt/VBoxLinuxAdditions.run && \
usermod -aG vboxsf worker && \
umount /mnt && \
reboot