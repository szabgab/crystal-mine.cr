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

COPY . .
RUN crontab /opt/crontab.txt
CMD ["crystal", "run", "src/webapp.cr"]