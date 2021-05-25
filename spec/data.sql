PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE shards (
            id INTEGER PRIMARY KEY,
            host TEXT,
            user_name TEXT,
            repo_name TEXT,
            record_last_updated DATETIME,
            name TEXT,
            description TEXT,
            version TEXT,
            shard_yml BOOL,
            travis_ci BOOL,
            github_actions BOOL,
            crystal TEXT,
            license TEXT,
            UNIQUE (host, user_name, repo_name)
            );
INSERT INTO shards VALUES(1,'github.com','szabgab','crystal-mine.cr','2021-05-25 14:59:16.972','Crystal Mine',replace('Experimenting with Crystal\n','\n',char(10)),'0.0.1',1,0,1,'','MIT');
INSERT INTO shards VALUES(2,'github.com','luckyframework','lucky','2021-05-25 14:59:18.172','lucky','','0.27.2',1,0,1,'>=0.36.1, < 2.0.0','MIT');
INSERT INTO shards VALUES(3,'github.com','soveran','toro','2021-05-25 14:59:19.160','toro','','0.4.2',1,0,1,'>= 0.36.0 - 1.0','MIT');
INSERT INTO shards VALUES(4,'github.com','watzon','octokit.cr','2021-05-25 14:59:21.176','octokit','','0.1.0',1,1,0,'>= 1.0.0','MIT');
CREATE TABLE authors (
            id INTEGER PRIMARY KEY,
            name TEXT,
            email TEXT,
            UNIQUE (email)
            );
CREATE TABLE author_of_shard (
            shards_id INTEGER,
            authors_id INTEGER,
            UNIQUE (shards_id, authors_id)
        );
COMMIT;
