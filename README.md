# debian-install-scripts

## Полезные команды Docker
#### Запуск контейнера и назначение имени "mikopbx"
`docker run --net=host --name mikopbx -it -d --rm mikopbx:7`
`docker run --net=host --name mikopbx --device /dev/dahdi/transcode --device /dev/dahdi/channel --device /dev/dahdi/ctl --device /dev/dahdi/pseudo --device /dev/dahdi/timer -it -d --rm mikopbx:11 entrypoint`
#### Список запущенных контейнеров
`docker ps`
#### Завершить процесс
`docker kill NAMES-OR-ID`
#### Подключиться к запущенному контейнеру
`docker exec -it NAMES-OR-ID bash`
`docker exec -it mikopbx bash`

#### Все запущенные контейнеры
`docker ps -qa`

#### Удалить все контейнеры
`docker stop $(docker ps -qa)`

`docker rm $(docker ps -qa)`

###
ln -s /storage/usbdisk1/mikopbx/custom_modules/ModuleDocker/bin/docker /bin/docker

tar --exclude storage \
    --exclude proc \
    --exclude sys \
    --exclude var/run \
    --exclude var/asterisk \
    --exclude dev \
    -c /  \
    | /storage/usbdisk1/mikopbx/custom_modules/ModuleDocker/bin/docker import - exampleimagedir