require "log"
require "sqlite3"


FIELDS = "id, host, user_name, repo_name, name, record_last_updated, description, version"

def get_db_file
    db_file = "data.db"
    if ENV.has_key?("MINE_DB")
        db_file =  ENV["MINE_DB"]
    end
    return db_file
end

def create_db
    db_file = get_db_file
    if File.exists?(db_file)
        Log.info { "File #{db_file} already exists." }
        return
    end
    Log.info { "Creating DB in #{db_file}." }
    DB.open "sqlite3://#{db_file}" do |db|
        db.exec "CREATE TABLE shards (
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
            )"
    end
end

def get_project(host, user_name, repo_name)
    db_file = get_db_file
    row = {} of String => String|Int32|Bool
    DB.open "sqlite3://#{db_file}" do |db|
        db.query "SELECT #{FIELDS} FROM shards WHERE host=? AND user_name=? AND repo_name=?",
            host, user_name, repo_name do |rs|
            rs.each do
                # TODO it is a loop but there should be only one result (or maybe none) how to improve?
                row = parse_row(rs)
            end
        end
    end
    return row
end

def parse_row(rs)
    row = {} of String => String|Int32|Bool
    row["id"] = rs.read(Int32)
    row["host"] = rs.read(String)
    row["user_name"] = rs.read(String)
    row["repo_name"] = rs.read(String)
    row["name"] = rs.read(String)
    row["record_last_updated"] = rs.read(String) # TODO date
    row["description"] = rs.read(String)
    row["version"] = rs.read(String)
    return row
end

def get_all()
    db_file = get_db_file
    results = [] of Hash(String, String|Int32|Bool)
    DB.open "sqlite3://#{db_file}" do |db|
        db.query "SELECT #{FIELDS} FROM shards" do |rs|
            rs.each do
                row = parse_row(rs)
                results.push(row)
            end
        end
    end
    results
end

def store_in_db(data)
    now = Time.utc

    project = get_project(data["host"], data["user_name"], data["repo_name"])

    db_file = get_db_file
    DB.open "sqlite3://#{db_file}" do |db|
        if project.has_key?("id")
            rowid = project["id"]
            Log.info { "Row ID #{rowid}" }
            res = db.exec "UPDATE shards SET
                host=?,
                user_name=?,
                repo_name=?,
                record_last_updated=?,
                name=?,
                description=?,
                version=?
                WHERE id=?",

                data["host"],
                data["user_name"],
                data["repo_name"],
                now,
                data["name"],
                data["description"],
                data["version"],
                rowid

            Log.info { "res #{res}" }
            return res.rows_affected, res.last_insert_id
        else
            Log.info { "New Row" }
            res = db.exec "INSERT INTO shards
                (host, user_name, repo_name, record_last_updated, name, description, version)
                VALUES (?, ?, ?, ?, ?, ?, ?)",
                data["host"],
                data["user_name"],
                data["repo_name"],
                now,
                data["name"],
                data["description"],
                data["version"]

            Log.info { "res #{res}" }
            return res.rows_affected, res.last_insert_id
        end
    end
end
