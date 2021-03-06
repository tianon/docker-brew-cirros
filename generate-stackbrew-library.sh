#!/bin/bash
set -Eeuo pipefail

self="$(readlink -f "$BASH_SOURCE")"
dir="$(dirname "$self")"
cd "$dir"

gitHubUrl='https://github.com/tianon/docker-brew-cirros'
gitFetch='refs/heads/dist'

commit="$(git ls-remote "$gitHubUrl.git" "$gitFetch" | cut -d$'\t' -f1)"

version="$(curl -fsSL "$gitHubUrl/raw/$commit/arches/version")"
arches="$(curl -fsSL "$gitHubUrl/raw/$commit/arches/supported-arches")"

# prints "$2$1$3$1...$N"
join() {
	local sep="$1"; shift
	local out; printf -v out "${sep//%/%%}%s" "$@"
	echo "${out#$sep}"
}

selfCommit="$(git log --format='format:%H' -1 "$self")"
cat <<-EOH
# this file is generated via $gitHubUrl/blob/$selfCommit/$(basename "$self")

Maintainers: Tianon Gravi <admwiggin@gmail.com> (@tianon)
GitRepo: $gitHubUrl.git
GitFetch: $gitFetch
GitCommit: $commit
Architectures: $(join ', ' $arches)
EOH
for arch in $arches; do
	echo "$arch-Directory: arches/$arch"
done

tags=()
while [ "${version%[.-]*}" != "$version" ]; do
	tags+=( $version )
	version="${version%[.-]*}"
done
tags+=(
	$version
	latest
)

echo
echo "Tags: $(join ', ' "${tags[@]}")"
