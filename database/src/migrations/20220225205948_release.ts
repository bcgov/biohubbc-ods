import * as fs from 'fs';
import { Knex } from 'knex';
import path from 'path';

const SPI_DATA_SCHEMA = process.env.DB_SPI_SCHEMA;
const DB_USER_API_PASS = process.env.DB_USER_API_PASS;
const DB_USER_API = process.env.DB_USER_API;

const DB_RELEASE = 'release.0.1.0';

/**
 * Apply biohub-platform release changes.
 *
 * @export
 * @param {Knex} knex
 * @return {*}  {Promise<void>}
 */
export async function up(knex: Knex): Promise<void> {
  const create_spatial_extensions = fs.readFileSync(path.join(__dirname, DB_RELEASE, 'create_spatial_extensions.psql'));

  const biohub_ods_spi_ddl = fs.readFileSync(path.join(__dirname, DB_RELEASE, 'biohub_ods_spi.sql'));
  await knex.raw(`
    -- set up spatial extensions
    ${create_spatial_extensions}

    -- set up data schema
    create schema if not exists ${SPI_DATA_SCHEMA};
    GRANT ALL ON SCHEMA ${SPI_DATA_SCHEMA} TO postgres;
    set search_path = ${SPI_DATA_SCHEMA}, public;

    -- setup api user
    create user ${DB_USER_API} password '${DB_USER_API_PASS}';

    -- postgres grants
    grant all on schema ${SPI_DATA_SCHEMA} to postgres;
    alter DEFAULT PRIVILEGES in SCHEMA ${SPI_DATA_SCHEMA} grant ALL on tables to postgres;

    -- api user grants
    grant all on schema ${SPI_DATA_SCHEMA} to ${DB_USER_API};
    GRANT USAGE ON SCHEMA ${SPI_DATA_SCHEMA} TO ${DB_USER_API};
    alter DEFAULT PRIVILEGES in SCHEMA ${SPI_DATA_SCHEMA} grant ALL on tables to ${DB_USER_API};
    alter role ${DB_USER_API} set search_path to ${SPI_DATA_SCHEMA}, public, topology;

    ${biohub_ods_spi_ddl}
  `);
}

export async function down(knex: Knex): Promise<void> {
  await knex.raw(`
    DROP SCHEMA IF EXISTS ${SPI_DATA_SCHEMA} CASCADE;
    DROP USER IF EXISTS ${DB_USER_API};
  `);
}
