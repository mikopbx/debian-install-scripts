# debian-install-scripts

## Быстрый старт
### Создать bridge подсеть
`docker network create mikopbx-bridge`
### Запустить контейнер
`
docker run --cap-add=NET_ADMIN \
            --network mikopbx-bridge \
            --name mikopbx \
            -v /var/spool/mikopbx/cf:/cf \
            -v /var/spool/mikopbx/storage:/storage \
            --publish 8080:80 \
            --publish 5060:5060 \
            -p 10000-10400:10000-10400 \
            -it -d --rm mikopbx:13
`

### Отправляем на github
`echo $CR_PAT | docker login ghcr.io -u USERNAME --password-stdin`
`cat /root/2021.4.2-mikopbx-generic-x86-64-linux.tar | docker import --change 'ENTRYPOINT ["sh", "/sbin/docker-entrypoint"]' --change 'LABEL org.opencontainers.image.source https://github.com/mikopbx/Core' - ghcr.io/boffart/mikopbx:2021.4.2.dev.x86-64`
`docker push ghcr.io/boffart/mikopbx:2021.4.2.dev.x86-64`

### Подключиться к запущенному контейнеру
`docker exec -it mikopbx sh`

## Полезные команды Docker

#### Запуск контейнера и назначение имени "mikopbx"
`docker run --cap-add=NET_ADMIN --net=host --name mikopbx -v /var/spool/mikopbx/cf:/cf -v /var/spool/mikopbx/storage:/storage -it -d --rm mikopbx:13`
`docker run --cap-add=NET_ADMIN --net=host --name mikopbx -v /var/spool/mikopbx/cf:/cf -v /var/spool/mikopbx/storage:/storage -it -d --rm ghcr.io/mikopbx/mikopbx-x86-64:2021.3.53-dev`
`docker run --cap-add=NET_ADMIN --net=host --name mikopbx -v /var/spool/mikopbx/cf:/cf -v /var/spool/mikopbx/storage:/storage --device /dev/dahdi/transcode --device /dev/dahdi/channel --device /dev/dahdi/ctl --device /dev/dahdi/pseudo --device /dev/dahdi/timer -it -d --rm mikopbx:11`
#### Список запущенных контейнеров
`docker ps`
#### Завершить процесс
`docker kill mikopbx`
#### Все запущенные контейнеры
`docker ps -qa`
#### Удалить все контейнеры
`docker stop $(docker ps -qa)`

`docker rm $(docker ps -qa)`

#### Импорт контейнера.
docker import --change 'ENTRYPOINT ["sh", "/sbin/docker-entrypoint"]' /tmp/2021.3.1-mikopbx-generic-x86-64-linux.tar mikopbx:13

#### Удалить все процессы. 
ps | grep -v 'docker-entrypoint' | grep -v '/bin/tail -f /dev/null' | grep -v 'PID' | cut -d ' ' -f 1 | xargs kill