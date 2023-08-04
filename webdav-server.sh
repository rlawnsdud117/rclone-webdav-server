#!/bin/bash

# bwlimit, username, password 환경 변수가 비어있을 경우 기본 값으로 설정합니다.
if [ -z "$1" ]; then
  bwlimit="1P"
else
  bwlimit="$1"
fi

if [ -z "$2" ]; then
  username="kamilake"
else
  username="$2"
fi

if [ -z "$3" ]; then
  password="kamilake"
else
  password="$3"
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

# Apache 웹 서버에서 WebDAV와 Basic Authentication 설정을 진행합니다.
rm -f /etc/apache2/webdav.password
echo "$username:$(openssl passwd -apr1 $password)" > /etc/apache2/webdav.password

# Apache2 웹 서버를 시작합니다.
apache2ctl -D FOREGROUND
