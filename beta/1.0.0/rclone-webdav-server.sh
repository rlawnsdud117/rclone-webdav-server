#!/bin/bash

if [ -z "$1" ]; then
  username="username"
else
  username="$1"
fi

if [ -z "$2" ]; then
  password="password"
else
  password="$2"
fi
if [ -z "$3" ]; then
  bwlimit="0"
else 
  bwlimit="$3"
fi

config_file=$"/data/config/rclone.conf"
PORT=$"80"

if [ ! -f $config_file ]; then
  if [ ! -f /root/.config/rclone/rclone.conf ]; then
    echo "rclone.conf is missing. Configure it by running 'rclone config'!"
    /bin/bash
  fi
  mkdir -p /data/config
  mv /root/.config/rclone/rclone.conf /data/config/rclone.conf 2>/dev/null
fi
#/data/Log

folder_path=$"/data/Log"
if [ ! -d "$folder_path" ]; then
    mkdir -p "$folder_path"
fi

section_name=$(awk 'NR==1 { if ($0 ~ /^\[[a-zA-Z0-9_-]+\]$/) print $0; else print "INVALID_SECTION_NAME" }' "$config_file")

if [ "$section_name" = "INVALID_SECTION_NAME" ]; then
   echo "Failed to find valid section name in first line of file /data/config/rclone.conf."
   exit 1
fi

section_name=$(echo "$section_name" | sed 's/\[\(.*\)\]/\1/') 


rm -f /etc/apache2/webdav.password
echo "$username:$(openssl passwd -apr1 $password)" > /etc/apache2/webdav.password

rclone serve webdav $section_name: --port $PORT--config $config_file --htpasswd /etc/apache2/webdav.password --etag-hash auto --vfs-cache-mode full --tpslimit 10 --tpslimit-burst 10 --dir-cache-time=160h --buffer-size=64M --vfs-read-chunk-size=2M --vfs-read-chunk-size-limit=2G --vfs-cache-max-age=5m --vfs-cache-mode=writes --log-file /data/Log/log.log --bwlimit $bwlimit 2>/dev/null
/bin/bash
