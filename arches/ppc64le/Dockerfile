FROM scratch

# https://github.com/cirros-dev/cirros/releases/download/0.6.0/cirros-0.6.0-ppc64le-lxc.tar.xz
ADD rootfs-ppc64le.tar.xz /

# skip network configuration
RUN rm /etc/rc3.d/S40-network
RUN sed -i '/is_lxc && lxc_netdown/d' /etc/init.d/rc.sysinit

CMD ["/sbin/init"]
