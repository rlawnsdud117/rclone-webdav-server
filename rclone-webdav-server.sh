#!/bin/bash

username="${1:-username}"
password="${2:-password}"
bwlimit="${3:-0}"
tpslimit="${4:-0}"
readonly="${5:-off}"
cachefolder="${6:-off}"

bwlimit_flag=$""
if [[ "$bwlimit" != "0" ]]; then
  bwlimit_flag=$"--bwlimit $bwlimit"
fi

readonly_flag=$""
if [[ "$readonly,," == "on" ]]; then
  readonly_flag=$"--read-only"
fi

#/data/config 
if [ ! -d $"/data/config" ]; then
    mkdir -p "/data/config"
fi
if [ ! -d "/data/Log" ]; then
    mkdir -p "/data/Log"
fi

cachefolder_flag=$""
if [[ "${cachefolder,}" == "on" ]]; then
    cachefolder_flag=$"-cache-dir /data/cache"
    if [ ! -d "/data/cache" ]; then
        mkdir -p "/data/cache"
    fi
fi  

# 대소문자 구별하여 출력
echo "cachefolder 값은 $cachefolder 입니다."

# rclone.conf 파일이 없는 경우 생성하도록 합니다.
if [ ! -f /data/config/rclone.conf ]; then
  if [ ! -f /root/.config/rclone/rclone.conf ]; then
    echo "rclone.conf가 없습니다. 'rclone config'를 실행하여 구성하십시오!"
    /bin/bash
  fi
  mkdir -p /data
  cp -f /root/.config/rclone/rclone.conf /data/config/rclone.conf
fi

config_file=$"/data/config/rclone.conf"
section_name=$(awk 'NR==1 { if ($0 ~ /^\[[a-zA-Z0-9_-]+\]$/) print $0; else print "INVALID_SECTION_NAME" }' "$config_file")
if [ "$section_name" = "INVALID_SECTION_NAME" ]; then
  echo "Unable to find a valid section name in the first line.."
  exit 1
fi
  
# [와 ] 문자 제거하여 섹션 이름만 추출
section_name=$(echo "$section_name" | sed 's/\[\(.*\)\]/\1/') 


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
   --tpslimit-burst 10 \
   --dir-cache-time 160h \
   --buffer-size 64M \
   --vfs-read-chunk-size 2M \
   --vfs-read-chunk-size-limit 2G \
   --vfs-cache-max-age 5m \
   $bwlimit_flag \
   $readonly_flag
