#!/bin/bash

set -euo pipefail

# Usage: buildpkg.sh <pkg1> <pkg2> ...
if [[ $# -eq 0 ]]; then
    echo "Usage: $0 <pkg1> <pkg2> ..."
    exit 1
fi

PKGS=("$@")

useradd -m -s /bin/bash aarchd-builder
echo "aarchd-builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

for pkg in "${PKGS[@]}"; do
    pkgdir="/mnt/PKGBUILDs/$pkg"

    if [[ ! -d "$pkgdir" ]]; then
        echo "Package directory $pkgdir does not exist. Skipping..."
        exit 1
    fi

    echo "Building package: $pkg"

    su aarchd-builder -c "cd '$pkgdir' && makepkg -scf --noconfirm"

    find "$pkgdir" -maxdepth 1 -name "*.pkg.tar.zst" -exec mv -v {} /mnt/pkgs/ \;
done

echo "All done.."
