#!/bin/bash
#
# Alex Marcus
# Flownet : Automated Networked Backup and Restoration
# Fall 2009
# Connecticut College Computer Science 495


#### Backup method
# backup servername
backup() {
    echo "Flowout: Attempting to backup ${1}..."

    # Possible first-ever backup, attempt to create backup folder (suppressing output)
    mkdir ./backups/ 2>/dev/null
    
    # Set date as the current date in the format MM-DD-YYYY-HH:MM:SS
    date=`date +%m-%d-%Y-%T`
    
    # Set backup as desired backup location (from flownet-servers[i].conf)
    backup=/home/flownet/dummies/

    # Set backupto as location of backup folder
    backupto=./backups/backup-$1.$date
    
    # Check if prior backup folder exists
    ls ./backups/backup-$1.* 2>/dev/null
    if [ $? -eq 0 ]
    then
	# Set lastbackup as last modified backup directory
	lastbackup=`ls -t -r -1 -d ./backups/*/ | tail -n 1`

	echo "Flowout: Prior backup for ${1} exists at ${lastbackup}!"
	
	echo "Flowout: Creating new backup folder for ${1} at ${backupto}..."

	# Create server.date folder with previous backup data
        cp -rf --preserve=all $lastbackup $backupto
	
	echo "Flowout: Syncing remote data at ${1}:${backup} with previous backup..."

	# rsync previous backup directory with files in desired backup folder
	# -a = archive mode for symbolic link, devices, attributes, permissions, and ownership preservation, same as -rlptgoD (no -H)
	# -q = quiet mode, no output exept errors
	# -z = compression to reduce size of data portions
	# --delete = delete files that were removed from source
	rsync -aqz --delete $1:$backup $backupto

	if [ $? -eq 0 ] # This checks the exit code of rsync, 0 = OK
	then
	    
	    echo "Flowout: Backup of ${1}:${backup} to ${backupto} was successful!  Moving to next server..."
	    
	else

	    echo "Flowout: Backup of ${1}:${backup} to ${backupto} failed with error code ${?}!  Moving to next server..."
	fi

    else
	echo "Flowout: Prior backup for ${1} does not yet exist!  Creating backup folder ${backupto}"

	# Create backup folder
	mkdir $backupto

        # rsync to new backup directory with files in desired backup folder
	# -a = archive mode for symolic link, devices, attributes, permissions, and ownership preservation, same as -rlptgoD (no -H)
	# -q = quiet mode, no output exept errors
	# -z = compression to reduce size of data portions
	rsync -aqz $1:$backup $backupto
	
	if [ $? -eq 0 ] # This checks the exit code of rsync, 0 = OK
	then
	    
	    echo "Flowout: Backup of ${1}:${backup} to ${backupto} was successful!  Moving to next server..."
	    
	else

	    echo "Flowout: Backup of ${1}:${backup} to ${backupto} failed with error code ${?}!  Moving to next server..."
	fi

    fi
}


#### Restore method
# restore servername
restore() {
    echo "Flowout: Attempting to restore ${1}..."

    # Set restore as location of desired restore location (from flownet-servers[i].conf)
    restore=/home/flownet/dummies

    # Check if prior backup folder exists
    ls ./backups/backup-$1.* 2>/dev/null
    if [ $? -eq 0 ]
    then
	# Set lastbackup as last modified backup directory
	lastbackup=`ls -t -r -1 -d ./backups/*/ | tail -n 1`

	echo "Flowout: Prior backup for ${1} exists at ${lastbackup}!"
    
	echo "Flowout: Attempting to restore files from ${lastbackup} to remote location ${1}:${restore}..."

	# rsync previous backup directory with desired location on remote server
	# -a = archive mode for symolic link, devices, attributes, permissions, and ownership preservation, same as -rlptgoD (no -H)
	# -q = quiet mode, no output exept errors
	# -z = compression to reduce size of data portions
	rsync -aqz $lastbackup flownet@$1:$restore

	if [ $? -eq 0 ] # This checks the exit code of rsync, 0 = OK
	then
	    
	    echo "Flowout: Restore of ${1}:${restore} from ${lastbackup} was successful!  Moving to next server..."
	    
	else

	    echo "Flowout: Restore of ${1}:${backup} from ${backupto} failed with error code ${?}!  Moving to next server..."
	fi

    else

	echo "Flowout: No valid previous backup was found for ${1}!  Moving to next server..."

    fi
}



#### Main Flownet
# Get time setting (from local flownet.conf)
WAIT=1

# Get servers to check (from local flownet.conf)
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
	echo "len = ${len} i = ${i}"
	# Ping servers[i] 5 times
	echo "Flowout: Trying to ping server ${servers[$1]}"
	ping -q -c 5 ${servers[$i]}
	if [ $? -eq 0 ] # This checks the exit code of the ping command, 0 = good pings
	then
	    echo "Flowout: Server ${servers[$i]} appears to be up, attempting to download configuration file..."
	    scp flownet@${servers[$i]}:/home/flownet/flownet.conf flownet-${servers[$i]}.conf

	    # Check if scp worked and flownet-servers[i].conf exists
	    if [ $? -eq 0 ] # Again, 0 = good
	    then
		echo "Flowout: Flownet configuration file from ${servers[$i]} successfully acquired!"
	        # Set action as action switch (from flownet-servers[i].conf)
		action=restore

		# Call appropriate action function
		case $action in
		    backup)
		        echo "Flowout: Backup action is set!"
			backup ${servers[$i]}
			;;
		    restore)
			echo "Flowout: Restore action is set!"
		        restore ${servers[$i]}
			;;
		    *)
		        echo "Flowout: Invalid action switch set for ${servers[$i]}, moving to next server..."
			;;
		esac
		
		# Clean up
		rm flownet-${servers[$i]}.conf
		
		let i++

	    else
		echo "Flowout: Unable to acquire ${servers[$i]} configuration file!  Moving to next server..."
		let i++
	    fi  

	else
	    echo "Flowout: Server ${servers[$i]} isn't responding, moving to next server..."
	    let i++
	fi

    done
done

