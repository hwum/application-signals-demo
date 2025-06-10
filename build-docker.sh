#!/bin/bash
# Create a file named build-docker.sh in the project root
set -e

# Clean up JAR files
cleanup() {
  echo "Cleaning up JAR files..."
  mvn clean
  echo "Cleanup complete"
}

# Call cleanup function
cleanup
# Skip OpenTelemetry Collector check
echo "Skipping OpenTelemetry Collector check"

# Build the JAR first
mvn clean package -DskipTests

# Build Docker images for each module
for module in spring-petclinic-admin-server spring-petclinic-customers-service spring-petclinic-vets-service spring-petclinic-visits-service spring-petclinic-config-server spring-petclinic-discovery-server spring-petclinic-api-gateway; do
  echo "Building Docker image for $module"
  cp $module/target/$module-*.jar docker/
  docker build -t springcommunity/$module \
    --build-arg ARTIFACT_NAME=$module-2.6.7 \
    --build-arg EXPOSED_PORT=9090 \
    --build-arg DOCKERIZE_VERSION=v0.6.1 \
    docker/
  rm docker/$module-*.jar
done

echo "All Docker images built successfully"

