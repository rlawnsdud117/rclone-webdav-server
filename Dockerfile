FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y curl && apt-get install -y unzip && curl https://rclone.org/install.sh | bash && apt-get install -y apache2 && rclone selfupdate --stable 

EXPOSE 80

ENV username "user"
ENV password "user"
ENV bwlimit "30m"

RUN curl -o /webdav-server.sh https://raw.githubusercontent.com/rlawnsdud117/rclone-webdav-server/main/webdav-server.sh
RUN chmod +x /webdav-server.sh

CMD /bin/bash -c '/webdav-server.sh "$username" "$password" "$bwlimit"'
