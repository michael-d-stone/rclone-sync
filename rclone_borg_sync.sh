#!/bin/bash
set -e
repos=( rpool/ROOT/pve-1 backup/proxmox-backup-server tank/file-cabinet tank/keepsake tank/keepsake2 tank/mikesclassicads tank/pbs tank/personal tank/testing tank/timemachine )
bwlimit=1024k
/backup/borg/backup/proxmox-backup-server/

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
       /usr/bin/rclone --config /home/mike/.config/rclone/rclone.conf -vvv sync --dry-run /backup/borg/$i b2:mds-borgbackup/$i
    fi

done

#echo "==================== syncing RESTIC backups"
#restic_repos=( default monitoring )
#for i in "${restic_repos[@]}"
#do
#  echo "==================== syncing $i"
#  /usr/bin/rclone --config /root/.config/rclone/rclone.conf -v sync /tank/data/minio/velero/restic/$i b2-restic:/billimek-restic/restic/$i
#done
