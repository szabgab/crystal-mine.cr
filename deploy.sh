#!/usr/bin/bash
export PATH=$PATH:/home/gabor/docker-compose/bin

git pull
docker run --rm -it -v$(pwd):/opt --workdir=/opt node:14.15 bash generate_bulma.sh
docker-compose build
docker-compose stop --time 0
docker-compose up --detach --time 0 --remove-orphans
docker image prune -f
