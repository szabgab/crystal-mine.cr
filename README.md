# Crystal Mine

## Setup

### On Ubuntu:

```
sudo apt-get install libsqlite3-dev
sudo apt-get install sqlite3
```

```
shards install
```


* Create a [Personal Access token](https://github.com/settings/tokens) with a name that you can easily recognize, e.g. "Crystal Mine Development Token" using the following rights:

```
repo
   x public_repo

user
   x read:user
   x user:email
```
* Save your GitHub username and the token it in a file called `config.txt` like this:

```
USERNAME:TOKEN
```

## Run tests

```
KEMAL_ENV=test crystal spec
```

Run test files separately

```
KEMAL_ENV=test crystal spec/web_test_spec.cr
KEMAL_ENV=test crystal spec/db_test_spec.cr
```

## Data Collecion:

```
crystal src/mine.cr --url https://github.com/szabgab/crystal-mine.cr
```

Or create a file with a list of repo URLs and then call

```
crystal src/mine.cr --repos repos.txt
```

## Web application

```
crystal run src/webapp.cr
```
