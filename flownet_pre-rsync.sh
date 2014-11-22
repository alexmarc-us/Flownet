#!/bin/bash

# Get time setting (from conf)
WAIT=1

# Get servers to check (from conf)
servers=("localhost")

# Loop this script forever
while [ 1 ]
do
    # Count up to WAIT, then execute server check
    WAITCOUNT=0
    while [ $WAITCOUNT != $WAIT ]
    do
	sleep 1
	let WAITCOUNT++
    done
    
    echo "Flowout: Time to start the flow..."
    
    # Loop through servers, executing server checks
    len=${#servers[@]}
    i=0
    while [ $i -lt $len ]
    do
	# Ping servers[i] 5 times
	echo "Flowout: Trying to ping server ${servers[$1]}"
	ping -q -c 5 ${servers[$i]}
	# If ping of servers[i] returns more than 0 times
	if [ $? = 0 ] # This checks the exit code of the ping command
	then
	    echo "Flowout: Server ${servers[$i]} appears to be up, attempting to confmount..."
	    mkdir ./confmount/
	    # Mount servers[i] flownet home folder as ./confmount/ (from conf)
	    ###username=flownet
	    ###password=flownetpass
	    ###sudo mount -tsmbfs -o username=$username,password=$password ${servers[$i]} ./confmount/
	    mount /home/flownet/ ./confmount # Only until mount figured out/networking
	    # Check if confmount worked and flownet.conf exists at ./confmount/
	    if [ $? = 0 ] &&[ -f ./confmount/flownet.conf ] # Checks the exit code of the confmount command and the status of flownet.conf
	    then
		echo "Flowout: Flownet home folder mount successful and configuration file found on ${servers[$i]}!"
		
		echo "Flowout: Attemping to mount backup/restore location on ${servers[$i]}..."
		# Mount servers[i] backup/restore location as ./accessmount/ (from conf)
		###accessmount=/home/flownet/
		###sudo mount -tsmbfs -o username=$username,password=$password ${servers[$i]}:$accessmount ./accessmount/
		mount /home/flownet/backuptest/ ./accessmount
		# Check if accessmount worked
		if [ $? = 0 ] # This checks the exit code of the accessmount mount command
		then
		    echo "Flowout: Flownet backup/restore location mount successful on ${servers[$i]}!"
	            # Set action as action switch (from conf) and call appropriate function
		    case $action in
			restore)
			    echo "Flowout: Restore action is set!"
		            # restore $servers[$i]
			    ;;
			backup)
		            echo "Flowout: Backup action is set!"
			    # backup $servers[$i]
			    ;;
			*)
		            echo "Flowout: Invalid action switch set for ${servers[$i]}, moving to next server..."
			    ;;
		    esac
		
		    # Unmount and clean up
		    sudo umount ./confmount/
		    rm -rf ./confmount/
		    sudo umount ./accessmount/
		    rm -rf ./confmount/
		    
		    let i++
		else
		    echo "Flowout: Mounting of ${servers[$i]} backup/restore location failed!  Moving to next server..."
		    let i++
		fi  
	    elif [ $? != 0 ]
	    then
		echo "Flowout: Mounting of confmount failed!  Moving to next server..."
		let i++
	    else
		echo "Flowout: ./confmount/flownet.conf does not exist, moving to next server..."
		let i++
	    fi
	else
	    echo "Flowout: Server ${servers[$i]} isn't responding, moving to next server..."
	    let i++
	fi
	let s++
    done
done
	
###

# backup servername backuplocation
backup() {
	DATE="`date +%F`"
	# If prior backup exists
	if [ -f ./backup/backup-$1.* ]
	then
	    # (Set lastbackup as newest backup directory)
	    lastbackup=
	    # Create server.date folder
            mkdir "./backups/backup-${1}.${DATE}"
	    # Check which files on server are new (diff)
	    diff `ls -l ./accessmount/` ./backups/$lastbackup/master.txt > diff.txt
	    # copy new files to new folder
	    val
	    # Copy not-already-existing files (base on names) to new folder
	    # create new master list in new folder
	    ls ./backups/backup-$1.$DATE
	else
		# copy all files from server to new folder
		# create new master list in new folder
	    
}

###

# restore(server)
	# if prior backup exists
		# push server.lastdate files to server
	# else	
		# display/log error
