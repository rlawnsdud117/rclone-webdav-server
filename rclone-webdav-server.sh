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
debug_flag=$""
if [[ "${debug,,}" != "off" && "$debug" != "0" && -n "$debug" ]]; then
  debug_flag=$"--log-file /data/log/log.log"
fi


# Create necessary directories if they don't exist
mkdir -p "/data/config"
mkdir -p "/data/Log"
mkdir -p "/etc/webdav"
if [[ "${cachefolder,,}" == "on" ]]; then
    mkdir -p "/data/cache"
fi

config_file=$"/data/config/rclone.conf"

# Check if rclone.conf exists and copy it if not
if [ ! -f $config_file ]; then
  if [ ! -f /root/.config/rclone/rclone.conf ]; then
    echo "rclone.conf does not exist. Please run 'rclone config' to configure it!" /bin/bash
  fi
  mkdir -p /data
  cp -f /root/.config/rclone/rclone.conf /data/config/rclone.conf
fi

# Get section name from rclone.conf
section_name=$(awk 'NR==1 { if ($0 ~ /^\[[[:alnum:] _-]+\]$/) print $0; else print "INVALID_SECTION_NAME" }' "$config_file")
if [ "$section_name" = "INVALID_SECTION_NAME" ]; then
  echo "The first line in the rclone.conf file does not contain a valid section name."  /bin/bash
  echo "Please verify the section name on the first line of the rclone.conf file."  /bin/bash
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
   $debug_flag \
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
