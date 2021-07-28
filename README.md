# debian-install-scripts

## Полезные команды Docker
#### Запуск контейнера и назначение имени "mikopbx"
`docker run --net=host --name mikopbx -it -d --rm mikopbx:2`
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