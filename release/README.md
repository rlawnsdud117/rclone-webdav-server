# Update History for the Rclone WebDAV Server Script
Unless serious bugs/errors arise in my script, it is highly likely that version 0.0.4 will be the final release.
## Version 0.0.1 has been released.
1. I have added a log file.
2. The configuration location has been changed.
## Version 0.0.2 has been released.
1. Instead of moving the rclone.conf file, I've added a script command to copy the file from /data/config/rclone.conf.
## Version 0.0.3 has been released.
1. Reading mode has been added.
## Version 0.0.4 has been released.
1. I've added a feature (cachefolder) to enable or disable the upload and download cache folder.
2. The issue where the file transfer rate limit (tpslimit) wasn't functioning has been resolved.
3. The problem where the speed limit (bwlimit) wasn't working when it was off, empty, or set to 0 has been fixed.
