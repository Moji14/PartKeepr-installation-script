#!/bin/bash

# Copyright (c) 2021 Mohamed Lanjri El Halimi. All rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 3 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# This bash script will automatize PartKeepr installation on Ubuntu 16.04
# running on a virtual machine (AWS free tier instance in this case).

# Reboot flag file existence check.
if [[ ! -f ~/resume-after-reboot ]]; then

        # Add this script to bash so it gets triggered immediately after reboot
        phrase="bash ~/PartKeepr-installation-script/PartKeeprScript.sh"
        echo "$phrase" >> ~/.bashrc

        # create a flag file to check if we are resuming from reboot.
        sudo touch ~/resume-after-reboot

	#Code before reboot
	# Go user diretory 
	cd

	# Server update and upgrade after EC2 instance creation
	sudo apt-get update -y
	sudo apt-get upgrade -y

        # Reboot here
	print "System will reboot now, please SSH connect again after a prudent wait"
        reboot
else
        echo "Resuming script after reboot.."
        # Remove the line that we added in bashrc
        sudo grep -v "$phrase" ~/.bashrc > ~/aux.txt
        sudo mv ~/aux.txt ~/.bashrc

        # Remove the temporary file that we created to check for reboot
        sudo rm -f ~/resume-after-reboot

        # Continue with rest of the script needed to be done after reboot

       	# Install tasksel to perform automated LAMP server installation
	sudo apt-get install tasksel

	# Execute LAMP server automated installation
	sudo tasksel install lamp-server

	# Automated MySQL installation/configuration
	mysql_secure_installation

	#MySQL database creation script

	sudo mysql -u root -pbasedatospwd -e "USE mysql;"
	sudo mysql -u root -pbasedatospwd -e "CREATE USER 'admin'@'localhost' IDENTIFIED BY 'adminbasepwd';"
	sudo mysql -u root -pbasedatospwd -e "GRANT ALL PRIVILEGES ON * . * TO 'admin'@'localhost';"
	sudo mysql -u root -pbasedatospwd -e "UPDATE user SET plugin='unix_socket' WHERE User='admin';"

	#Now we will set up a user and database for PartKeepr. Replace insert_password_here with a suitable password
	sudo mysql -u root -pbasedatospwd -e "CREATE USER 'PartKeepr'@'localhost' IDENTIFIED BY 'partkeepruserpwd';"
	sudo mysql -u root -pbasedatospwd -e "UPDATE user SET plugin='mysql_native_password' WHERE User='PartKeepr';"
	sudo mysql -u root -pbasedatospwd -e "FLUSH PRIVILEGES;"
	sudo mysql -u root -pbasedatospwd -e "CREATE DATABASE PartKeepr CHARACTER SET UTF8;"
	sudo mysql -u root -pbasedatospwd -e "GRANT USAGE ON *.* to 'PartKeepr'@'localhost';"
	sudo mysql -u root -pbasedatospwd -e "GRANT ALL PRIVILEGES ON PartKeepr.* TO 'PartKeepr'@'localhost';"
	sudo mysql -u root -pbasedatospwd -e " EXIT;"



	# PHP installation verification (not necesary, but recommended for better script)
	# Need to create the phpinfo.php file
	#sudo nano /var/www/html/phpinfo.php

	# PHP required extensions installation
	sudo apt-get install php-curl php-ldap php-bcmath php-gd php-dom

	# PartKeepr files downloads and extraction(decompression)
	wget https://downloads.partkeepr.org/partkeepr-1.4.0.tbz2
	sudo tar -xjvf partkeepr-1.4.0.tbz2 -C /var/www

	# Check the www group to modifiy directory premissions. This step can be skiped (not necesary but recommended for better script)
	# cat /etc/passwd | grep www

	# Directory permissions modifications
	sudo chown -R $(whoami):www-data /var/www/partkeepr-1.4.0
	sudo find /var/www/partkeepr-1.4.0 -type d -exec chmod 770 {} +
	sudo find /var/www/partkeepr-1.4.0 -type f -exec chmod 660 {} +
	sudo a2enmod userdir rewrite

	# Set Apache server and PHP configurations by relocating them from the files already downloared from my repository on GitHub
	# Create backup copies of the files that needed to be configured
	sudo mv /etc/apache2/apache2.conf /etc/apache2/apache2.conf.bak
	sudo mv /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/000-default.conf.bak
	sudo mv /etc/apache2/sites-available/default-ssl.conf /etc/apache2/sites-available/default-ssl.conf.bak
	sudo mv /etc/php/7.0/apache2/php.ini /etc/php/7.0/apache2/php.ini.bak

	#Move files from the cloned repository directory to it's final destinations
	sudo mv ~/PartKeepr-installation-script/apache2.conf /etc/apache2/apache2.conf.bak
	sudo mv ~/PartKeepr-installation-script/000-default.conf /etc/apache2/sites-available/000-default.conf.bak
	sudo mv ~/PartKeepr-installation-script/default-ssl.conf /etc/apache2/sites-available/default-ssl.conf.bak
	sudo mv ~/PartKeepr-installation-script/php.ini /etc/php/7.0/apache2/php.ini.bak

	#Apache server restart
	sudo service apache2 restart

	#Indicate user to prepare to do the on-website configuration steps and then prepare launch a web browser
	echo "Plase open the brouser and insert the next url 'yoururl.com/setup' and follow the steps"

	# Add the Authkey generated by PartKeepr installer to authkey.php
	echo "Plase paste here the authkey generated by the PartKeepr installer"
	read key
	sudo echo "$key" >> /var/www/partkeepr-1.4.0/app/authkey.php

	#Move cron.d file
	sudo mv ~/PartKeepr-installation-script/partkeepr /etc/cron.d/partkeepr

	#Remove the donwloaded PartKeepr file (ask with a reconmedation).
	sudo rm partkeepr-1.4.0.tbz2

	# Print installation end message.
	print "Installation finished, enjoy you inventory management software!"

fi
