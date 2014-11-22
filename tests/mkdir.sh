#!/bin/sh
echo "test1"
echo "Date: `date +%F`"
echo "test1b"
DATE="`date +%F`"
echo "test2"
echo "./backups/backup-$1.$DATE"
echo "test3"
mkdir ./backups/backup-$1.$DATE
