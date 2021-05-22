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
            github_actions_ci BOOL,
            UNIQUE (host, user_name, repo_name)
            );
INSERT INTO shards VALUES(1,'github.com','szabgab','crystal-mine.cr','2021-05-21 14:14:55.042','Crystal Mine',replace('Experimenting with Crystal\n','\n',char(10)),'0.0.1',NULL,NULL,NULL);
INSERT INTO shards VALUES(2,'github.com','watzon','octokit.cr','2021-05-21 14:14:56.884','octokit','','0.1.0',NULL,NULL,NULL);
INSERT INTO shards VALUES(3,'github.com','luckyframework','lucky','2021-05-21 14:14:58.010','lucky','','0.27.2',NULL,NULL,NULL);
INSERT INTO shards VALUES(4,'github.com','soveran','toro','2021-05-21 14:14:58.883','toro','','0.4.2',NULL,NULL,NULL);
COMMIT;
