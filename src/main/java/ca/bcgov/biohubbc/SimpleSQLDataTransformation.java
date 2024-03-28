package ca.bcgov.biohubbc;

import java.io.IOException;
import java.io.InputStreamReader;
import java.io.Reader;
import java.io.UncheckedIOException;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.SQLException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.io.Resource;
import org.springframework.util.FileCopyUtils;

public abstract class SimpleSQLDataTransformation extends DataTransformation {

  private final Logger log = LoggerFactory.getLogger(getClass());

  // should be injected in subclasses
  protected abstract Resource getSQLResource();

  private String SQLResourceToString() {
    Resource rez = this.getSQLResource();

    try (Reader reader = new InputStreamReader(rez.getInputStream(), StandardCharsets.UTF_8)) {
      return FileCopyUtils.copyToString(reader);
    } catch (IOException e) {
      throw new UncheckedIOException(e);
    }
  }

  public void run() throws DataTransformationException {
    String SQL = this.SQLResourceToString();

    try (Connection connection = ds.getConnection()){
      log.info("Executing native SQL");
      log.debug(SQL);

      connection.nativeSQL(SQL);

    } catch (SQLException e) {
      throw new DataTransformationException(e);
    }
  }

}
