# Convection [![CircleCI][badge]][circleci]

Convection is the application that powers our consignments workflow, enabling
users to submit works to consign through Artsy partners. For now, it
encapsulates logic from [rothko-api] and [rothko-web-public].


* State: production
* Production: [https://convection.artsy.net][production] | [Heroku][production_heroku]
* Staging: [https://convection-staging.artsy.net][staging] | [Heroku][staging_heroku]
* GitHub: [https://github.com/artsy/convection](https://github.com/artsy/convection)
* Point People: [@sweir27]

## Setup

* Fork the project to your GitHub account

* Clone your fork:
  ```
  $ git clone git@github.com:your-github-username/convection.git
  ```

* Read and run setup script:
  ```
  $ cat bin/setup
  $ bin/setup
  ```

## Tests

Once setup, you can run the tests like this:

```
$ bundle exec rake spec
```

Note: the default rake task is setup to run tests and RuboCop.

## Starting Server

Foreman is used to manage the server configuration, so starting a server is as
easy as:

```
$ foreman start
```

See the Procfile for more.

## Deploying

PRs merged to the `master` branch are automatically deployed to staging.
Production is automatically deployed upon merges to `release`. Create such a PR
with [`deploy_pr`][deploy_pr] or [this handy link][deploy].

## Creating a Submission

Generate a valid JWT token in a Convection console:

```ruby
payload =  { aud: 'app', sub: '<valid user id>' }
token = JWT.encode payload, Convection.config.jwt_secret, 'HS256'
```

Use `curl` to generate a submission with an `artist_id` (emails will appear in
mailtrap).

```
curl -H 'Authorization: Bearer <token>' -H 'Accept: application/json' -d 'artist_id=5059d82a1fc9fa00020008ff' https://convection-staging.artsy.net/api/submissions
```

[badge]: https://circleci.com/gh/artsy/convection.svg?style=svg&circle-token=cf452a49d5399e749ebbb85a0843d6111b79c9aa
[circleci]: https://circleci.com/gh/artsy/convection
[rothko-api]: https://github.com/artsy/rothko-api
[rothko-web-public]: https://github.com/artsy/rothko-web-public
[production]: https://convection.artsy.net
[production_heroku]: https://dashboard.heroku.com/apps/convection-production
[staging]: https://convection-staging.artsy.net
[staging_heroku]: https://dashboard.heroku.com/apps/convection-staging
[@sweir27]: https://github.com/sweir27
[deploy_pr]: https://github.com/jonallured/deploy_pr
[deploy]: https://github.com/artsy/convection/compare/release...master?expand=1
