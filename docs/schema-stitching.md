# Schema Stitching

Convection takes advantage of [schema stitching](https://artsy.github.io/blog/2018/12/11/GraphQL-Stitching/), which allows us to localize our GraphQL code at the service level, rather than writing everything in Metaphysics. However, there are some steps involved in ensuring that the changes made here propagate correctly throughout our application eco-system.

### Adding or modifying Convection GraphQL schema

1. Make change to convection GraphQL schema, run rake task to generate `_schema.graphql file`, open PR and merge, and be sure its fully deployed to staging
1. In Metaphysics commit that new schema file and open a PR. Merge PR, and make sure it gets to staging.
1. In Eigen (if needed) - run `yarn sync-schema`. Merge PR. An Eigen bot will then go back over to MP and update persisted queries
1. In Volt (if needed) run `foreman run bundle exec rake graphql:schema:update`
1. In Reaction (if needed) run `yarn sync-schema`. PR and merge, and make sure an `auto` release has been deployed to NPM
1. Go to force. If Renovate hasn’t already merged Reaction version bump, go ahead and open a PR containing latest reaction version and and merge.

So that ends up looking something like this:

```
$ rake graphql:schema:idl
# commit in convection
$ cp _schema.graphql ../metaphysics/src/data/convection.graphql
# commit in metaphysics
```

> NOTE: Technically speaking, only steps 1 and 2 are required to start working with stitched code, but there will be schema out of sync warnings on PRs if theres a difference between Eigen local schema and MP or Reaction local schema and MP (which is checked in Force, since Force is the deploy target).
