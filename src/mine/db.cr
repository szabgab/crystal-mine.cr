require "sqlite3"

FIELDS = "id, host, user_name, repo_name, name, record_last_updated, description, version, shard_yml, travis_ci, github_actions, crystal, license"

def get_db_file : String
    db_file = "data.db"
    if ENV.has_key?("MINE_DB")
        db_file =  ENV["MINE_DB"]
    end
    Log.info { "DB file: #{db_file}" }
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
            github_actions BOOL,
            crystal TEXT,
            license TEXT,
            UNIQUE (host, user_name, repo_name)
            )"


        # There is going to be a lot of overlap among owners, authros, and contributors, but for each group we'll
        # have very different details so we have three separate tables to hold them.

        # owners are the the owners of the repositories (eg. in case of  github.com/foobar/project it is foobar)
        # each shard has a single owner.

        # "authors" are the people listed in the shard.uml file as authors
        # each shard can have multiple authors
        db.exec "CREATE TABLE authors (
            id INTEGER PRIMARY KEY,
            name TEXT,
            email TEXT,
            UNIQUE (email)
            )"
        db.exec "CREATE TABLE author_of_shard (
            shards_id INTEGER,
            authors_id INTEGER,
            FOREIGN KEY(shards_id) REFERENCES shards(id),
            FOREIGN KEY(authors_id) REFERENCES authors(id),
            UNIQUE (shards_id, authors_id)
            )"
        db.exec "CREATE TABLE dependencies (
            shards_id INTEGER,
            dependency_type TEXT,
            host TEXT,
            user_name TEXT,
            repo_name TEXT,
            FOREIGN KEY(shards_id) REFERENCES shards(id)
            )"

        # "contributors" are people who can be extracted from the commit informations
        # each shard can have multiple contributors
        db.exec "CREATE TABLE contributors (
            id INTEGER PRIMARY KEY,
            name TEXT,
            email TEXT,
            UNIQUE (email)
            )"
    end
end

class Shard
    include JSON::Serializable
    def_equals @id, @host, @user_name, @repo_name, @travis_ci, @github_actions, @shard_yml, @name, @description, @version, @crystal, @license, @dependencies, @record_last_updated

    property id                  : Int32
    property host                : String
    property user_name           : String
    property repo_name           : String
    property travis_ci           : Bool
    property github_actions      : Bool
    property shard_yml           : Bool
    property name                : String
    property description         : String
    property record_last_updated : String
    property version             : String
    property crystal             : String
    property license             : String
    property dependencies
    getter dependencies = [] of Array(String)

    def initialize(
            id = 0,
            host = "",
            user_name = "",
            repo_name = "",
            travis_ci = false,
            github_actions = false,
            shard_yml = false,
            name = "",
            description = "",
            record_last_updated = "",
            version = "",
            crystal = "",
            license = "",
            dependencies = [] of Array(String))
        @id = id
        @host = host
        @user_name = user_name
        @repo_name = repo_name
        @travis_ci = travis_ci
        @github_actions = github_actions
        @shard_yml = shard_yml
        @name = name
        @description = description
        @record_last_updated = record_last_updated
        @version = version
        @crystal = crystal
        @license = license
        @dependencies = dependencies
    end

    def Shard.from_db(rs)
        Shard.new(
            id: rs.read(Int32),
            host: rs.read(String),
            user_name: rs.read(String),
            repo_name: rs.read(String),
            name: rs.read(String),
            record_last_updated: rs.read(String), # TODO date
            description: rs.read(String),
            version: rs.read(String),
            shard_yml: rs.read(Bool),
            travis_ci: rs.read(Bool),
            github_actions: rs.read(Bool),
            crystal: rs.read(String),
            license: rs.read(String),
        )
    end

end

class Dependency
    property shards_id       : Int32
    property dependency_type : String
    property host            : String
    property user_name       : String
    property repo_name       : String

    def initialize(shards_id, dependency_type, host, user_name, repo_name)
        @shards_id = shards_id
        @dependency_type = dependency_type
        @host = host
        @user_name = user_name
        @repo_name = repo_name
    end

    def url
        return "https://#{@host}/#{@user_name}/#{@repo_name}"
    end

    def Dependency.from_db(rs)
        Dependency.new(
            shards_id: rs.read(Int32),
            dependency_type: rs.read(String),
            host: rs.read(String),
            user_name: rs.read(String),
            repo_name: rs.read(String),
        )
    end
end

def get_all_dependencies()
    dependencies = [] of Dependency
    db_file = get_db_file
    DB.open "sqlite3://#{db_file}" do |db|
        db.query "
                SELECT shards_id, dependency_type, host, user_name, repo_name
                FROM dependencies",
                do |rs|
            rs.each do
                dependencies.push Dependency.from_db(rs)
            end
        end
    end
    return dependencies
end

def count(db, sql)
    result = 0
    db.query sql do |rs|
        rs.each do
            result = rs.read(Int32)
        end
    end
    return result
end

def get_stats()
    stats = {} of String => Int32

    db_file = get_db_file
    DB.open "sqlite3://#{db_file}" do |db|
        stats["all"] = count(db, "SELECT COUNT(*) FROM shards")
        stats["no_description"] = count(db, %{SELECT COUNT(*) FROM shards WHERE description = ""})
    end
    return stats
end

def get_reverse_dependencies(host, user_name, repo_name)
    dependencies = [] of Dependency

    db_file = get_db_file
    DB.open "sqlite3://#{db_file}" do |db|
        db.query "
                SELECT shards.id, dependencies.dependency_type, shards.host, shards.user_name, shards.repo_name
                FROM shards, dependencies
                WHERE dependencies.shards_id=shards.id
                    AND dependencies.host = ?
                    AND dependencies.user_name = ?
                    AND dependencies.repo_name = ?",
                host, user_name, repo_name do |rs|
            rs.each do
                dependencies.push Dependency.from_db(rs)
            end
        end
    end
    return dependencies
end

def get_dependencies(shard_id)
    dependencies = [] of Dependency

    db_file = get_db_file
    DB.open "sqlite3://#{db_file}" do |db|
        db.query "
                SELECT shards_id, dependency_type, host, user_name, repo_name
                FROM dependencies
                WHERE shards_id=?",
                shard_id do |rs|
            rs.each do
                dependencies.push Dependency.from_db(rs)
            end
        end
    end
    return dependencies
end

def get_project(host, user_name, repo_name)
    db_file = get_db_file

    shard = nil
    DB.open "sqlite3://#{db_file}" do |db|
        db.query "SELECT #{FIELDS} FROM shards WHERE host=? AND user_name=? AND repo_name=?",
            host, user_name, repo_name do |rs|
            rs.each do
                # TODO it is a loop but there should be only one result (or maybe none) how to improve?
                shard = Shard.from_db(rs)
            end
        end
    end
    return shard
end


def get_shards(query)
    query = "%" + query + "%"
    db_file = get_db_file
    shards = [] of Shard
    DB.open "sqlite3://#{db_file}" do |db|
        db.query "SELECT #{FIELDS}
            FROM shards
            WHERE
                repo_name LIKE ?
                OR name LIKE ?
                OR description LIKE ?
        ",  query, query, query do |rs|
            rs.each do
                shards.push Shard.from_db(rs)
            end
        end
    end
    shards
end

def get_all()
    db_file = get_db_file
    shards = [] of Shard
    DB.open "sqlite3://#{db_file}" do |db|
        db.query "SELECT #{FIELDS} FROM shards" do |rs|
            rs.each do
                shards.push Shard.from_db(rs)
            end
        end
    end
    shards
end

def store_in_db(data)
    rows_affected, last_insert_id = store_shard_in_db(data)
    store_dependencies_in_db(last_insert_id, data)

    return rows_affected, last_insert_id
end

def store_dependencies_in_db(shard_id, data)
    db_file = get_db_file
    DB.open "sqlite3://#{db_file}" do |db|
        db.exec "DELETE FROM dependencies WHERE shards_id=?", shard_id
        data.dependencies.each {|dependency|
            db.exec "INSERT INTO dependencies
                (shards_id, dependency_type, host, user_name, repo_name)
                VALUES (?, ?, ?, ?, ?)",
                shard_id, dependency[0], dependency[1], dependency[2], dependency[3]
        }
    end
end

def store_shard_in_db(data)
    now = Time.utc

    project = get_project(data.host, data.user_name, data.repo_name)

    db_file = get_db_file
    DB.open "sqlite3://#{db_file}" do |db|
        if ! project.nil? && project.id != 0
            rowid = project.id
            Log.info { "Row ID #{rowid}" }
            res = db.exec "UPDATE shards SET
                host=?,
                user_name=?,
                repo_name=?,
                record_last_updated=?,
                name=?,
                description=?,
                version=?,
                travis_ci=?,
                github_actions=?,
                shard_yml=?,
                crystal=?,
                license=?
                WHERE id=?",

                data.host,
                data.user_name,
                data.repo_name,
                now,
                data.name,
                data.description,
                data.version,
                data.travis_ci,
                data.github_actions,
                data.shard_yml,
                data.crystal,
                data.license,
                rowid

            Log.info { "res #{res}" }
            return res.rows_affected, res.last_insert_id
        else
            Log.info { "New Row" }
            res = db.exec "INSERT INTO shards
                (host, user_name, repo_name, record_last_updated, name, description, version, travis_ci, github_actions, shard_yml, crystal, license)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                data.host,
                data.user_name,
                data.repo_name,
                now,
                data.name,
                data.description,
                data.version,
                data.travis_ci,
                data.github_actions,
                data.shard_yml,
                data.crystal,
                data.license

            Log.info { "res #{res}" }
            return res.rows_affected, res.last_insert_id
        end
    end
end
