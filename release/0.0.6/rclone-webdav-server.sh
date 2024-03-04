#!/bin/bash

username="${1:-username}"
password="${2:-password}"
bwlimit="${3:-}"
tpslimit="${4:-}"
readonly="${5:-}"
cachefolder="${6:-}"

bwlimit_flag=$""
if [[ "${bwlimit,,}" != "off" && "$bwlimit" != "0" && -n "$bwlimit" ]]; then
  bwlimit_flag=$"--bwlimit $bwlimit"
fi

readonly_flag=$""
if [[ "${readonly,,}" == "on" ]]; then
  readonly_flag="--read-only"
fi

#/data/config 
if [ ! -d $"/data/config" ]; then
    mkdir -p "/data/config"
fi
if [ ! -d "/data/Log" ]; then
    mkdir -p "/data/Log"
fi

cachefolder_flag=$""
if [[ "${cachefolder,,}" == "on" ]]; then
    cachefolder_flag="--cache-dir /data/cache"
    if [ ! -d "/data/cache" ]; then
        mkdir -p "/data/cache"
    fi
fi  

# rclone.conf 파일이 없는 경우 생성하도록 합니다.
if [ ! -f /data/config/rclone.conf ]; then
  if [ ! -f /root/.config/rclone/rclone.conf ]; then
    echo "rclone.conf does not exist. Please run 'rclone config' to configure it!" 
    /bin/bash
  fi
  mkdir -p /data
  cp -f /root/.config/rclone/rclone.conf /data/config/rclone.conf
fi

# Process the section name
section_name=$(awk 'NR==1 { if ($0 ~ /^\[[a-zA-Z0-9 _-]+\]$/) print $0; else print "INVALID_SECTION_NAME" }' "$config_file")

if [ "$section_name" = "INVALID_SECTION_NAME" ]; then
echo "The first line in the rclone.conf file does not contain a valid section name."
/bin/bash
fi

# Remove brackets and replace spaces with underscores
section_name=$(echo "$section_name" | sed 's/\[\(.*\)\]/\1/' | tr ' ' '_')

# Update section name in the file
sed -i "1s/.*/[$section_name]/" "$config_file"


rm -f /etc/apache2/webdav.password
echo "$username:$(openssl passwd -apr1 $password)" > /etc/apache2/webdav.password

rclone serve webdav "$section_name": \
   --addr 0.0.0.0:80 \
   --config /data/config/rclone.conf \
   $cachefolder_flag \
   --log-file /data/Log/log.log \
   --htpasswd /etc/apache2/webdav.password \
   --etag-hash auto \
   --vfs-cache-mode full \
   --tpslimit $tpslimit \
   --tpslimit-burst 100 \
   --dir-cache-time 160h \
   --buffer-size 64M \
   --vfs-read-chunk-size 2M \
   --vfs-read-chunk-size-limit 2G \
   --vfs-cache-max-age 5m \
   $bwlimit_flag \
   $readonly_flag
    /bin/bash
