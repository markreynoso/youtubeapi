## Instructions to install GiveSafe

1. Install the requirements [below](#Requirements)
2. Clone the repo from git@github.com:markreynoso/youtubeapi.git
3. Go to the project's root directory and run `bundle install`
4. Setup your env configuation. 
    * Open `/config/database.yml` and add you postgres credentials if needed. 
    * Create `/config/env_vars.yml` and add your api keys. See example below.
5. Setup the databases: 
```shell
bin/rake db:create
bin/rake db:migrate
bin/rake db:seed
```

Run the application with `bin/rails server`

### Requirements

Environment variables example. 
```
development:
    YOUTUBE_API_KEY: add_key
    SUBSPLASH_API_KEY: add_key
```

Requires the following:
* postgres [install here](http://www.postgresql.org/download/) 
* ruby 2.5.1
* rails 5.2.1
