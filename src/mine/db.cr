require "log"
require "sqlite3"

def get_db_file
    db_file = "data.db"
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

# def get_id()
#     DB.open "sqlite3://#{db_file}" do |db|
#     rowid = nil
#     db.query "SELECT id FROM shards WHERE host=? AND user_name=? AND repo_name=?",
#         data["host"], data["user_name"], data["repo_name"] do |rs|
#         rs.each do
#             rowid = rs.read(Int32)
#         end
#     end
#     return rowid
# end

def store_in_db(data)
    now = Time.utc

    #res = nil
    db_file = get_db_file
    DB.open "sqlite3://#{db_file}" do |db|
        rowid = nil
        db.query "SELECT id FROM shards WHERE host=? AND user_name=? AND repo_name=?",
            data["host"], data["user_name"], data["repo_name"] do |rs|
            rs.each do
                rowid = rs.read(Int32)
            end
        end

        Log.info { "Row ID #{rowid}" }
        if rowid.nil?
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
                return res.rows_affected, res.last_insert_id
        else
            res = db.exec "UPDATE shards SET
                host=?,
                user_name=?,
                repo_name=?,
                record_last_updated=?,
                name=?,
                description=?,
                version=?
                WHERE id=?
            ",
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
        end
    end
end
