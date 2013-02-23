#!/bin/sh

# Small backup script
# by Mikheev Rostislav <hacenator@gmail.com>
# v 2.2
#
# Seriously, I recomend you to use bacula!
#
# Read instruction in README file

action=$1

# Compress as default command
#if [ "$action" = "" ]; then
#    action="compress"
#fi

# CONFIG!
directory=$(cd `dirname $0` && pwd)
to="/var/backups" # where store backups
dformat="%d-%m-%y" # date format fo file
stamp=`date +"%s"` # current  timestamp
date=`date +"$dformat"` # current date in format 'dformat'
list=`cat $directory/list` # backup lists
store=2592000 # backup files store time in seconds (60*60*24*30)
logfile="$directory/log" # log file location
# CONFIG!

tolog()
{
    at=`date +"%d-%m-%y %H:%M:%S"`
    echo "[$at] $1" >> $logfile
    echo "[$at] $1"
}

# GO!
tolog "Run from: $directory"
tolog "Action: $action"
tolog "Today: $date"
tolog "Writien backup file to: $to/backup-$date.zip"

# Compress
if [ "$action" = "compress" ]; then
    mkdir $to/$date

    # Copy
    for dir in $list
    do
        if [ "$(ls -A $dir)" ]; then
	    tolog "Backup directory: '$dir'"
    	    cp -R $dir $to/$date
    	else
    	    tolog "Directory '$dir' is empty. Skipping"
    	fi
    done

    # Compress
    if [ "$(ls -A $to/$date)" ]; then
        cd $to
        tolog "Compress..."
        /usr/local/bin/zip -9 -r "backup-$date.zip" $date
    else
	tolog "Nothing to backup"
    fi
    tolog "Cleaning..."
    rm -r $to/$date
else
    # clean old backups
    if [ "$action" = "clean" ]; then
	files=`ls $to | grep backup`
	max=0
	for file in $files
	do
	    x=`stat -f "%m" "$to/$file"`
	    age=$(($stamp - $x))
	    tolog "File '$file' age are $age sec"
	    if [ $age -gt $store ]; then
		tolog "Delete old backup file '$file'"
		tolog `rm "$to/$file"`
	    fi
	done
    else
	# Help
	echo "What are you want to do?"
	echo "compress - to make backups"
	echo "clean - to delete old backup files. Be careful with this option!"
    fi
fi