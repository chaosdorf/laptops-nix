#!/usr/bin/env bash
# This shell script can be called by `update`.
# It updates the system software and configuration.
# It elevates to root by itself (without a password).

if [ "$EUID" -ne 0 ]
  then exec sudo /run/current-system/sw/bin/update
fi

cd /etc/nixos
git remote set-url origin https://codeberg.org/Chaosdorf/laptops-nix.git
git fetch
git reset --hard origin/main
nixos-rebuild boot
echo "Reboot the system to apply the update"
