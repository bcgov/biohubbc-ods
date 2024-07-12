create table temp_survey_matching as (select substring(dr.label from 'SPI GeoDB/(\d+)')::int                          as geodb_reference,
                                             dr.spi_project_id                                                        as spi_project_id,
                                             (select project_id
                                              from biohub.project
                                              where spi_project_id = dr.spi_project_id)                               as biohub_project_id,
                                             dr.design_component_id                                                   as spi_design_component_id,
                                             dr.study_area_id                                                         as spi_study_area_id,
                                             (select ssa.study_area_name
                                              from spi_study_areas ssa
                                              where ssa.study_area_id = dr.study_area_id)                             as study_area_name,
                                             (select dc.design_component_label
                                              from spi_design_components dc
                                              where dc.design_component_id = dr.design_component_id)                  as dc_label,
                                             (select dc.design_component_type
                                              from spi_design_components dc
                                              where dc.design_component_id = dr.design_component_id)                  as dc_type,
                                             (select array_agg(g.geo)
                                              from imported_geo_data g
                                              where g.spi_document_reference = dr.document_reference_id)              as geo,
                                             (select array_agg(s2a.survey_id)
                                              from spi_survey_study_areas s2a
                                              where s2a.study_area_id = dr.study_area_id)                             as spi_survey_ids,
                                             (select array_agg(survey_id)
                                              from survey sv
                                              where sv.spi_survey_id in (select s2a.survey_id
                                                                         from spi_survey_study_areas s2a
                                                                         where s2a.study_area_id = dr.study_area_id)) as biohub_survey_ids
                                      from spi_document_references dr
                                      where dr.label like 'SPI GeoDB/%');

delete
from temp_survey_matching
where geo is null;

with cte as (select ts.spi_project_id,
                    ts.study_area_name,
                    ts.dc_label,
                    ts.dc_type,
                    u.*
             from temp_survey_matching ts,
                  unnest(biohub_survey_ids, geo) as u(survey, geoz)
             where u.geoz is not null)
insert
into survey_spatial_component(survey_id,
                              name,
                              description,
                              geometry,
                              geography,
                              create_date,
                              create_user,
                              update_date,
                              update_user,
                              revision_count)
select distinct on (cte.survey, cte.study_area_name) cte.survey,
                                                     cte.study_area_name,
                                                     'SPI Import - ' || cte.dc_type || ' - ' || cte.dc_label,
                                                     ST_Transform(cte.geoz::geometry, 3005),
                                                     cte.geoz,
                                                     current_date,
                                                     (select system_user_id
                                                      from system_user
                                                      where user_identifier = 'postgres'),
                                                     current_date,
                                                     (select system_user_id
                                                      from system_user
                                                      where user_identifier = 'postgres'),
                                                     1
from cte
where cte.survey is not null;

insert
into survey_location(survey_id, name, description, geometry, geography, geojson, create_date, create_user, update_date,
                     update_user, revision_count);
