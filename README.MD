# SPI Migration Scripts

This repository contains code related to the migration of the legacy SPI database into the BiohubBC/SIMS environment.

There are three main components:

### Transformation Code

A Java application that is designed to work on a prepared PostgreSQL database (see documentation on preparation steps in
Confluence).

To execute, ensure you have a modern Java runtime and execute:

```
./gradlew bootRun
```

### GeoPandas GEODB import Core

Standalone application for importing GeoDB data into PostGIS. Documented in the `./geodb-import` directory.

### Collection of useful SQL snippets

In `./useful-sql-snippets`
