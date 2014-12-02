#!/bin/bash

# Used for a regular back-up from a server to a local PC. You should run this script from the PC client that the data will be copied and NOT from the server. 
# It is advisable to have ssh without login from the client PC to the server. 
# Call like this: ./backup.sh "[project_name_[folder]]" "" "[path_in_the_sever_to_be_copied]" "[path_in_the_local_machine_that_script_will_be_executed]" "[username]@[IP]:" "[dummy_mail]" "" "" [optional_arg]
#
#
# Copyright (C) 2014 Grigorios G. Chrysos
# available under the terms of the Apache License, Version 2.0

#Backup name
if [ -n "$1" ]; then
    BACKUP_NAME=$1  # Name of backup (log file, dest dir, exclude)
else 
    exit 1
fi

# Optional hostname
if [ -n "$2" ]; then
    HOST=$2          # host
else 
    HOST=""
fi

# Source files
if [ -n "$3" ]; then 
    if [ -n "$HOST" ]; then 
        SRC=${HOST}:$3
    else 
        SRC=$3         
    fi    
else 
    exit 1
fi

# Repository location
if [ -n "$4" ]; then
    BACKUP_REPO=$4  
else 
    exit 1
fi

# Custom ssh command (like ssh -i keyfile -l remote_user)
if [ -n "$5" ]; then
    SSH_COMMAND=$5  
else 
    SSH_COMMAND=""
fi

# Email for logging
if [ -n "$6" ]; then
    EMAIL=$6        
else
    exit 1
fi

# Optional backup of mysql (need username and password)
if [ -n "$7" -a -n "$8" ]; then
    if [ -n "$HOST" -a -n "$SSH_COMMAND" ]; then
        $SSH_COMMAND $HOST "mysqldump -u '$7' -p'$8' --all-databases | gzip > ~/mysql.gz"
    else
        mysqldump -u '$7' -p'$8' --all-databases | gzip > ~/mysql.gz
    fi;
fi

# Standard variables
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" 
DST="$BACKUP_REPO$BACKUP_NAME"
EXCLUDE="$DIR/$BACKUP_NAME.exclude"
LOG="$DIR/$BACKUP_NAME.log"
RSYNC_PATH=" /usr/bin/rsync"

DATE=`date +%Y-%m-%d`   # Full date 2012-12-31
DOW=`date +%w`          # Day of the week 1 is Monday
DOM=`date +%d`          # Date of the Month e.g. 27

# Create non-existing directories
if [ ! -d "$DST/current" ]; then
    mkdir -p $DST/current
fi
if [ ! -d "$DST/Daily" ]; then
    mkdir $DST/Daily
fi
if [ ! -d "$DST/Weekly" ]; then
    mkdir $DST/Weekly
fi
if [ ! -d "$DST/Monthly" ]; then
    mkdir $DST/Monthly
fi
if [  -d "$DST/incomplete" ]; then
    rm -rf $DST/incomplete
fi

# Create empty exclusion file if it not exists
if [ ! -f "$EXCLUDE" ] ; then
    touch $EXCLUDE
fi

# Monthly full backup
if [ $DOM = "01" ]; then
        DATE_DST=$DST/Monthly/`date +%B`

# Weekly full backup
elif [ $DOW = "5" ]; then
    	DATE_DST=$DST/Weekly/$DATE

# Make incremental backup - overwrite last weeks
else
	DATE_DST=$DST/Daily/`date +%A`
fi
echo $DST
# Execute the rsync task
if [ -n "$5" ]; then
    rsync -azv  $SSH_COMMAND$SRC $DST/incomplete > $LOG 2>&1 && cat $LOG || cat $LOG #| mail -s "Rsync $BACKUP_NAME: success" $EMAIL || cat $LOG | mail -s "Rsync $BACKUP_NAME: failed" $EMAIL
else
echo $SSH_COMMAND
   rsync -e --rsh="$SSH_COMMAND" --rsync-path="$RSYNC_PATH" -az --numeric-ids --stats --human-readable --delete --exclude-from "$EXCLUDE" --delete-excluded --link-dest=$DST/current $SRC $DST/incomplete > $LOG 2>&1 && cat $LOG || cat $LOG
fi
if [ -n "$9" ]; then 				# optional arg: If provided, then saves the files in a directory based on the time
    THETIME=`date +%y%m%d_%H%M`  		# file format: %year%month%day_%time
    BY_TIME='BY_TIME'
    mkdir -p $DST/$BY_TIME
    mkdir -p $DST/$BY_TIME/$THETIME
    DATE_DST=$DST/$BY_TIME'/'$THETIME
    BT='/*'
elif [ -d "$DATE_DST" ]; then   		# Delete existing destination directory.
    rm -rf $DATE_DST
    BT=''
fi

# Move backup to destination and setup new reference directory 
mv $DST/incomplete$BT $DATE_DST
rm -rf $DST/current 
ln -s $DATE_DST $DST/current
