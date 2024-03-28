create table if not exists public.migrate_spi_user_deduplication
(
    id              bigserial primary key,
    given_name      varchar(255) not null,
    family_name     varchar(255) not null,
    display_name    varchar(512) not null,
    when_created    date,
    when_updated    date,
    spi_project_ids integer[] check (cardinality(spi_project_ids) > 0),
    spi_person_ids  integer[] check (cardinality(spi_project_ids) > 0),
    biohub_user_id  integer      null references biohub.system_user (system_user_id) on delete set null on update cascade default null,
    constraint dedup unique (family_name, given_name)
)
;


CREATE OR REPLACE FUNCTION public.migrate_populate_project_ids()
    RETURNS trigger
    LANGUAGE plpgsql
AS
$function$
BEGIN
    new.spi_project_ids := (select spi_project_id from spi_persons where person_id in (new.spi_person_ids));
    return new;
END
$function$;

create or replace trigger populate_project_ids
    after insert or update
    on public.migrate_spi_user_deduplication
    for each row
execute function public.migrate_populate_project_ids();

insert into migrate_spi_user_deduplication
(family_name, given_name, display_name, when_created, when_updated, spi_project_ids, spi_person_ids)

select surname,
       regexp_replace(concat(trim(first_given_name), ' ', trim(second_given_name)), '\s+', ' ', 'g') as given_name,
       regexp_replace(concat(trim(first_given_name), ' ', trim(second_given_name), ' ', trim(surname)), '\s+', ' ',
                      'g')                                                                           as display_name,
       min(date_trunc('day', when_created))                                                          as when_created,
       max(date_trunc('day', when_updated))                                                          as when_updated,
       array_agg(spi_project_id)                                                                     as spi_project_ids,
       array_agg(person_id)                                                                          as spi_person_ids
from spi_persons
group by surname, regexp_replace(concat(trim(first_given_name), ' ', trim(second_given_name)), '\s+', ' ', 'g'),
         regexp_replace(concat(trim(first_given_name), ' ', trim(second_given_name), ' ', trim(surname)), '\s+', ' ',
                        'g');

insert into biohub.system_user (user_identity_source_id,
                                user_identifier,
                                record_effective_date,
                                create_date,
                                create_user,
                                update_date,
                                display_name,
                                given_name,
                                family_name,
                                notes,
                                email)
select 1,
       'spi-' || id,
       current_date,
       when_created,
       (select system_user_id from system_user where user_identifier = 'spi-migration'),
       when_updated,
       display_name,
       given_name,
       family_name,
       json_build_object('migration_id', id)::text,
       'default'

from migrate_spi_user_deduplication;
