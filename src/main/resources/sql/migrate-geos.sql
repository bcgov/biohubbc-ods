create table public.imported_geo_data
(
    id                     bigint primary key generated always as identity,
    geo                    geometry not null,
    spi_document_reference int      not null,
    spi_polygon_id         int      not null
);

create view
    public.map_imported_geodata_to_both_spi_and_biohub as
with labels as (select substring(dr.label from 'SPI GeoDB/(\d+)')::int as geodb_reference,
                       dr.spi_project_id                               as spi_project_id,
                       (select project_id
                        from biohub.project
                        where spi_project_id = dr.spi_project_id)      as biohub_project_id,
                       dr.design_component_id                          as spi_design_component_id,
                       dr.study_area_id                                as spi_study_area_id

                from spi_document_references dr
                where dr.label like 'SPI GeoDB/%')
select labels.*,
       imports.geo as raw_geo
from labels
         join imported_geo_data imports on geodb_reference = imports.spi_document_reference;


create or replace view public.geodata_as_mbtile_compatible_fc as
select row_to_json(featurecollection) as json
from (select 'FeatureCollection'               as type,
             array_to_json(array_agg(feature)) as features
      from (select 'Feature'                                             as type,
                   st_asgeojson(st_transform(x.raw_geo, 4326))::json     as geometry,
                   row_to_json((select p
                                from (select x.spi_project_id,
                                             x.biohub_project_id,
                                             x.spi_design_component_id,
                                             x.spi_study_area_id) as p)) as properties
            from map_imported_geodata_to_both_spi_and_biohub x
            where not st_isempty(x.raw_geo)) as feature) as featurecollection;
