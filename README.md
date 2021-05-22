# Crystal Mine

## Setup

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

## TODO

* Create web interface to display data from database
* Write tests to check the web interface
* Use templates
* List all the names on the front page


* Move application inside Docker container and docker-compose
* Deploy application

* Fetch all the Crystal projects from Github (waiting for watzon/octokit.cr or using plain api request)


* Allow user to search database (name of the project, description)
* Show last-modified based on GitHub
* Create a cross reference with the authors
* Create a page with the pictures of the authors
* Collect all the contributors as well and show them as well
* Allow people to ask to be excluded (a config file in the mine or in their own GitHub repo?)
* List dependencies based on the shard.yml and based on the actual usage, link to dependencies, list reverse dependencies

* Be able to easily find the documentation or link to documentation of packages. e.g. HTTP::Client::Response

