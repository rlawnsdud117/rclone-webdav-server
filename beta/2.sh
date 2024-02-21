#!/bin/bash
bwlimit="${1:-}"
tpslimit="${2:-}"
readonly="${3:-}"
cachefolder="${4:-}"
readonly="${5:-}"
debug="${6:-}"

bwlimit_flag=$""
if [[ "${bwlimit,,}" != "off" && "$bwlimit" != "0" && -n "$bwlimit" ]]; then
  bwlimit_flag=$"--bwlimit $bwlimit"
fi

tpslimit_flag=$""
if [[ "${tpslimit,,}" != "off" && "$tpslimit" != "0" && -n "$tpslimit" ]]; then
  tpslimit_flag=$"--tpslimit $tpslimit"
fi

cachefolder_flag=$""
if [[ "${cachefolder,,}" == "on" ]]; then
    cachefolder_flag="--cache-dir /data/cache"
    if [ ! -d "/data/cache" ]; then
        mkdir -p "/data/cache"
    fi
fi  

readonly_flag=$""
if [[ "${readonly,,}" == "on" ]]; then
  readonly_flag=$"--read-only"
fi

debug_flag=$""
if [[ "${debug,,}" != "off" && "$debug" != "0" && -n "$debug" ]]; then
  debug_flag=$"--log-file /data/log/log.log"
fi

#/data/config 
if [ ! -d "/data/config" ]; then
    mkdir -p "/data/config"
fi
if [ ! -d "/data/Log" ]; then
    mkdir -p "/data/Log"
fi


if [ ! -f /data/config/rclone.conf ]; then
  if [ ! -f /root/.config/rclone/rclone.conf ]; then
    echo "rclone config file not found. Please run 'rclone config' to set it up!!"
    /bin/bash
  fi
  mkdir -p /data
  cp -f /root/.config/rclone/rclone.conf /data/config/rclone.conf
fi

# Get section name from rclone.conf
config_file="/data/config/rclone.conf"
section_name=$(awk 'NR==1 { if ($0 ~ /^\[[a-zA-Z0-9_-]+\]$/) print $0; else print "INVALID_SECTION_NAME" }' "$config_file")
if [ "$section_name" = "INVALID_SECTION_NAME" ]; then
  echo "Unable to find a valid section name in the first line."  /bin/bash
fi
section_name=$(echo "$section_name" | sed 's/\[\(.*\)\]/\1/') 

mkdir -p "/etc/webdav"
htpasswd_file=$"/etc/webdav/htpasswd"

for user_info in $USERS; do
    username=$(echo "$user_info" | cut -d: -f1)
    password=$(echo "$user_info" | cut -d: -f2)
    echo "$username:$(openssl passwd -apr1 $password)" >> "$htpasswd_file"
done

rclone serve webdav $section_name: \
   --addr 0.0.0.0:80 \
   --config $config_file \
   $cachefolder_flag \
   $debug_flag \
   --htpasswd $htpasswd_file \
   --vfs-cache-mode full \
   --etag-hash auto \
   $tpslimit_flag \
   --tpslimit-burst 100 \
   --dir-cache-time 160h \
   --buffer-size 64M \
   --vfs-read-chunk-size 2M \
   --vfs-read-chunk-size-limit 2G \
   --vfs-cache-max-age 5m \
   $bwlimit_flag \
   $readonly_flag
