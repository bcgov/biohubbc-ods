# bcgov/biohubbc/database

## Technologies Used

| Technology | Version | Website                              | Description          |
| ---------- | ------- | ------------------------------------ | -------------------- |
| node       | 14.x.x  | https://nodejs.org/en/               | JavaScript Runtime   |
| npm        | 6.x.x   | https://www.npmjs.com/               | Node Package Manager |
| PostgreSQL | 12.5    | https://www.postgresql.org/download/ | PSQL database        |
| PostGIS    | 3       | https://postgis.net/                 | GIS (spatial) tools  |

<br />

# Knex Migrations / Seeds

## Migrations

An ordered list of database changes (creates, deletes, alters, etc).  
The latest version of your database will then be the summation of all of the migration changes, applied in order.

Migrations are tracked via a `migrations` database table, and will only ever run once.

## Seeds

A set of scripts that populate the database tables with any ephemeral values required for the app to function during development. This can include dummy data so that when the app is running locally, you don't have to manually create data in order to experience the app as it would be in a real environment.

Seeds will run in alphanumeric order, so if the order of seeds is important, consider prefixing the file name with a number.

Unlike migrations, seeds are not tracked, and will attempt to run every time the knex seeds command is executed. As a result, seeds should be written such that they can be run repeatedly without error.

# Port forward to remote database

1. Open a terminal
2. Log in to OpenShift using the login command copied from the web-console
3. Get onto the correct project
   ```
   oc projects
   oc project <correct project name>
   ```
4. Find the database pod
   ```
   oc get pods
   ```
5. Port forward

   ```
   oc port-forward <pod name> <local port to use>:<remove port to forward>

   Ex:

   oc port-forward biohub-platform-db-postgresql-dev-deploy-100 5555:5432
   ```

<br />

# General PSQL commands

## Dumping the database

Doc: https://www.postgresql.org/docs/9.6/app-pgdump.html

```
pg_dump databaseName > dumpFileName
```

### Useful options:

    --schema-only
    --data-only

## Restoring the database from a dump

Doc: https://www.postgresql.org/docs/9.6/app-pgrestore.html

```
pg_restore dumpFileName
```

### Useful options:

    --schema-only
    --data-only

<br />

# Troubleshooting

## Knex

### Required configuration option 'client' is missing.

The `Knexfile.ts` defines the settings that Knex will use when running migrations and seeds. It requires several environment variables to function correctly.

- Double check that your environment variables have been set (`.env`)
  - See makefile command: `Make env`
