# Convection

Convection is the application that powers our consignments workflow, letting users submit works to consign through Artsy partners. For now, it encapsulates logic from [rothko-api](https://github.com/artsy/rothko-api) and [rothko-web-public](https://github.com/artsy/rothko-web-public).

[![CircleCI](https://circleci.com/gh/artsy/pulse.svg?style=svg&circle-token=c6fe94db9990375e2a542dc38153a812a6cf6b48)](https://circleci.com/gh/artsy/pulse)

* __State:__ _early_ production
* __Staging:__ [pulse-staging.artsy.net](https://pulse-staging.artsy.net) | [artsy-pulse-staging on Heroku](https://dashboard.heroku.com/apps/artsy-pulse-staging/resources)
* __Production:__ [pulse.artsy.net](https://pulse.artsy.net) | [artsy-pulse-production on Heroku](https://dashboard.heroku.com/apps/artsy-pulse-production/resources)
* __Github:__ [https://github.com/artsy/pulse](https://github.com/artsy/pulse)
* __CI:__ [CircleCI](https://circleci.com/gh/artsy/pulse)
* __Branching/Deploys:__ PRs merged to `master` are automatically built and deployed to staging. PRs from `master` to `release` are automatically deployed to production. [Deploy to production](https://github.com/artsy/pulse/compare/release...master?expand=1).

### Set up

    bundle # install dependencies
    bundle exec rake # run rubocop and tests
    cp .env.example .env # create local file for configuration, edit it
    foreman start # run local rails server and sidekiq worker

### Example request

Trigger a password-reset email for the user with id `4ec1365bd7e9bb000100028d`:

    curl -H 'Authorization: Token <secret>' -H 'Accept: application/json' -d 'user_id=4ec1365bd7e9bb000100028d' https://pulse-staging.artsy.net/api/forgot_password

### Development notes

Configuration is provided via environment variables. [Foreman](https://github.com/ddollar/foreman) and a `.env` file are recommended. See `config/initializers/_config.rb` for a list of available properties and their defaults.

A [mailtrap.io](mailtrap.io) mailbox already exists and is the default destination for emails from a development environment. (See 1Password for the necessary credentials.)

Email templates can also be previewed locally by implementing previews in `spec/mailers/previews` and visiting [http://localhost:3000/rails/mailers](http://localhost:3000/rails/mailers).

Available API routes should be documented in the `BaseController#root` action's response.
