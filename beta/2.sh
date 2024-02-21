#!/bin/bash
bwlimit="${1:-}"
tpslimit="${2:-}"
readonly="${3:-}"
cachefolder="${4:-}"
path="${4:-}"

debug_flag=""
if [[ "${debug,,}" != "off" && "$debug" != "0" && -n "$debug" ]]; then
  debug_flag="--log-file /data/log/log.log"
fi

bwlimit_flag=""
if [[ "${bwlimit,,}" != "off" && "$bwlimit" != "0" && -n "$bwlimit" ]]; then
  bwlimit_flag="--bwlimit $bwlimit"
fi

tpslimit_flag=""
if [[ "${tpslimit,,}" != "off" && "$tpslimit" != "0" && -n "$tpslimit" ]]; then
  tpslimit_flag="--tpslimit $tpslimit"
fi

path_flag=""
if [[ "${path,,}" != "off" && "$path" != "0" && -n "$path" ]]; then
  path_flag="$path"
fi

readonly_flag=""
if [[ "${readonly,,}" == "on" ]]; then
  readonly_flag="--read-only"
fi

#/data/config 
if [ ! -d "/data/config" ]; then
    mkdir -p "/data/config"
fi
if [ ! -d "/data/Log" ]; then
    mkdir -p "/data/Log"
fi

cachefolder_flag=""
if [[ "${cachefolder,,}" == "on" ]]; then
    cachefolder_flag="--cache-dir /data/cache"
    if [ ! -d "/data/cache" ]; then
        mkdir -p "/data/cache"
    fi
fi  

# rclone.conf 파일이 없는 경우 생성하도록 합니다.
if [ ! -f /data/config/rclone.conf ]; then
  if [ ! -f /root/.config/rclone/rclone.conf ]; then
    echo "rclone.conf가 없습니다. 'rclone config'를 실행하여 구성하십시오!"
    /bin/bash
  fi
  mkdir -p /data
  cp -f /root/.config/rclone/rclone.conf /data/config/rclone.conf
fi

config_file="/data/config/rclone.conf"
section_name=$(awk 'NR==1 { if ($0 ~ /^\[[a-zA-Z0-9_-]+\]$/) print $0; else print "INVALID_SECTION_NAME" }' "$config_file")
if [ "$section_name" = "INVALID_SECTION_NAME" ]; then
  echo "Unable to find a valid section name in the first line.."
  /bin/bash
fi
  
# [와 ] 문자 제거하여 섹션 이름만 추출
section_name=$(echo "$section_name" | sed 's/\[\(.*\)\]/\1/') 

section_name_with_path=""
if [ -z "$pach" ] || [ "$pach" = "off" ]; then
    section_name_with_path="$section_name"
else
    section_name_with_path="${section_name}/$pach"
fi


mkdir -p "/etc/webdav"
htpasswd_flag="/etc/webdav/htpasswd1"

for user_info in $USERS; do
    username=$(echo "$user_info" | cut -d: -f1)
    password=$(echo "$user_info" | cut -d: -f2)
    echo "$username:$(openssl passwd -apr1 $password)" >> "$htpasswd_flag"
done

rclone serve webdav "$section_name_with_path": \
   --addr 0.0.0.0:80 \
   --config /data/config/rclone.conf \
   $cachefolder_flag \
   $debug_flag \
   --htpasswd "$htpasswd_flag" \
   --etag-hash auto \
   --vfs-cache-mode full \
   $tpslimit_flag \
   --tpslimit-burst 100 \
   --dir-cache-time 160h \
   --buffer-size 64M \
   --vfs-read-chunk-size 2M \
   --vfs-read-chunk-size-limit 2G \
   --vfs-cache-max-age 5m \
   $bwlimit_flag \
   $readonly_flag
/bin/bash
