FROM scratch

# https://github.com/cirros-dev/cirros/releases/download/0.6.2/cirros-0.6.2-x86_64-lxc.tar.xz
ADD rootfs-x86_64.tar.xz /

# skip network configuration
RUN rm /etc/rc3.d/S40-network
RUN sed -i '/is_lxc && lxc_netdown/d' /etc/init.d/rc.sysinit

CMD ["/sbin/init"]
