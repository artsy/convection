# Convection 
Convection is the application that powers our consignments workflow, enabling users to submit works to consign through Artsy partners. For now, it encapsulates logic from [rothko-api] and [rothko-web-public].

## Meta [![CircleCI][badge]][circleci]
- **State:** production
- **Production:** [https://convection.artsy.net][production] | [Kubernetes][production_k8]
- **Staging:** [https://convection-staging.artsy.net][staging] | [Kubernetes][staging_k8]
- **GitHub:** [https://github.com/artsy/convection](https://github.com/artsy/convection)
- **Point People:** [@sweir27]
- **CI/Deploys:** [CircleCi](https://circleci.com/gh/artsy/convection); PRs merged to `artsy/convection#master` are automatically deployed to staging; PRs from `staging` to `release` are automatically deployed to production. Create such a PR with [`deploy_pr`][deploy_pr] or [this handy link][deploy].
- **Cron Tasks:** A daily digest is sent to partners at 10am EST. The production database is exported daily at 12am EST, and imported to staging daily at 1am EST. 

## Setup

- Fork the project to your GitHub account

- Clone your fork:

  ```
  $ git clone git@github.com:your-github-username/convection.git
  ```

- Read and run setup script:
  ```
  $ cat bin/setup
  $ bin/setup
  ```

- Populate environment variables

  `.env.example` contains the keys you'll need to add to your local `.env` file. Consider using [the `copy_env` utility](https://github.com/jonallured/copy_env) to populate the values directly from hokusai:

  ```
  $ copy_env hokusai
  ```

## Tests

Once setup, you can run the tests like this:

```
$ bundle exec rake spec
# or
$ hokusai test
```

Note: the default rake task is setup to run tests and RuboCop.

## Starting Server

```
$ foreman start
# or
$ hokusai dev start
```

See the Procfile and Hokusai configuration to understand other services launched.

## API

When running in development, this API has a GraphiQL instance at http://localhost:5000/graphiql

## Creating a Submission

Generate a valid JWT token in a Convection console:

```ruby
payload =  { aud: 'app', sub: '<valid user id>', roles: 'user,admin' }
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
[production_k8]: https://kubernetes.artsy.net/#!/deployment/default/convection-web
[staging]: https://convection-staging.artsy.net
[staging_k8]: https://kubernetes-staging.artsy.net/#!/deployment/default/convection-web
[@sweir27]: https://github.com/sweir27
[deploy_pr]: https://github.com/jonallured/deploy_pr
[deploy]: https://github.com/artsy/convection/compare/release...staging?expand=1
