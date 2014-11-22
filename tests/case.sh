#!/bin/sh

echo "Please talk to me..."
while :
do
	read INPUT
	case $INPUT in
		hello)
			clear
			echo "Hello yourself!"
			vim ../flownet.sh
			;;
		bye)
			echo "See you later!"
			break
			;;
		*)
			echo "Huh?  What was that?"
			clear
			;;
	esac
done
echo
echo "That's it!"
