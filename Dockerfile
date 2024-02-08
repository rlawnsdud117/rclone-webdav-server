FROM ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive

ENV username "user"
ENV password "user"
ENV bwlimit "100m"
ENV tpslimit "10"
ENV readonly "off"
ENV cachefolder "off"
ENV LANG=ko_KR.UTF-8

RUN apt-get update && \
    apt-get install -y curl unzip openssl locales && \
    curl https://rclone.org/install.sh | bash && \
    curl -o /webdav-server.sh https://raw.githubusercontent.com/rlawnsdud117/rclone-webdav-server/main/rclone-webdav-server.sh && \
    chmod +x /webdav-server.sh && \
    localedef -f UTF-8 -i ko_KR ko_KR.UTF-8 && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

EXPOSE 80

CMD /webdav-server.sh $username $password $bwlimit $tpslimit $readonly $cachefolder
