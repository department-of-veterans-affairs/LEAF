# Use Alpine Linux 3.14 as the base image
FROM php:fpm-alpine3.19

# Update package index and install OpenJDK 11 and Maven
RUN apk update && apk add openjdk11 && apk add maven

COPY ../test/startup.sh /startup.sh
RUN chmod +x /startup.sh

# Set the working directory to /app
WORKDIR /app

# Copy the source code from the local machine to the container's /app directory
COPY ../test/Test-Automation/src src

# Copy the Project Object Model (POM) file to the container's /app directory
COPY ../test/Test-Automation/pom.xml .

# Define the entry point for the container, specifying Maven as the command to run
# ENTRYPOINT ["mvn"]

# Set the default command for the container to run the "test" goal when started
#CMD ["test"]

CMD ["/startup.sh"]