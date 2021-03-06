#!/bin/bash

use_cache= #192.168.1.5 # set to pacserve ip

set -e
info() { echo -e "\e[1;39m$@\e[m"; }

info "Setting up pacman"
pacman -Sy --noconfirm --noprogressbar pacman-contrib
# select pacman mirrors
[[ -z "$use_cache" ]] && rm /etc/pacman.d/mirrorlist || echo 'Server = http://'$use_cache':15678/pacman/$repo/$arch' >/etc/pacman.d/mirrorlist
curl -s 'https://www.archlinux.org/mirrorlist/?country=CN&protocol=http&protocol=https&ip_version=4&use_mirror_status=on' \
	| sed 's|^#||;/^#/ d' | rankmirrors -n 6 - >>/etc/pacman.d/mirrorlist
# add mingw repos - https://github.com/maxrd2/arch-repo/
cat >>/etc/pacman.conf <<EOF
[multilib]
Include = /etc/pacman.d/mirrorlist
[shugaoye]
SigLevel = Optional TrustAll
EOF
echo 'Server = https://github.com/shugaoye/MINGW-packages/releases/download/$arch' >>/etc/pacman.conf
# setup pacman
pacman-key --init
pacman-key --populate archlinux
pacman -Sy archlinux-keyring pacman --noconfirm --noprogressbar --needed --quiet
pacman-db-upgrade

info "Updating system"
pacman -Su --noconfirm --noprogressbar --quiet

info "Installing system packages"
pacman -S --noconfirm --noprogressbar \
	sudo imagemagick make git binutils patch base-devel python2 wget curl \
	expac yajl vim openssh rsync lzop unzip bash-completion ncdu jq pacaur
	
info "Installing mingw packages"
pacman -S --noconfirm --noprogressbar \
	mingw-w64-toolchain mingw-w64-cmake mingw-w64-configure mingw-w64-pkg-config \
	mingw-w64-ffmpeg mingw-w64-qt5 mingw-w64-kf5 nsis

info "Cleaning up"
rm -rf \
	/usr/share/{doc,man}/* \
	/tmp/* \
	/var/{tmp,cache/pacman/pkg,lib/pacman/sync}/* \
	/home/devel/.cache
