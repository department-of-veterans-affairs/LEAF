# Use Alpine Linux 3.14 as the base image
FROM php:fpm-alpine3.19

# Update package index and install OpenJDK 11 and Maven
RUN apk update && apk add openjdk11 && apk add maven

COPY startup.sh /startup.sh
RUN chmod +x /startup.sh
RUN chmod +x /var/www/html/
RUN chown -R www-data:www-data /var/www
RUN chmod -R g+rwX /var/www

# Set the working directory to /app
WORKDIR /app

# Copy the source code from the local machine to the container's /app directory
COPY src src

# Copy the Project Object Model (POM) file to the container's /app directory
COPY pom.xml .

# Define the entry point for the container, specifying Maven as the command to run
# ENTRYPOINT 

# Set the default command for the container to run the "test" goal when started
#CMD ["test"]

CMD "/startup.sh"