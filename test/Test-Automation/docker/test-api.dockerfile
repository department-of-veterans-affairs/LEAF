FROM php:8.1.28-fpm-bullseye

# Update package index and install OpenJDK 11 and Maven
RUN apt update
RUN apt install -y openjdk-11-jdk maven

#COPY docker/startup.sh /startup.sh

COPY docker/index.php /var/www/html/selenium-tests/index.php
#RUN chmod +x /startup.sh

# Set the working directory to /app
WORKDIR /app
COPY docker/startup.sh startup.sh
RUN ["chmod", "+x", "startup.sh"]
# Copy the source code from the local machine to the container's /app directory
COPY src src


# Copy the Project Object Model (POM) file to the container's /app directory
# COPY pom.xml .
COPY pom.xml .
COPY testng.xml .

RUN chown -R www-data:www-data /app
RUN chown -R www-data:www-data /var/www

# Define the entry point for the container, specifying Maven as the command to run
# ENTRYPOINT 

CMD ["bash", "/app/startup.sh"]