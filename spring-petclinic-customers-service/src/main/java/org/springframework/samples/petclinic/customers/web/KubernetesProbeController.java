// File: /Users/hwum/Desktop/OpenSource/CloudSmith/application-signals-demo/spring-petclinic-customers-service/src/main/java/org/springframework/samples/petclinic/customers/web/KubernetesProbeController.java

package org.springframework.samples.petclinic.customers.web;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class KubernetesProbeController {

  @GetMapping("/actuator/health")
  public String health() {
    // This will cause Kubernetes health checks to fail
    if (System.getenv("KUBERNETES_SERVICE_HOST") != null) {
      throw new RuntimeException("Health check intentionally failed");
    }
    return "{\"status\":\"UP\"}";
  }
}
