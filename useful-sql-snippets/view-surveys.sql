select survey.survey_name                                                                                    as name,
       survey.start_date                                                                                     as start_date,
       survey.end_date                                                                                       as end_date,
       survey.survey_type                                                                                    as type,
       survey.intended_outcome_measure_code                                                                  as ecological_variables,
       coalesce(survey.objectives_note, '') ||
       coalesce(survey.ecological_season_code, '') ||
       (select string_agg(coalesce(sa.layout_note, ''), ', ')
        from spi_study_areas sa
        where sa.study_area_id in
              (select study_area_id from spi_survey_study_areas ssa where ssa.survey_id = survey.survey_id)) as notes,
       funding.agency_project_label,
       survey.wildlife_permit_label                                                                          as permit_number,
       0                                                                                                     as funding_amount,
       (select taxa.taxonomic_unit_id
        from spi_target_taxa taxa
        where taxa.survey_id = survey.survey_id
          and focus = 'PRIMARY'
        limit 1)
from spi_surveys survey,
     spi_fundings funding
where funding.spi_project_id = survey.spi_project_id;
