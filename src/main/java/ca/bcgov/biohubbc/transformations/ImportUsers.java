package ca.bcgov.biohubbc.transformations;

import ca.bcgov.biohubbc.SimpleSQLDataTransformation;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.annotation.Order;
import org.springframework.core.io.Resource;
import org.springframework.stereotype.Component;

@Component("IMPORT_USERS")
@Order(200)
public class ImportUsers extends SimpleSQLDataTransformation {

  @Value("classpath:sql/migrate-users.sql")
  private Resource SQL;

  @Override
  protected Resource getSQLResource() {
    return SQL;
  }
}
