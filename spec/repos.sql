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
INSERT INTO shards VALUES(1,'github.com','szabgab','crystal-mine.cr','2021-06-03 12:35:00.283','Crystal Mine',replace('Experimenting with Crystal\n','\n',char(10)),'0.0.1',1,0,1,'','MIT');
INSERT INTO shards VALUES(2,'github.com','luckyframework','lucky','2021-06-03 12:35:01.518','lucky','','0.27.2',1,0,1,'>=0.36.1, < 2.0.0','MIT');
INSERT INTO shards VALUES(3,'github.com','soveran','toro','2021-06-03 12:35:02.707','toro','','0.4.2',1,0,1,'>= 0.36.0 - 1.0','MIT');
INSERT INTO shards VALUES(4,'github.com','watzon','octokit.cr','2021-06-03 12:35:06.451','octokit','','0.1.0',1,1,0,'>= 1.0.0','MIT');
CREATE TABLE authors (
            id INTEGER PRIMARY KEY,
            name TEXT,
            email TEXT,
            UNIQUE (email)
            );
CREATE TABLE author_of_shard (
            shards_id INTEGER,
            authors_id INTEGER,
            FOREIGN KEY(shards_id) REFERENCES shards(id),
            FOREIGN KEY(authors_id) REFERENCES authors(id),
            UNIQUE (shards_id, authors_id)
            );
CREATE TABLE dependencies (
            shards_id INTEGER,
            dependency_type TEXT,
            host TEXT,
            user_name TEXT,
            repo_name TEXT,
            FOREIGN KEY(shards_id) REFERENCES shards(id)
            );
INSERT INTO dependencies VALUES(1,'dependencies','github.com','watzon','octokit.cr');
INSERT INTO dependencies VALUES(1,'dependencies','github.com','crystal-lang','crystal-sqlite3');
INSERT INTO dependencies VALUES(1,'dependencies','github.com','kemalcr','kemal');
INSERT INTO dependencies VALUES(1,'dependencies','github.com','kemalcr','spec-kemal');
INSERT INTO dependencies VALUES(1,'dependencies','github.com','crystal-lang','shards');
INSERT INTO dependencies VALUES(1,'development_dependencies','github.com','crystal-ameba','ameba');
INSERT INTO dependencies VALUES(1,'development_dependencies','github.com','samueleaton','sentry');
INSERT INTO dependencies VALUES(2,'dependencies','github.com','luckyframework','lucky_task');
INSERT INTO dependencies VALUES(2,'dependencies','github.com','luckyframework','habitat');
INSERT INTO dependencies VALUES(2,'dependencies','github.com','luckyframework','wordsmith');
INSERT INTO dependencies VALUES(2,'dependencies','github.com','luckyframework','avram');
INSERT INTO dependencies VALUES(2,'dependencies','github.com','luckyframework','lucky_router');
INSERT INTO dependencies VALUES(2,'dependencies','github.com','luckyframework','shell-table.cr');
INSERT INTO dependencies VALUES(2,'dependencies','github.com','luckyframework','cry');
INSERT INTO dependencies VALUES(2,'dependencies','github.com','crystal-loot','exception_page');
INSERT INTO dependencies VALUES(2,'dependencies','github.com','luckyframework','dexter');
INSERT INTO dependencies VALUES(2,'dependencies','github.com','luckyframework','pulsar');
INSERT INTO dependencies VALUES(2,'dependencies','github.com','luckyframework','teeplate');
INSERT INTO dependencies VALUES(2,'development_dependencies','github.com','crystal-ameba','ameba');
INSERT INTO dependencies VALUES(3,'dependencies','github.com','soveran','seg');
INSERT INTO dependencies VALUES(3,'development_dependencies','github.com','emancu','crotest');
INSERT INTO dependencies VALUES(4,'dependencies','github.com','crystal-lang','json_mapping.cr');
INSERT INTO dependencies VALUES(4,'dependencies','github.com','icyleaf','halite');
INSERT INTO dependencies VALUES(4,'development_dependencies','github.com','manastech','webmock.cr');
INSERT INTO dependencies VALUES(4,'development_dependencies','github.com','vonkingsley','hi8.cr');
CREATE TABLE contributors (
            id INTEGER PRIMARY KEY,
            name TEXT,
            email TEXT,
            UNIQUE (email)
            );
COMMIT;
