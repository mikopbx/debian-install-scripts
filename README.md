# debian-install-scripts

## Полезные команды Docker
#### Запуск контейнера и назначение имени "mikopbx"
`docker run --net=host --name mikopbx -v /var/spool/mikopbx/cf:/cf -v /var/spool/mikopbx/storage:/storage -it -d --rm mikopbx:12`
`docker run --net=host --name mikopbx -v /var/spool/mikopbx/cf:/cf -v /var/spool/mikopbx/storage:/storage --device /dev/dahdi/transcode --device /dev/dahdi/channel --device /dev/dahdi/ctl --device /dev/dahdi/pseudo --device /dev/dahdi/timer -it -d --rm mikopbx:11`
#### Список запущенных контейнеров
`docker ps`
#### Завершить процесс
`docker kill mikopbx`
#### Подключиться к запущенному контейнеру
`docker exec -it mikopbx sh`
#### Все запущенные контейнеры
`docker ps -qa`
#### Удалить все контейнеры
`docker stop $(docker ps -qa)`

`docker rm $(docker ps -qa)`

#### Импорт контейнера.
docker import --change 'ENTRYPOINT ["sh", "/sbin/docker-entrypoint"]' /tmp/2021.3.1-mikopbx-generic-x86-64-linux.tar mikopbx:12

#### Удалить все процессы. 
ps | grep -v 'docker-entrypoint' | grep -v '/bin/tail -f /dev/null' | grep -v 'PID' | cut -d ' ' -f 1 | xargs kill