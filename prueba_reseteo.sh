#!/bin/bash

# filename: prueba_reseteo.sh

# check if the reboot flag file exists.

# We created this file before rebooting.
if [[ ! -f /var/run/resume-after-reboot ]]; then
  	echo "running script for the first time.."
  	# run your scripts here

  	# Preparation for reboot
  	script="bash /prueba_reseteo.sh"

  	# add this script to zsh so it gets triggered immediately after reboot
  	# change it to .bashrc if using bash shell
  	echo "$script" >> ~/.bashrc

  	# create a flag file to check if we are resuming from reboot.
  	sudo touch /var/run/resume-after-reboot

  	echo "rebooting.."
  	# reboot here
  	sleep 10
	reboot
else
  	echo "resuming script after reboot.."
	sleep 10

  	# Remove the line that we added in zshrc
  	sed -i "$script" ~/.bashrc

  	# remove the temporary file that we created to check for reboot
  	sudo rm -f /var/run/resume-after-reboot

  	# continue with rest of the script
fi
