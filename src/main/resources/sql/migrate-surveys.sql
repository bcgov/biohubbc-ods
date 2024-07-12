insert into project(spi_project_id, name, objectives, start_date, end_date, location_description, create_date)
select spi_project_id, project_name, project_objectives, start_date, end_date, location_description, when_created
from spi_projects;


-- maintain mapping parity
alter table survey
    add column spi_survey_id integer null;

insert into biohub.survey (uuid, spi_survey_id, "name", start_date, end_date, create_date, update_date, create_user,
                           project_id)
insert into type(name, record_effective_date, create_user)
select distinct survey_type, to_timestamp(0), 8
from spi_surveyswhere survey_type is not nullon conflict do nothing;


insert into survey_type(survey_id, type_id, create_user)
select s.survey_id, (select type_id from type where name = ss.survey_type), 8
from survey s,
     spi_surveys ss
where spi_survey_id is not null
  and ss.survey_id = s.spi_survey_id
  and ss.survey_type is not null;


insert into intended_outcome(name, record_effective_date, create_user)
select distinct intended_outcome_measure_code, to_timestamp(0), 8
from spi_surveys
where spi_surveys.intended_outcome_measure_code is not nullon conflict do nothing;

update survey x
set intended_outcome_id = (select io.intended_outcome_id as iq
                           from intended_outcome io,
                                survey s,
                                spi_surveys ss
                           where s.spi_survey_id is not null
                             and ss.survey_id = s.spi_survey_id
                             and ss.intended_outcome_measure_code is not null
                             and io.name = ss.intended_outcome_measure_code
                             and s.survey_id = x.survey_id);

insert into ecological_season(name, record_effective_date, create_user)
select distinct ecological_season_code, to_timestamp(0), 8
from spi_surveys
where spi_surveys.ecological_season_code is not null
on conflict do nothing;


update survey x
set ecological_season_id = (select es.ecological_season_id as iq
                            from ecological_season es,
                                 survey s,
                                 spi_surveys ss
                            where s.spi_survey_id is not null
                              and ss.survey_id = s.spi_survey_id
                              and ss.ecological_season_code is not null
                              and es.name = ss.ecological_season_code
                              and s.survey_id = x.survey_id);


insert into permit(survey_id, number, type, create_user)
select s.survey_id, ss.wildlife_permit_label, 'spi-imported', 8
from survey s,
     spi_surveys ss
where spi_survey_id is not null
  and ss.survey_id = s.spi_survey_id
  and ss.wildlife_permit_label is not null;


insert into program (name, description)
values ('SPI Imported', '');


alter table study_species
    add column is_spi_import boolean not null default false;


insert into project_role (name, description, record_effective_date)
values ('SPI Imported Role', '', '1900-01-01');


with mapping as (select survey_id as survey, focus = 'PRIMARY' as is_focal, taxonomic_unit_id from spi_target_taxa)
insert
into study_species (survey_id, is_focal, wldtaxonomic_units_id, is_spi_import)
select s.survey_id, is_focal, taxonomic_unit_id, false
from mapping
         join survey s on mapping.survey = s.spi_survey_id;

