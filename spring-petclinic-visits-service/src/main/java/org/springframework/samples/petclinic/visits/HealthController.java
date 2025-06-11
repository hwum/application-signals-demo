// File: spring-petclinic-visits-service/src/main/java/org/springframework/samples/petclinic/visits/HealthController.java
package org.springframework.samples.petclinic.visits;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HealthController {

  @GetMapping("/actuator/health")
  public ResponseEntity<String> health() {
    // Always return 500 error
    throw new RuntimeException("Health check failed");
  }
}
