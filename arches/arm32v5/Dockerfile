FROM scratch

# https://github.com/cirros-dev/cirros/releases/download/0.5.3/cirros-0.5.3-arm-lxc.tar.xz
ADD rootfs-arm.tar.xz /

# skip network configuration
RUN rm /etc/rc3.d/S40-network
RUN sed -i '/is_lxc && lxc_netdown/d' /etc/init.d/rc.sysinit

CMD ["/sbin/init"]
