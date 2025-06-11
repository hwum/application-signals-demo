// File: spring-petclinic-visits-service/src/main/java/org/springframework/samples/petclinic/visits/BrokenHealthIndicator.java
package org.springframework.samples.petclinic.visits;

import org.springframework.boot.actuate.health.Health;
import org.springframework.boot.actuate.health.HealthIndicator;
import org.springframework.stereotype.Component;

@Component
public class BrokenHealthIndicator implements HealthIndicator {

  @Override
  public Health health() {
    // Always return DOWN status
    return Health.down()
        .withDetail("error", "Service intentionally broken")
        .build();
  }
}
