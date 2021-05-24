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

## Collect 

```
crystal mine.cr --url https://github.com/szabgab/crystal-mine.cr
```

Or create a file with a list of repo URLs and then call

```
crystal mine.cr --repos repos.txt
```
