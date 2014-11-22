#!/bin/bash

# Get time setting (from conf)
WAIT=1

# Get current host name (from conf)
HOST=localhost

# Get creation destination (from conf)
DEST=./dummies/

# Initialize creation destination
rm -rf $DEST
mkdir $DEST

# Set file counter to 0 to start
COUNT=0

# Loop this script forever
while [ 1 ]
do
        # Count up to WAIT, execute file creation
	WAITCOUNT=0
	while [ "$WAITCOUNT" != $WAIT ]
	do
		sleep 1
		let WAITCOUNT++
	done

	# Set filename as destination/dummy_hostname_count
	NEWFILE="${DEST}dummy_${HOST}_${COUNT}"
	$ Set filesize as random number from 1 to 1000
	NEWSIZE=`echo $RANDOM%1000 + 1 | bc`

	echo "Attempting to create file ${NEWFILE} of size ${NEWSIZE}"
	
	# File creation
	dd if=/dev/zero of=$NEWFILE bs=$NEWSIZE count=1
	# Increment file counter
	let COUNT++
done
