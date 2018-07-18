#!/bin/bash
set -Eeuo pipefail

self="$(readlink -f "$BASH_SOURCE")"
dir="$(dirname "$self")"
cd "$dir"

gitHubUrl='https://github.com/tianon/docker-brew-cirros'
gitFetch='refs/heads/dist'

#rawGitUrl="$gitHubUrl/raw"
rawGitUrl="${gitHubUrl//github.com/cdn.rawgit.com}" # we grab tiny files, and rawgit's CDN is more consistently speedy on a cache hit than GitHub's

commit="$(git ls-remote "$gitHubUrl.git" "$gitFetch" | cut -d$'\t' -f1)"

version="$(curl -fsSL "$rawGitUrl/$commit/arches/version")"
arches="$(curl -fsSL "$rawGitUrl/$commit/arches/supported-arches")"

# prints "$2$1$3$1...$N"
join() {
	local sep="$1"; shift
	local out; printf -v out "${sep//%/%%}%s" "$@"
	echo "${out#$sep}"
}

selfCommit="$(git log --format='format:%H' -1 "$self")"
cat <<-EOH
# this file is generated via $gitHubUrl/blob/$selfCommit/$self

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
