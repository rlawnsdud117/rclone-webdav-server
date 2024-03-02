#!/bin/bash

# Set default values for parameters if not provided
username="${1:-username}"
password="${2:-password}"
bwlimit="${3:-}"
tpslimit="${4:-}"
readonly="${5:-}"
cachefolder="${6:-}"
debug="${7:-}"

# Set flags based on provided parameters
bwlimit_flag=""
if [[ "${bwlimit,,}" != "off" && "$bwlimit" != "0" && -n "$bwlimit" ]]; then
  bwlimit_flag="--bwlimit $bwlimit"
fi

readonly_flag=""
if [[ "${readonly,,}" == "on" ]]; then
  readonly_flag="--read-only"
fi

debug_flag=""
if [[ "${debug,,}" != "off" && "$debug" != "0" && -n "$debug" ]]; then
  debug_flag="--log-file /data/log/log.log"
fi

Log_folder="/data/Log"
etc_webdav_folder="/etc/webdav"

if [ ! -d "$Log_folder" ]; then
    mkdir -p "$Log_folder"
fi

if [ ! -d "$etc_webdav_folder" ]; then
    mkdir -p "$etc_webdav_folder"
fi

cache_flag=""
if [[ "${cachefolder,,}" == "on" ]]; then
    mkdir -p "/data/cache"
    cache_flag="--cache-dir /data/cache"
fi

config_folder="/data/config"
config_file="/data/config/rclone.conf"

# Check if rclone.conf exists and copy it if not
if [ ! -f $config_file ]; then
  if [ ! -f /root/.config/rclone/rclone.conf ]; then
    echo "rclone.conf does not exist. Please run 'rclone config' to configure it!" 
    /bin/bash
  fi
  mkdir -p "$config_folder"
  cp -f /root/.config/rclone/rclone.conf /data/config/rclone.conf
fi

# Get section name from rclone.conf
section_name=$(awk 'NR==1 { if ($0 ~ /^\[[a-zA-Z0-9 _-]+\]$/) print $0; else print "INVALID_SECTION_NAME" }' "$config_file")
if [ "$section_name" = "INVALID_SECTION_NAME" ]; then
  echo "The first line in the rclone.conf file does not contain a valid section name."
  /bin/bash 
  echo "Please verify the section name on the first line of the rclone.conf file."
  /bin/bash

else
  # Check if section name contains spaces
  if [[ "$section_name" =~ [[:space:]] ]]; then
    echo "The section name \"$section_name\" contains spaces. Please use it without spaces."
  fi
fi
section_name=$(echo "$section_name" | sed 's/\[\(.*\)\]/\1/' | tr -d ' ') 

# Generate htpasswd file
htpasswd_file="/etc/webdav/htpasswd"
echo "$username:$(openssl passwd -apr1 $password)" > "$htpasswd_file"

# Run rclone serve webdav command
rclone serve webdav "$section_name": \
   --addr 0.0.0.0:80 \
   --config "$config_file" \
   $cache_flag \
   --vfs-cache-mode writes \
   $debug_flag \
   --htpasswd "$htpasswd_file" \
   --etag-hash auto \
   --tpslimit "$tpslimit" \
   --tpslimit-burst 100 \
   --dir-cache-time 160h \
   --buffer-size 64M \
   --vfs-read-chunk-size 2M \
   --vfs-read-chunk-size-limit 2G \
   --vfs-cache-max-age 5m \
   $bwlimit_flag \
   $readonly_flag

/bin/bash
