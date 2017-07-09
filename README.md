Based on:

- https://github.com/marcan/takeover.sh
- https://habrahabr.ru/post/321696/

How to use those scripts

Create image using build-rescue-image.sh and upload it to the http server reachable from the system that should be rescued.
Run 
```
start-rescue-system.sh http://rescue.image/url user@host
```
to setup rescue system
Login to the rescue system:
```
ssh -p 11122 root@host
```
password is defined in the build-rescue-image.sh
