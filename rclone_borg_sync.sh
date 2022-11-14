#!/bin/bash
set -e
date=$(date '+%Y-%m-%d-%H_%M_%S')

repos=("rpool/ROOT/pve-1" "storage/file_cabinet" "storage/keepsake" "storage/keepsake2" "storage/mikesclassicads" "backup/timemachine")

bwlimit=16192k

logfile=/var/log/rclone-$date.log

#Bail if rclone is already running, maybe previous run didn't finish
if pidof -x rclone >/dev/null; then
    echo "Process already running"
    # exit
fi

for i in "${repos[@]}"
do
    #Lets see how much space is used by directory to back up
    #if directory is gone, or has gotten small, we will exit
    space=`du -s /backup/borg/$i|awk '{print $1}'`

    if (( $space < 4500 )); then
       echo "not enough space used in $i ($space) - skipping!"
    else
       echo "==================== syncing $i"
    sudo /usr/bin/rclone --config /home/mike/.config/rclone/rclone.conf --bwlimit=$bwlimit -vvv sync /backup/borg/$i b2:mds-borgbackup/$i 2>&1 | sudo tee $logfile
    fi

done

date=$(date '+%Y-%m-%d-%H_%M_%S')

/usr/bin/rclone --config /home/mike/.config/rclone/rclone.conf -vvv sync /backup/proxmox_backup_server/ 2>&1 | tee -a /var/log/pbs-$date.log
