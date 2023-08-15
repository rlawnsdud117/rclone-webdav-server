FROM debian:bullseye-slim

ARG DEBIAN_FRONTEND=noninteractive

# 환경 변수를 설정합니다.
ENV username "user"
ENV password "user"
ENV bwlimit "30m"
ENV LANG=ko_KR.UTF-8

# 필요한 패키지들을 설치합니다.
RUN apt-get update && \
    apt-get install -y curl unzip apache2 locales && \
    curl https://rclone.org/install.sh | bash && \
    curl -o /webdav-server.sh https://raw.githubusercontent.com/rlawnsdud117/rclone-webdav-server/main/webdav-server.sh && \
    chmod +x /webdav-server.sh && \
    localedef -f UTF-8 -i ko_KR ko_KR.UTF-8 && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean
    
EXPOSE 80


CMD /webdav-server.sh "$username" "$password" "$bwlimit"

