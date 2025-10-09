# laptops-nix

This repository contains configuration for some of the public laptops in the space.

The guest account password is `guest`. Updates can be installed by running `update`.

There's an `admin` account that can be reached from the login screen or via `su admin`.

Users can be created with the following command (UI will follow):

> homectl create your-login-name --real-name="Your real name" --storage=luks --fs-type=btrfs --image-path /dev/sdX --shell=$(which your-shell) --member-of=users
