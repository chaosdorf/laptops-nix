#!/usr/bin/env bash
# This shell script can be called by `update`.
# It updates the system software and configuration.
# It elevates to root by itself (without a password).

if [ "$EUID" -ne 0 ]
  then exec sudo update
fi

cd /etc/nixos
git fetch
git reset --hard origin/main
nixos-rebuild switch
