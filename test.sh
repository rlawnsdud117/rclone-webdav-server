#!/bin/bash

# Set default values for parameters if not provided
username="${1:-username}"
password="${2:-password}"
bwlimit="${3:-}"
tpslimit="${4:-}"
readonly="${5:-}"
cachefolder="${6:-}"

# Set flags based on provided parameters
bwlimit_flag=""
if [[ "${bwlimit,,}" != "off" && "$bwlimit" != "0" && -n "$bwlimit" ]]; then
  bwlimit_flag="--bwlimit $bwlimit"
fi

readonly_flag=""
if [[ "${readonly,,}" == "on" ]]; then
  readonly_flag="--read-only"
fi

# Create necessary directories if they don't exist
mkdir -p "/data/config"
mkdir -p "/data/Log"
mkdir -p "/etc/webdav"
if [[ "${cachefolder,,}" == "on" ]]; then
    mkdir -p "/data/cache"
fi

# Check if rclone.conf exists and copy it if not
if [ ! -f /data/config/rclone.conf ]; then
  if [ ! -f /root/.config/rclone/rclone.conf ]; then
    echo "rclone.conf does not exist. Please run 'rclone config' to configure it!" /bin/bash
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

# Generate htpasswd file
htpasswd_file="/etc/webdav/htpasswd"
echo "$username:$(openssl passwd -apr1 $password)" > "$htpasswd_file"

# Run rclone serve webdav command
rclone serve webdav "$section_name": \
   --addr 0.0.0.0:80 \
   --config "$config_file" \
   --cache-dir /data/cache \
   --log-file /data/Log/log.log \
   --htpasswd "$htpasswd_file" \
   --etag-hash auto \
   --vfs-cache-mode minimal \
   --tpslimit "$tpslimit" \
   --tpslimit-burst 100 \
   --dir-cache-time 160h \
   --buffer-size 64M \
   --vfs-read-chunk-size 2M \
   --vfs-read-chunk-size-limit 2G \
   --vfs-cache-max-age 5m \
   $bwlimit_flag \
   $readonly_flag

# Start interactive shell
/bin/bash
