# Convection

Convection is the application that powers our consignments workflow, enabling users to submit works to consign through Artsy partners. For now, it encapsulates logic from [rothko-api] and [rothko-web-public].

## Meta [![CircleCI][badge]][circleci]

- **State:** production
- **Production:** [https://convection.artsy.net][production] | [Kubernetes][production_k8]
- **Staging:** [https://convection-staging.artsy.net][staging] | [Kubernetes][staging_k8]
- **GitHub:** [https://github.com/artsy/convection](https://github.com/artsy/convection)
- **Point People:** [@jonallured]
- **CI/Deploys:** [CircleCi](https://circleci.com/gh/artsy/convection); PRs merged to `artsy/convection#master` are automatically deployed to staging; PRs from `staging` to `release` are automatically deployed to production. Create such a PR with [`deploy_pr`][deploy_pr] or [this handy link][deploy].
- **Cron Tasks:** A daily digest is sent to partners at 10am EST. The production database is exported Sunday mornings at 12am EST, and imported to staging Sunday mornings at 1am EST.

## Contributing Pull Requests

Convection accepts PRs from branches on the main artsy/convection repo. PRs from forks will not be built in the CI environment and cannot be merged directly.

## Setup

### Artsy Developers

- Read and run setup script:

  ```
  $ cat bin/setup
  $ bin/setup
  ```
- Shared Configuration for Local Development

Convection uses [shared configuration](https://github.com/artsy/README/blob/main/playbooks/development-environments.md#shared-configuration) to distribute common and sensitive configuration values. The setup script will download `.env.shared` and also initialize `.env` (from `.env.example`). The `.env` file is for custom configuration and any overrides.

If a new sensitive (or common) environment variable needs to be added for development, remember to also update the shared configuraton in S3. Find [update instructions here](https://github.com/artsy/README/blob/main/playbooks/development-environments.md#shared-configuration). _This is only required when expanding shared development environment configuration_.

### Non-Artsy Developers

- Fork the project to your GitHub account

- Clone your fork:

```
$ git clone git@github.com:your-github-username/convection.git
```

- Populate environment variables

`.env.oss.example` contains the environment variables you'll need to add to your local `.env` file.


## Tests

Once setup, you can run the tests like this:

```
$ bundle exec rake spec
# or
$ hokusai test
```

Note: the default rake task is setup to run tests and RuboCop.

## Did You Change the GraphQL Schema?

If you have changed Convection GraphQL schema, make sure to do the following:

Step 1: In convection, run:

```shell
$ rake graphql:schema:idl
```

Step 2: Copy the generated `_schema.graphql` file to the [convection.graphql](https://github.com/artsy/metaphysics/blob/master/src/data/convection.graphql) file in [metaphysics](https://github.com/artsy/metaphysics).

This file is used for stitching. See [docs/schema-stitching.md][schema-doc] for additional step you might need to do.

## Starting Server

```
$ foreman start
# or
$ hokusai dev start
```

See the Procfile and Hokusai configuration to understand other services launched.

## GraphQL

When running in development, this API has a GraphiQL instance at http://localhost:5000/graphiql

> See [schema stitching][schema-doc] for more info about propagating changes through the Artsy application ecosystem.

## Creating a Submission

Generate a valid JWT token in a Convection console:

```ruby
payload = { aud: 'app', sub: '<valid user id>', roles: 'user,admin' }
token = JWT.encode payload, Convection.config.jwt_secret, 'HS256'
```

### Via API:

Use `curl` to generate a submission with an `artist_id` (emails will appear in
mailtrap).

```
curl -H 'Authorization: Bearer <token>' -H 'Accept: application/json' -d 'artist_id=5059d82a1fc9fa00020008ff' https://convection-staging.artsy.net/api/submissions
```

### Via [Metaphysics](http://metaphysics-staging.artsy.net/):

Be sure a valid `X-Access-Token` is set (can be `jwt` from above) and submit the following GraphQL mutation:

```json
{
  "input": {
    "artistID": "5059d82a1fc9fa00020008ff"
  }
}
```

```graphql
mutation createConsignmentSubmissionMutation(
  $input: CreateSubmissionMutationInput!
) {
  createConsignmentSubmission(input: $input) {
    consignmentSubmission {
      id
      artist {
        id
      }
    }
  }
}
```

[badge]: https://circleci.com/gh/artsy/convection.svg?style=svg&circle-token=cf452a49d5399e749ebbb85a0843d6111b79c9aa
[circleci]: https://circleci.com/gh/artsy/convection
[rothko-api]: https://github.com/artsy/rothko-api
[rothko-web-public]: https://github.com/artsy/rothko-web-public
[production]: https://convection.artsy.net
[production_k8]: https://kubernetes.prd.artsy.systems/#!/deployment/default/convection-web
[staging]: https://convection-staging.artsy.net
[staging_k8]: https://kubernetes.stg.artsy.systems/#!/deployment/default/convection-web
[@jonallured]: https://github.com/jonallured
[deploy_pr]: https://github.com/jonallured/deploy_pr
[deploy]: https://github.com/artsy/convection/compare/release...staging?expand=1
[schema-doc]: docs/schema-stitching.md
