FROM php:8.1.28-fpm-bullseye

# Update package index and install OpenJDK 11 and Maven
RUN apt update
RUN apt install -y openjdk-11-jdk maven

COPY ./docker/selenium-tests/index.php /var/www/html/selenium-tests/index.php
#RUN chmod +x /startup.sh

# Set the working directory to /app
WORKDIR /app
COPY ./docker/selenium-tests/startup.sh startup.sh
RUN ["chmod", "+x", "startup.sh"]

# Copy the source code from the local machine to the container's /app directory
COPY ./test/Test-Automation/src src


# Copy the Project Object Model (POM) file to the container's /app directory
COPY ./test/Test-Automation/pom.xml .
COPY ./test/Test-Automation/testng.xml .

RUN chown -R www-data:www-data /app
RUN chown -R www-data:www-data /var/www

# Define the entry point for the container, specifying Maven as the command to run
# ENTRYPOINT 

CMD ["bash", "/app/startup.sh"]