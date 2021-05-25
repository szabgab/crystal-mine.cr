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
            UNIQUE (host, user_name, repo_name)
            );
INSERT INTO shards VALUES(1,'github.com','szabgab','crystal-mine.cr','2021-05-25 11:38:41.682','Crystal Mine',replace('Experimenting with Crystal\n','\n',char(10)),'0.0.1',1,0,1);
INSERT INTO shards VALUES(2,'github.com','watzon','octokit.cr','2021-05-25 11:38:43.660','octokit','','0.1.0',1,1,0);
INSERT INTO shards VALUES(3,'github.com','luckyframework','lucky','2021-05-25 11:38:44.985','lucky','','0.27.2',1,0,1);
INSERT INTO shards VALUES(4,'github.com','soveran','toro','2021-05-25 11:38:45.871','toro','','0.4.2',1,0,1);
COMMIT;
