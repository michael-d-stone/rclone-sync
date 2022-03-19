#!/bin/bash
set -e
repos=( lb pihole proxmox proxmox-b proxmox-c home )

#Bail if rclone is already running, maybe previous run didn't finish
if pidof -x rclone >/dev/null; then
    echo "Process already running"
    # exit
fi

for i in "${repos[@]}"
do
    #Lets see how much space is used by directory to back up
    #if directory is gone, or has gotten small, we will exit
    space=`du -s /tank/backups/borg/$i|awk '{print $1}'`

    if (( $space < 4500 )); then
       echo "not enough space used in $i ($space) - skipping!"
    else
       echo "==================== syncing $i"
       /usr/bin/rclone --config /root/.config/rclone/rclone.conf -v sync /tank/backups/borg/$i b2-borg:/billimek-borg/$i
    fi

done

echo "==================== syncing RESTIC backups"
restic_repos=( default monitoring )
for i in "${restic_repos[@]}"
do
  echo "==================== syncing $i"
  /usr/bin/rclone --config /root/.config/rclone/rclone.conf -v sync /tank/data/minio/velero/restic/$i b2-restic:/billimek-restic/restic/$i
done