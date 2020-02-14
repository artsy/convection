# Scripts

In the `/bin` folder there are a number of scripts to help one work with
convection, here are some basic descriptions of the ones we've added:

* `console` - open a rails console with proper env setup
* `pull_data` - pull postgres data from staging
* `server` - start a server with proper env setup
* `worker` - start a worker with proper env setup

To envoke any of these tasks, you can do this:

```
$ ./bin/console
```

So very friendly to scripting.

## Pull Data from Staging

In order to get one's local postgres database in sync with staging, you can run
the `pull_data` task:

```
$ ./bin/pull_data
```

This will:

* drop your dev database
* create an empty dev database
* dump the staging database
* restore the staging database

Note: you will need to be connected the VPN in order for this to work.
