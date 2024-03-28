package ca.bcgov.biohubbc;


import java.util.List;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class TransformationRunner {
  private static Logger log = LoggerFactory.getLogger(TransformationRunner.class);

  private final List<DataTransformation> transformations;

  @Autowired
  public TransformationRunner(List<DataTransformation> transformations) {
    this.transformations = transformations;
  }


  @Autowired
  void listTransformation() {
    log.info("Listing available transformations");
    for (DataTransformation t : transformations) {
      log.info(t.toString());
    }
  }

  void runAllTransformations() {
    log.info("Running transformations");
    for (DataTransformation transformation : transformations) {
      log.info("Running transformation " + transformation.toString());
      try {
        transformation.run();
      } catch (DataTransformationException e) {
        log.error("Caught an unexpected error while running transformation", e);
      }
    }
    log.info("Run complete");
  }

  void runSpecificTransformation(String beanName) {
    this.transformations.stream().filter(p -> p.getBeanName().equals(beanName)).findFirst().ifPresentOrElse(
      t -> {
        log.info("Running transformation " + t.toString());
        try {
          t.run();
        } catch (DataTransformationException e) {
          log.error("Caught an unexpected error while running transformation", e);
        }
      },
      () -> {
        log.info("Transformation with name " + beanName + " not found");
      }
    );
  }
}
