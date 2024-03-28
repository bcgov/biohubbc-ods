package ca.bcgov.biohubbc.transformations;

import ca.bcgov.biohubbc.SimpleSQLDataTransformation;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.annotation.Order;
import org.springframework.core.io.Resource;
import org.springframework.stereotype.Component;

@Component("IMPORT_PROJECTS")
@Order(100)
public class ImportProjects extends SimpleSQLDataTransformation {

  @Value("classpath:sql/migrate-projects.sql")
  private Resource SQL;

  @Override
  protected Resource getSQLResource() {
    return SQL;
  }
}
