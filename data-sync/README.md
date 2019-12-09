# Data Sync

This directory includes the Dockerfile and scripts for copying production data to the staging database.
This image is used in a cron job which runs on the staging and production Kubernetes clusters daily.

## Deploying changes

After changing any files in the `data-sync` directory,
run `data-sync/publish-sync-dockerfile.sh` to build and publish the
new sync image.
