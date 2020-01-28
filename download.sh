#!/usr/bin/env bash
set -Eeuo pipefail

# map Bashbrew arches to CirrOS arches
# https://github.com/cirros-dev/cirros/tree/master/conf
arches=(
	'amd64=x86_64'
	'arm32v5=arm' # https://github.com/cirros-dev/cirros/blob/0.4.0/conf/buildroot-arm.config#L47
	'arm64v8=aarch64'
	'i386'
	'ppc64le'
)

self="$(readlink -f "$BASH_SOURCE")"
dir="$(dirname "$self")"
cd "$dir"

# https://github.com/cirros-dev/cirros/releases
tags=( $(
	git ls-remote --tags https://github.com/cirros-dev/cirros.git \
		| cut -d/ -f3- \
		| cut -d^ -f1 \
		| grep -vE '_pre' \
		| sort -rV
) )

version=
for tag in "${tags[@]}"; do
	# "curl --head" on the artifacts directly results in "403 Forbidden" ...
	if curl -fsSL "https://github.com/cirros-dev/cirros/releases/tag/$tag" 2>/dev/null | tac|tac | grep -qF "cirros-${tag}-x86_64-lxc.tar.xz"; then
		version="$tag"
		break
	fi
done
if [ -z "$version" ]; then
	echo >&2 "error: failed to find suitable version/tag (tried all of: ${tags[*]})"
	exit 1
fi

echo "$version:"

rm -rf arches
mkdir arches
cd arches
echo "$version" > version

for arch in "${arches[@]}"; do
	bashbrewArch="${arch%=*}"
	cirrosArch="${arch#*=}"

	mkdir "$bashbrewArch"

	url="https://github.com/cirros-dev/cirros/releases/download/${version}/cirros-${version}-${cirrosArch}-lxc.tar.xz"
	if ! curl -fsSL -o "$bashbrewArch/rootfs-$cirrosArch.tar.xz" "$url"; then
		echo >&2
		echo >&2 "warning: skipping '$bashbrewArch / $cirrosArch': failed to download '$url'"
		echo >&2
		rm -rf "$bashbrewArch"
		continue
	fi

	echo "- $bashbrewArch ($cirrosArch)"

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

	echo "$bashbrewArch" >> supported-arches
done
