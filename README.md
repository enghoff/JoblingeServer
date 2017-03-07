### Joblinge Backend

Documentation:

[API](doc/api.md)
[DEPLOY-SETUP](doc/deploy-setup.md)
[PRODUCTION-SETUP](doc/production-setup.md)


To start

- `cp config/settings.example.yml config/settings.yml`
- `cp .rbenv-vars.example .rbenv-vars`
- `bundle`
- `bundle exec rake db:setup`
- `bundle exec rake tmp:create`

Environment variables for the database and email server configuration can be set at the `rbenv-vars` file.

Launch the app with `bundle exec rails s -b 0.0.0.0`

Run the tests with `bundle exec guard`

Use MailHog or MailCatcher to intercept emails on port 1025 by default.

- To launch mailhog: `mailhog` (server on :8025)
- To launch Mailcatcher: `mailcatcher --http-ip=0.0.0.0` (server on :1080)





