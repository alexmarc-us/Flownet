#!/bin/bash
#
# Alex Marcus
# Flowconf : Flownet Server Configuration Wizard
# Connecticut College Computer Science 495
# Fall 2009
# amarcus@conncoll.edu

# Run as: sudo ./flowconf.sh

# Check if user has sudo
if [ "$UID" -ne "0" ] 
then
    echo "You much be root/sudo to run the Flownet wizard!"
    exit 1
fi

while :
do

echo -e "What would you like to do?\
Input \"install\" for a fresh installation of Flownet\n\
Input \"add\" to add a server to your Flownetwork (new server must have Flownet configured already)\n\
Input \"log\" to view the current Flowlog\n\
Input \"clear\" to clear the current Flowlog\n\
Input \"edit\" to view and edit the local flownet.conf\n
Input \"quit\" to banish this wizard"

if [ ! -d /home/flownet/ ]
then
    echo "Flownet is NOT installed!!! (add, log, clear, and edit will FAIL)"
fi

read INPUT
case $INPUT in
    install)
	# Install fresh Flownet
	echo "A fresh install will erase all data (including backups) from prior installations of Flownet.  Are you sure? (yes/no)"
	read SURE
	case $SURE in
	    yes)
		# Empty /home/flownet directory
		echo "Removing the /home/flownet/ directory..."
		rm -rf /home/flownet/ 
		echo "...Done!"
		echo

		# Add flownet group and user with /home/flownet/ home directory
		echo "Adding the flownet group and user with /home/flownet/ home directory..."
		groupadd flownet
		useradd -m -g flownet flownet
		echo "...Done!"
		echo
		
		# Change the Flownet user password (user prompt)
		echo "Setting up the flownet user password..."
		passwd flownet
		echo "...Done!"
		echo
		
		# Create flownet.conf
		echo "Moving flownet.conf file to Flownet home folder..."
		mv flownet.conf /home/flownet/flownet.conf
		chown flownet:flownet /home/flownet/flownet.conf
		echo "...Done!"
		echo

		# Create flowlock.conf
		echo "Moving flowlock.conf file to Flownet home folder..."
		mv flowlock.conf /home/flownet/flowlock.conf
		chown flownet:flownet /home/flownet/flowlock.conf
		echo "...Done!"
		echo

		# Create flowlog.txt
		echo "Creating the Flownet log file..."
		rm -f /home/flownet/flowlog.txt >/dev/null
		echo "FLOWNET LOG" >>flowlog.txt
		echo "...Done!"

		# Create flownet.sh
		echo "Moving flownet.sh file to Flownet home folder..."
		mv flownet.sh /home/flownet/flownet.sh
		chown flownet:flownet /home/flownet/flownet.sh
		echo "...Done!"
		echo
		
		# Set flownet.sh to run at startup (crontab line)
		echo "Setting /home/flownet/flownet.sh to run at startup..."
		echo "* * * * * /home/flownet/flownet.sh" >> /etc/crontab
		echo "...Done!"
		echo

		# Generate RSA key for local Flownet user
		echo "Generating local RSA keys..."
		echo "When prompted, press enter for no password:"
		su flownet -c "ssh-keygen -t rsa"
		echo "...Done!"
		
		echo "Flownet has now sucessfully been installed!  You should now use the edit command to configure flownet, the add command to add servers to your Flownetwork, and restart once you're ready."
		echo
		;;

	    no)
		;;

	    *)
		echo "Invalid response!"
		;;
	esac
	;;

    add)
	# Add new server to flownet.conf
	echo "What server would you like to add to your Flownetwork? (IP or hosename if within same LAN)"
	read NEWSERVER

	# Add NEWSERVER to flownet.conf file
	echo "Adding ${NEWSERVER} to local flownet.conf file..."
	NEWLINE=`cat /home/flownet/flownet.conf | grep "CHECKSERVERS=(" | tr -d ")" | sed "s/$/ $NEWSERVER)/"`
	cat /home/flownet/flownet.conf | sed "s/^.*CHECKSERVERS=(.*$/$NEWLINE/" >/home/flownet/flownet.conf.temp
	mv /home/flownet/flownet.conf.temp /home/flownet/flownet.conf
	echo "...Done!"
	echo

	# Copy public RSA to new server
	echo "Copying local public RSA key to ${NEWSERVER}"
	su flownet -c "scp /home/flownet/.ssh/id_rsa.pub flownet@${NEWSERVER}:~/.ssh/authorized_keys"
	su flownet -c "ssh flownet@${NEWSERVER} chmod 700 /home/flownet/.ssh/authorized_keys"
	echo "...Done!"
	echo
	
	;;

    log)
	# View the Flowlog
	more /home/flownet/flowlog.txt
	;;

    clear)
	# Clear the Flowlog
	echo "Clearing the Flownet log file..."
	rm -f /home/flownet/flowlog.txt
	echo "FLOWNET LOG" >>flowlog.txt
	echo "...Done!"
	;;

    edit)
	# Edit flownet.conf
	vim /home/flownet/flownet.conf
	;;

    quit)
	# Quit the configuration wizard
	echo "Quitting now!"
	break
	;;
	    
    *)
	echo "Invalid response!"
	;;

esac
done