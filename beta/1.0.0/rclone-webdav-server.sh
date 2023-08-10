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
  bwlimit="$3"
fi

# rclone.conf 파일이 없는 경우 생성하도록 합니다.
if [ ! -f /data/rclone.conf ]; then
  if [ ! -f /root/.config/rclone/rclone.conf ]; then
    echo "rclone.conf가 없습니다. 'rclone config'를 실행하여 구성하십시오!"
    /bin/bash
  fi
  mkdir -p /data
  mv /root/.config/rclone/rclone.conf /data/rclone.conf 2>/dev/null
fi

config_file=$"/data/rclone.conf"

    section_name=$(awk 'NR==1 { if ($0 ~ /^\[[a-zA-Z0-9_-]+\]$/) print $0; else print "INVALID_SECTION_NAME" }' "$config_file")
    if [ "$section_name" = "INVALID_SECTION_NAME" ]; then
        echo "첫 번째 줄에서 유효한 섹션 이름을 찾지 못했습니다."
        exit 1
    fi

    # [와 ] 문자 제거하여 섹션 이름만 추출
    section_name=$(echo "$section_name" | sed 's/\[\(.*\)\]/\1/') 

# Apache 웹 서버에서 WebDAV와 Basic Authentication 설정을 진행합니다.
rm -f /etc/apache2/webdav.password
echo "$username:$(openssl passwd -apr1 $password)" > /etc/apache2/webdav.password

rclone serve webdav $section_name: --addr 0.0.0.0:80 --config /data/rclone.conf --htpasswd /etc/apache2/webdav.password --etag-hash auto --vfs-cache-mode full --tpslimit 10 --tpslimit-burst 10 --dir-cache-time=160h --buffer-size=64M --vfs-read-chunk-size=2M --vfs-read-chunk-size-limit=2G --vfs-cache-max-age=5m --vfs-cache-mode=writes --bwlimit $bwlimit 2>/dev/null
/bin/bash
