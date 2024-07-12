package ca.bcgov.biohubbc.transformations;

import ca.bcgov.biohubbc.SimpleSQLDataTransformation;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.annotation.Order;
import org.springframework.core.io.Resource;
import org.springframework.stereotype.Component;

@Component("IMPORT_LINK_GEOS_TO_SURVEYS")
@Order(500)
public class ImportLinkGeosToSurveys extends SimpleSQLDataTransformation {

  @Value("classpath:sql/migrate-link-geos-to-surveys.sql")
  private Resource SQL;

  @Override
  protected Resource getSQLResource() {
    return SQL;
  }
}
