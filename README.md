# laptops-nix

This repository contains configuration for some of the public laptops in the space.

The guest account password is `guest`.
Updates to the software and to the configuration can be installed by running `update`.
Updates to the software are installed automatically.

There's an `admin` account that can be reached from the login screen or via `su admin`.

Users can be created with `account-manager` or with the following command:

```bash
homectl create your-login-name --real-name="Your real name" --storage=luks --fs-type=btrfs --image-path /dev/sdX --shell=$(which your-shell) --member-of=users
```
