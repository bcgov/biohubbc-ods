
with mapping as
         (select p.spi_project_id, pp.person_id, b.project_id
          from spi_projects p
                   inner join biohub.project b on p.spi_project_id = b.spi_project_id
                   inner join spi_persons pp on pp.spi_project_id = p.spi_project_id)
insert
into biohub.project_participation (project_id, system_user_id, project_role_id, create_user)
select mapping.project_id,
       (select biohub_user_id from migrate_spi_user_deduplication where mapping.person_id = ANY (spi_person_ids)),
       5,
       (select system_user_id from biohub.system_user where user_identifier = 'spi-migration')
from mapping
on conflict do nothing;
