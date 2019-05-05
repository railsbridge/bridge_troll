# Deployment Docs

The app is deployed on Heroku with staging and production servers.  Everyone with commit privileges to this repo, should be able to push to staging, since we should update staging whenever we update the code.  If you don't have access and you think you should, ask a [project admin](Project-Admins).

## Backups

We have daily backups:

```
heroku pg:backups schedules --app bridgetroll

=== Backup Schedules
HEROKU_POSTGRESQL_RED_URL: daily at 2:00 America/Los_Angeles
```

For more info, see [Heroku PGBackups docs](https://devcenter.heroku.com/articles/heroku-postgres-backups).

## production and staging git config

Here's a sample .git/config:

```
   [remote "heroku"]
	url = git@heroku.com:bridgetroll.git
	fetch = +refs/heads/*:refs/remotes/heroku/*
   [remote "staging"]
	url = git@heroku.com:bridgetroll-staging.git
	fetch = +refs/heads/*:refs/remotes/heroku/*
```

then to deploy the app to staging:

```
git push staging master
```

to production:

```
git push heroku master
```

publish new course descriptions
```
heroku run rake populate_courses --remote staging
```


## staging environment
staging is setup just like production, except
```
heroku config:set RACK_ENV=staging RAILS_ENV=staging --remote staging
```

### resetting the database

#### (1) set up db locally
```
export FORCE_POSTGRES=1
bundle
db:setup
```

#### (2) reset staging db

To execute database commands on heroku, we need the named database URL found via `heroku pg:info` (which isn't a URL at all, but rather a reference like `HEROKU_POSTGRESQL_BLUE_URL`. The commands below capture it into a variable, then reset the database

```
STAGING_DB_URL=`heroku pg:info --remote staging | sed -n "s/^=== \(.*\)$/\1/p"`
echo $STAGING_DB_URL
heroku pg:reset $STAGING_DB_URL --remote staging
```

then you will need to confirm that you really want to reset the database


#### (3) push local db to heroku staging

```
heroku pg:push bridgetroll_development $STAGING_DB_URL --remote staging
```
there are two errors which appear to be harmless

```
pg_restore: [archiver (db)] could not execute query: ERROR:  must be owner of extension plpgsql
    Command was: COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';
  :
pg_restore: [archiver (db)] Error from TOC entry 2650; 0 0 COMMENT EXTENSION unaccent
pg_restore: [archiver (db)] could not execute query: ERROR:  must be owner of extension unaccent
    Command was: COMMENT ON EXTENSION unaccent IS 'text search dictionary that removes accents';
 :
WARNING: errors ignored on restore: 2
 ▸    pg_restore errored with 1
```





