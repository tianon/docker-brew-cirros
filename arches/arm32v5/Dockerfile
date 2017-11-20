FROM scratch

# https://download.cirros-cloud.net/0.4.0/cirros-0.4.0-arm-lxc.tar.xz
ADD rootfs-arm.tar.xz /

# skip network configuration
RUN rm /etc/rc3.d/S40-network
RUN sed -i '/is_lxc && lxc_netdown/d' /etc/init.d/rc.sysinit

CMD ["/sbin/init"]
