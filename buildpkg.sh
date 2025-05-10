#!/bin/bash

set -euo pipefail

# Usage: buildpkg.sh <pkg1> <pkg2> ...
if [[ $# -eq 0 ]]; then
    echo "Usage: $0 <pkg1> <pkg2> ..."
    exit 1
fi

info() {
    echo -e "\e[35m$1\e[0m"
}

PKGS=("$@")

if ! id -u aarchd-builder &>/dev/null; then
    useradd -m -s /bin/bash aarchd-builder
fi

if ! grep -Fxq "root ALL=(ALL) NOPASSWD: ALL" /etc/sudoers; then
    echo "root ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
fi

if ! grep -Fxq "aarchd-builder ALL=(ALL) NOPASSWD: ALL" /etc/sudoers; then
    echo "aarchd-builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
fi

pacman -Syu base-devel fakeroot git --needed --noconfirm

chown -R aarchd-builder:aarchd-builder /mnt/PKGBUILDs

for pkg in "${PKGS[@]}"; do
    pkgdir="/mnt/PKGBUILDs/$pkg"

    if [[ ! -d "$pkgdir" ]]; then
        info "Package directory $pkgdir does not exist. Skipping..."
        exit 1
    fi

    info "Building package: $pkg"

    sudo -u aarchd-builder -H bash -c "cd '$pkgdir' && makepkg -scf --noconfirm"

    find "$pkgdir" -maxdepth 1 \( -name "*.pkg.tar.zst" -o -name "*.pkg.tar.zst.sig" \) -exec mv -v {} /mnt/pkgs/ \;

done

echo "All done.."
