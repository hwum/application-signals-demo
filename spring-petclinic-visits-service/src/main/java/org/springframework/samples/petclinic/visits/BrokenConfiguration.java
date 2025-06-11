// File: spring-petclinic-visits-service/src/main/java/org/springframework/samples/petclinic/visits/BrokenConfiguration.java
package org.springframework.samples.petclinic.visits;

import javax.sql.DataSource;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

@Configuration
public class BrokenConfiguration {

  @Bean
  public DataSource dataSource() {
    // Invalid database connection
    HikariConfig config = new HikariConfig();
    config.setJdbcUrl("jdbc:mysql://non-existent-host:3306/db");
    config.setUsername("invalid");
    config.setPassword("invalid");
    config.setMaximumPoolSize(0); // Invalid pool size
    return new HikariDataSource(config);
  }
}
