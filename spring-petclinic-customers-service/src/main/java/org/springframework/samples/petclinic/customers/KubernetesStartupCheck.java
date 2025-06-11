package org.springframework.samples.petclinic.customers;

import org.springframework.boot.context.event.ApplicationStartedEvent;
import org.springframework.context.annotation.Profile;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Component;

@Component
@Profile("kubernetes")
public class KubernetesStartupCheck {

    @EventListener(ApplicationStartedEvent.class)
    public void checkKubernetesEnvironment() {
        // Check if running in Kubernetes by looking for environment variables
        if (System.getenv("KUBERNETES_SERVICE_HOST") != null || 
            System.getenv("ERROR_TRIGGER") != null) {
            
            // Throw an error to fail the service startup in Kubernetes
            throw new RuntimeException("Service intentionally failed to start in Kubernetes environment");
        }
    }
}