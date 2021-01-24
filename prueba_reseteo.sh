#!/bin/bash

# filename: prueba_reseteo.sh

# check if the reboot flag file exists (we created this file before rebooting).
if [[ ! -f /var/run/resume-after-reboot ]]; then

# Run your scripts here
  	echo "Running script for the first time.."
  	# Preparation for reboot
	# Add this script to bash so it gets triggered immediately after reboot
  	phrase="bash ~/PartKeepr-installation-script/prueba_reseteo.sh"
  	echo "$phrase" >> ~/.bashrc

  	# create a flag file to check if we are resuming from reboot.
  	sudo touch /var/run/resume-after-reboot
	ls /var/run/
	tail -n 1 ~/.bashrc
	# Reboot here
  	echo "Rebooting.."
  	sleep 3
	#reboot
else
  	echo "Resuming script after reboot.."

  	# Remove the line that we added in bashrc
	sudo grep -v "bash ~/PartKeepr-installation-script/prueba_reseteo.sh" ~/.bashrc > ~/aux.txt
	sudo mv ~/aux.txt ~/.bashrc

  	# remove the temporary file that we created to check for reboot
  	sudo rm -f /var/run/resume-after-reboot
	ls /var/run/
	tail -n 1 ~/.bashrc
  	# continue with rest of the script
fi
