FROM debian:10-slim

ARG DEBIAN_FRONTEND=noninteractive
COPY . /root/install

SHELL ["/bin/bash", "-c"]

RUN apt-get update && \
    apt-get install busybox && \
    apt-get upgrade -y -o Dpkg::Options::="--force-confold" && \
    cd /root/install && \
    sh ./install.sh && \
    ln -s /bin/busybox /bin/ifconfig && \
    ln -s /bin/busybox /bin/ping && \
    ln -s /bin/busybox /bin/route && \
    ln -s /usr/sbin/cron /usr/sbin/crond \
    rm -rf /bin/ps && ln -s /bin/busybox /bin/ps && \
    touch /etc/docker

CMD ["/etc/rc/bootup", ""]
### Networking configuration
EXPOSE 80 443 5060/udp 5060/tcp 5038 8088 8089 10000-11000/udp