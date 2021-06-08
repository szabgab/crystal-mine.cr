FROM crystallang/crystal

RUN apt-get update && \
    apt-get -y install libsqlite3-dev && \
    apt-get -y install sqlite3        && \
    apt-get install -y less           && \
    apt-get install -y vim            && \
    apt-get install -y cron           && \
    rm -rf /var/lib/apt/lists/*       && \
    echo DONE


WORKDIR /opt
COPY shard.yml .
RUN shards install --ignore-crystal-version
RUN crystal build --release lib/sentry/src/sentry_cli.cr -o ./bin/sentry-docker

COPY . .
RUN crystal build --release src/webapp.cr -o ./bin/webapp
RUN crontab /opt/crontab.txt
CMD ["./bin/webapp"]
