#!/bin/bash

# filename: prueba_reseteo.sh

# Reboot flag file existence check.
if [[ ! -f ~/resume-after-reboot ]]; then

	# Add this script to bash so it gets triggered immediately after reboot
  	phrase="bash ~/PartKeepr-installation-script/prueba_reseteo.sh"
  	echo "$phrase" >> ~/.bashrc

  	# create a flag file to check if we are resuming from reboot.
  	sudo touch ~/resume-after-reboot

	# Reboot here
	echo "Rebooting..."

  	sleep 3
	reboot
else
  	echo "Resuming script after reboot.."
  	# Remove the line that we added in bashrc
	sudo grep -v "$phrase" ~/.bashrc > ~/aux.txt
	sudo mv ~/aux.txt ~/.bashrc

  	# Remove the temporary file that we created to check for reboot
  	sudo rm -f ~/resume-after-reboot
  	# Continue with rest of the script
fi
