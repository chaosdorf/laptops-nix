# This file is run (sourced) as root on each guest user creation.

# set the password, so that the user can unlock their screen
echo "guest" | passwd $USER -s
