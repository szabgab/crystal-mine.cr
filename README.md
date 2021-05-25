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
crystal spec
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
crystal src/mine.cr --repos spec/repos.txt
crystal src/mine.cr --repos spec/many_repos.txt
```

## Web application

```
crystal run src/webapp.cr
```

Build sentry:

```
crystal build --release lib/sentry/src/sentry_cli.cr -o ./bin/sentry
```

Run with sentry

```
./bin/sentry -b "crystal build src/webapp.cr -o bin/webapp" -r bin/webapp
```


## CSS

Generate CSS file (public/bulma.css) from SCSS file (sass/mystles.scss):

```
npm install
npm run css-build
```

## Add fields to collect and display

1. Add to database schema (in db)
1. Add to store_in_db (in db)
1. Remove old `data.db`
1. Run collect `crystal src/mine.cr --repos spec/repos.txt --verbose`
1. Dump data using `echo .dump | sqlite3 data.db > spec/data.sql`
1. Add columns to `FIELDS` and to `parse_row`
1. Add columns to the display template
