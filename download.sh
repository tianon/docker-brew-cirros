#!/usr/bin/env bash
set -Eeuo pipefail

self="$(readlink -f "$BASH_SOURCE")"
dir="$(dirname "$self")"
cd "$dir"

version="$(curl -fsSL 'http://download.cirros-cloud.net/version/released')"

# map Bashbrew arches to CirrOS arches
arches=(
	'amd64=x86_64'
	'arm32v5=arm' # https://git.launchpad.net/cirros/tree/conf/buildroot-arm.config?id=0.4.0#n47
	'arm64v8=aarch64'
	'i386'
	'ppc64le'
)

rm -rf arches
mkdir arches
cd arches
echo "$version" > version

for arch in "${arches[@]}"; do
	bashbrewArch="${arch%=*}"
	cirrosArch="${arch#*=}"

	mkdir "$bashbrewArch"

	url="https://download.cirros-cloud.net/$version/cirros-$version-$cirrosArch-lxc.tar.xz"
	if ! curl -fL -o "$bashbrewArch/rootfs-$cirrosArch.tar.xz" "$url"; then
		echo >&2
		echo >&2 "warning: skipping '$bashbrewArch / $cirrosArch': failed to download '$url'"
		echo >&2
		rm -rf "$bashbrewArch"
		continue
	fi

	{
		echo 'FROM scratch'
		echo
		echo "# $url"
		echo "ADD rootfs-$cirrosArch.tar.xz /"
		echo
		echo '# skip network configuration'
		echo 'RUN rm /etc/rc3.d/S40-network'
		echo "RUN sed -i '/is_lxc && lxc_netdown/d' /etc/init.d/rc.sysinit"
		echo
		echo 'CMD ["/sbin/init"]'
	} > "$bashbrewArch/Dockerfile"
done
