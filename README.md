# Convection

Convection is the application that powers our consignments workflow, enabling users to submit works to consign through Artsy partners. For now, it encapsulates logic from [rothko-api](https://github.com/artsy/rothko-api) and [rothko-web-public](https://github.com/artsy/rothko-web-public).

[![CircleCI](https://circleci.com/gh/artsy/convection.svg?style=svg&circle-token=cf452a49d5399e749ebbb85a0843d6111b79c9aa)](https://circleci.com/gh/artsy/convection)

* __State:__ development
* __Staging:__ [convection-staging.herokuapp.com](https://convection-staging.artsy.net) | [convection-staging on Heroku](https://dashboard.heroku.com/apps/convection-staging/resources)
* __Production:__ [convection-production.herokuapp.com](https://convection.artsy.net) | [convection-production on Heroku](https://dashboard.heroku.com/apps/convection-production/resources)
* __Github:__ [https://github.com/artsy/convection](https://github.com/artsy/convection)
* __CI:__ [CircleCI](https://circleci.com/gh/artsy/convection)
* __Branching/Deploys:__ PRs merged to `master` are automatically built and deployed to staging. PRs from `master` to `release` are automatically deployed to production. [Deploy to production](https://github.com/artsy/convection/compare/release...master?expand=1).

### Set up

    bundle # install dependencies
    bundle exec rake # run rubocop and tests
    cp .env.example .env # create local file for configuration, edit it
    foreman start # run local rails server

### Development notes

Configuration is provided via environment variables. [Foreman](https://github.com/ddollar/foreman) and a `.env` file are recommended. See `config/initializers/_config.rb` for a list of available properties and their defaults.

### Creating a Submission
Generate a valid JWT token in a Convection console:
```ruby
payload =  { aud: 'app', sub: '<valid user id>' }
token = JWT.encode payload, Convection.config.jwt_secret, 'HS256'
```

Use `curl` to generate a submission with an artist_id (emails will appear in mailtrap)
```
curl -H 'Authorization: Bearer <token>' -H 'Accept: application/json' -d 'artist_id=5059d82a1fc9fa00020008ff' https://convection-staging.artsy.net/api/submissions
```