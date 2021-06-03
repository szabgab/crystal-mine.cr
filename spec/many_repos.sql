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
INSERT INTO shards VALUES(1,'github.com','amberframework','amber','2021-06-03 12:35:11.880','amber','','0.36.0',1,1,0,'0.35.0','MIT');
INSERT INTO shards VALUES(2,'github.com','ffwff','lilith','2021-06-03 12:35:16.204','','','',0,0,0,'','');
INSERT INTO shards VALUES(3,'github.com','hkalexling','Mango','2021-06-03 12:35:17.867','mango','','0.21.0',1,0,1,'0.35.1','MIT');
INSERT INTO shards VALUES(4,'github.com','iv-org','invidious','2021-06-03 12:35:19.825','invidious','','0.20.1',1,0,1,'0.36.1','AGPLv3');
INSERT INTO shards VALUES(5,'github.com','jeromegn','slang','2021-06-03 12:35:21.208','slang','','1.7.3',1,1,0,'>= 0.25.0, < 2.0.0','MIT');
INSERT INTO shards VALUES(6,'github.com','kemalcr','kemal','2021-06-03 12:35:22.259','kemal','','1.0.0',1,0,1,'>= 0.36.0','MIT');
INSERT INTO shards VALUES(7,'github.com','kostya','myhtml','2021-06-03 12:35:23.568','myhtml','','1.5.4',1,1,0,'>= 0.35.1, < 2.0.0','MIT');
INSERT INTO shards VALUES(8,'github.com','luckyframework','avram','2021-06-03 12:35:24.868','avram','','0.20.0',1,0,1,'>= 0.36.1, < 2.0.0','MIT');
INSERT INTO shards VALUES(9,'github.com','luckyframework','habitat','2021-06-03 12:35:25.998','habitat','','0.4.7',1,0,1,'>= 0.36.1, < 2.0.0','MIT');
INSERT INTO shards VALUES(10,'github.com','luckyframework','lucky','2021-06-03 12:35:27.233','lucky','','0.27.2',1,0,1,'>=0.36.1, < 2.0.0','MIT');
INSERT INTO shards VALUES(11,'github.com','luckyframework','lucky_router','2021-06-03 12:35:28.325','lucky_router','','0.4.2',1,0,1,'>= 0.36.1, < 2.0.0','MIT');
INSERT INTO shards VALUES(12,'github.com','luckyframework','lucky_task','2021-06-03 12:35:29.386','lucky_task','','0.1.0',1,0,1,'>= 0.36.1, < 2.0.0','MIT');
INSERT INTO shards VALUES(13,'github.com','luckyframework','wordsmith','2021-06-03 12:35:30.405','wordsmith','','0.2.2',1,0,1,'>= 0.35.1, < 2.0.0','MIT');
INSERT INTO shards VALUES(14,'github.com','mint-lang','mint','2021-06-03 12:35:31.721','mint','','0.13.0-devel',1,0,1,'>= 1.0.0','BSD-3-Clause');
INSERT INTO shards VALUES(15,'github.com','placeos','calendar','2021-06-03 12:35:32.863','place_calendar','','4.9.3',1,1,0,'>= 0.36.1, < 2.0.0','MIT');
INSERT INTO shards VALUES(16,'github.com','soveran','toro','2021-06-03 12:35:33.816','toro','','0.4.2',1,0,1,'>= 0.36.0 - 1.0','MIT');
INSERT INTO shards VALUES(17,'github.com','spider-gazelle','pinger','2021-06-03 12:35:34.736','pinger','','1.1.1',1,0,1,'>= 0.36.1','MIT');
INSERT INTO shards VALUES(18,'github.com','spider-gazelle','spider-gazelle','2021-06-03 12:35:35.639','spider-gazelle','','1.0.0',1,0,1,'','');
INSERT INTO shards VALUES(19,'github.com','szabgab','crystal-mine.cr','2021-06-03 12:35:36.700','Crystal Mine',replace('Experimenting with Crystal\n','\n',char(10)),'0.0.1',1,0,1,'','MIT');
INSERT INTO shards VALUES(20,'github.com','veelenga','awesome-crystal','2021-06-03 12:35:37.727','Awesome Crystal','','0.1.0',1,1,0,'','');
INSERT INTO shards VALUES(21,'github.com','watzon','octokit.cr','2021-06-03 12:35:39.559','octokit','','0.1.0',1,1,0,'>= 1.0.0','MIT');
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
INSERT INTO dependencies VALUES(1,'dependencies','github.com','amberframework','amber-router');
INSERT INTO dependencies VALUES(1,'dependencies','github.com','amberframework','cli');
INSERT INTO dependencies VALUES(1,'dependencies','github.com','elorest','compiled_license');
INSERT INTO dependencies VALUES(1,'dependencies','github.com','jeromegn','kilt');
INSERT INTO dependencies VALUES(1,'dependencies','github.com','techmagister','liquid.cr');
INSERT INTO dependencies VALUES(1,'dependencies','github.com','amberframework','micrate');
INSERT INTO dependencies VALUES(1,'dependencies','github.com','will','crystal-pg');
INSERT INTO dependencies VALUES(1,'dependencies','github.com','crystal-lang','crystal-mysql');
INSERT INTO dependencies VALUES(1,'dependencies','github.com','crystal-lang','crystal-sqlite3');
INSERT INTO dependencies VALUES(1,'dependencies','github.com','stefanwille','crystal-redis');
INSERT INTO dependencies VALUES(1,'dependencies','github.com','luckyframework','shell-table.cr');
INSERT INTO dependencies VALUES(1,'dependencies','github.com','jeromegn','slang');
INSERT INTO dependencies VALUES(1,'dependencies','github.com','phoffer','inflector.cr');
INSERT INTO dependencies VALUES(1,'dependencies','github.com','mosop','teeplate');
INSERT INTO dependencies VALUES(1,'dependencies','github.com','crystal-loot','exception_page');
INSERT INTO dependencies VALUES(1,'dependencies','github.com','crystal-lang','yaml_mapping.cr');
INSERT INTO dependencies VALUES(1,'dependencies','github.com','crystal-lang','json_mapping.cr');
INSERT INTO dependencies VALUES(1,'development_dependencies','github.com','crystal-ameba','ameba');
INSERT INTO dependencies VALUES(3,'dependencies','github.com','kemalcr','kemal');
INSERT INTO dependencies VALUES(3,'dependencies','github.com','kemalcr','kemal-session');
INSERT INTO dependencies VALUES(3,'dependencies','github.com','crystal-lang','crystal-sqlite3');
INSERT INTO dependencies VALUES(3,'dependencies','github.com','schovi','baked_file_system');
INSERT INTO dependencies VALUES(3,'dependencies','github.com','hkalexling','archive.cr');
INSERT INTO dependencies VALUES(3,'dependencies','github.com','crystal-ameba','ameba');
INSERT INTO dependencies VALUES(3,'dependencies','github.com','at-grandpa','clim');
INSERT INTO dependencies VALUES(3,'dependencies','github.com','jessedoyle','duktape.cr');
INSERT INTO dependencies VALUES(3,'dependencies','github.com','kostya','myhtml');
INSERT INTO dependencies VALUES(3,'dependencies','github.com','mamantoha','http_proxy');
INSERT INTO dependencies VALUES(3,'dependencies','github.com','hkalexling','image_size.cr');
INSERT INTO dependencies VALUES(3,'dependencies','github.com','hkalexling','koa');
INSERT INTO dependencies VALUES(3,'dependencies','github.com','epoch','tallboy');
INSERT INTO dependencies VALUES(3,'dependencies','github.com','hkalexling','mg');
INSERT INTO dependencies VALUES(3,'dependencies','github.com','hkalexling','mangadex');
INSERT INTO dependencies VALUES(4,'dependencies','github.com','will','crystal-pg');
INSERT INTO dependencies VALUES(4,'dependencies','github.com','crystal-lang','crystal-sqlite3');
INSERT INTO dependencies VALUES(4,'dependencies','github.com','kemalcr','kemal');
INSERT INTO dependencies VALUES(4,'dependencies','github.com','ysbaddaden','pool');
INSERT INTO dependencies VALUES(4,'dependencies','github.com','iv-org','protodec');
INSERT INTO dependencies VALUES(4,'dependencies','github.com','iv-org','lsquic.cr');
INSERT INTO dependencies VALUES(6,'dependencies','github.com','luislavena','radix');
INSERT INTO dependencies VALUES(6,'dependencies','github.com','jeromegn','kilt');
INSERT INTO dependencies VALUES(6,'dependencies','github.com','crystal-loot','exception_page');
INSERT INTO dependencies VALUES(6,'development_dependencies','github.com','crystal-ameba','ameba');
INSERT INTO dependencies VALUES(8,'dependencies','github.com','luckyframework','lucky_task');
INSERT INTO dependencies VALUES(8,'dependencies','github.com','will','crystal-pg');
INSERT INTO dependencies VALUES(8,'dependencies','github.com','luckyframework','habitat');
INSERT INTO dependencies VALUES(8,'dependencies','github.com','luckyframework','wordsmith');
INSERT INTO dependencies VALUES(8,'dependencies','github.com','luckyframework','dexter');
INSERT INTO dependencies VALUES(8,'dependencies','github.com','luckyframework','shell-table.cr');
INSERT INTO dependencies VALUES(8,'dependencies','github.com','luckyframework','pulsar');
INSERT INTO dependencies VALUES(8,'development_dependencies','github.com','crystal-ameba','ameba');
INSERT INTO dependencies VALUES(9,'development_dependencies','github.com','crystal-ameba','ameba');
INSERT INTO dependencies VALUES(10,'dependencies','github.com','luckyframework','lucky_task');
INSERT INTO dependencies VALUES(10,'dependencies','github.com','luckyframework','habitat');
INSERT INTO dependencies VALUES(10,'dependencies','github.com','luckyframework','wordsmith');
INSERT INTO dependencies VALUES(10,'dependencies','github.com','luckyframework','avram');
INSERT INTO dependencies VALUES(10,'dependencies','github.com','luckyframework','lucky_router');
INSERT INTO dependencies VALUES(10,'dependencies','github.com','luckyframework','shell-table.cr');
INSERT INTO dependencies VALUES(10,'dependencies','github.com','luckyframework','cry');
INSERT INTO dependencies VALUES(10,'dependencies','github.com','crystal-loot','exception_page');
INSERT INTO dependencies VALUES(10,'dependencies','github.com','luckyframework','dexter');
INSERT INTO dependencies VALUES(10,'dependencies','github.com','luckyframework','pulsar');
INSERT INTO dependencies VALUES(10,'dependencies','github.com','luckyframework','teeplate');
INSERT INTO dependencies VALUES(10,'development_dependencies','github.com','crystal-ameba','ameba');
INSERT INTO dependencies VALUES(11,'development_dependencies','github.com','crystal-ameba','ameba');
INSERT INTO dependencies VALUES(12,'development_dependencies','github.com','crystal-ameba','ameba');
INSERT INTO dependencies VALUES(13,'development_dependencies','github.com','crystal-ameba','ameba');
INSERT INTO dependencies VALUES(14,'dependencies','github.com','schovi','baked_file_system');
INSERT INTO dependencies VALUES(14,'dependencies','github.com','kemalcr','kemal');
INSERT INTO dependencies VALUES(14,'dependencies','github.com','jwaldrip','admiral.cr');
INSERT INTO dependencies VALUES(14,'dependencies','github.com','gdotdesign','cr-dotenv');
INSERT INTO dependencies VALUES(14,'dependencies','github.com','icyleaf','markd');
INSERT INTO dependencies VALUES(14,'development_dependencies','github.com','crystal-ameba','ameba');
INSERT INTO dependencies VALUES(15,'dependencies','github.com','placeos','office365');
INSERT INTO dependencies VALUES(15,'dependencies','github.com','placeos','google');
INSERT INTO dependencies VALUES(15,'dependencies','github.com','arcage','crystal-email');
INSERT INTO dependencies VALUES(15,'development_dependencies','github.com','spoved','vcr.cr');
INSERT INTO dependencies VALUES(16,'dependencies','github.com','soveran','seg');
INSERT INTO dependencies VALUES(16,'development_dependencies','github.com','emancu','crotest');
INSERT INTO dependencies VALUES(17,'development_dependencies','github.com','veelenga','ameba');
INSERT INTO dependencies VALUES(18,'dependencies','github.com','spider-gazelle','action-controller');
INSERT INTO dependencies VALUES(18,'dependencies','github.com','spider-gazelle','active-model');
INSERT INTO dependencies VALUES(18,'dependencies','github.com','crystal-community','future.cr');
INSERT INTO dependencies VALUES(18,'dependencies','github.com','place-labs','secrets-env');
INSERT INTO dependencies VALUES(18,'dependencies','github.com','jeromegn','kilt');
INSERT INTO dependencies VALUES(18,'development_dependencies','github.com','veelenga','ameba');
INSERT INTO dependencies VALUES(19,'dependencies','github.com','watzon','octokit.cr');
INSERT INTO dependencies VALUES(19,'dependencies','github.com','crystal-lang','crystal-sqlite3');
INSERT INTO dependencies VALUES(19,'dependencies','github.com','kemalcr','kemal');
INSERT INTO dependencies VALUES(19,'dependencies','github.com','kemalcr','spec-kemal');
INSERT INTO dependencies VALUES(19,'dependencies','github.com','crystal-lang','shards');
INSERT INTO dependencies VALUES(19,'development_dependencies','github.com','crystal-ameba','ameba');
INSERT INTO dependencies VALUES(19,'development_dependencies','github.com','samueleaton','sentry');
INSERT INTO dependencies VALUES(20,'development_dependencies','github.com','icyleaf','markd');
INSERT INTO dependencies VALUES(21,'dependencies','github.com','crystal-lang','json_mapping.cr');
INSERT INTO dependencies VALUES(21,'dependencies','github.com','icyleaf','halite');
INSERT INTO dependencies VALUES(21,'development_dependencies','github.com','manastech','webmock.cr');
INSERT INTO dependencies VALUES(21,'development_dependencies','github.com','vonkingsley','hi8.cr');
CREATE TABLE contributors (
            id INTEGER PRIMARY KEY,
            name TEXT,
            email TEXT,
            UNIQUE (email)
            );
COMMIT;
