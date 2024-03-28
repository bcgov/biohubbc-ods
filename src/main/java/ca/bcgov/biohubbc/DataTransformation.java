package ca.bcgov.biohubbc;

import javax.sql.DataSource;
import org.springframework.beans.factory.BeanNameAware;
import org.springframework.beans.factory.annotation.Autowired;

public abstract class DataTransformation implements BeanNameAware {

  private String beanName;

  @Override
  public void setBeanName(String name) {
    this.beanName = name;
  }

  public String getBeanName() {
    return beanName;
  }

  @Override
  public String toString() {
    return getBeanName();
  }

  @Autowired
  protected DataSource ds;

  public abstract void run() throws DataTransformationException;
}
