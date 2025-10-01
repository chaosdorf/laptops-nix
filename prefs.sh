# This file is run (sourced) as root on each guest user creation.

# set the password, so that the user can unlock their screen
echo "guest" | passwd $USER -s
# add the user to the systemd-journal group, so that they can run `journalctl`
usermod --groups systemd-journal --append $USER
