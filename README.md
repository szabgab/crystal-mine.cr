# Crystal Mine

Source code of the [Crystal Mine](https://crystal-mine.org/)

## Setup Development environment

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

## Docker compose for development

1. Install Docker
1. Install Docker compose (e.g. `pip install docker-compose`)
1. Copy `docker-compose.override.yml.example` to `docker-compose.override.yml` and change it according to your taste.
1. Build: `docker-compose build`
1. Start `docker-compose up`
1. Collect some data: `docker exec -it crystal-minecr_cron_1 crystal src/mine.cr --repos spec/repos.txt`
1. Visit http://localhost:6002



## Run tests

```
docker exec -it crystal-minecr_cron_1 crystal spec
```

Run test files separately

```
docker exec -it crystal-minecr_cron_1 crystal spec/web_test_spec.cr
docker exec -it crystal-minecr_cron_1 crystal spec/db_test_spec.cr
```

## Data Collecion:

A single URL

```
docker exec -it crystal-minecr_cron_1 crystal src/mine.cr --url https://github.com/szabgab/crystal-mine.cr
```

Or create a file with a list of repo URLs and then call

```
docker exec -it crystal-minecr_cron_1 crystal src/mine.cr --repos spec/repos.txt
docker exec -it crystal-minecr_cron_1 crystal src/mine.cr --repos spec/many_repos.txt
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
1. Run `crystal/update.cr`  that will update the *.sql and *.json files in spec/
1. Add columns to `FIELDS` and to `parse_row`
1. Add columns to the display template
