FROM php:8.1.28-fpm-bullseye

# Update package index and install OpenJDK 11 and Maven
RUN apt update
RUN apt install -y openjdk-11-jdk maven

COPY startup.sh /startup.sh
RUN chmod +x /startup.sh

# Set the working directory to /app
WORKDIR /app

# Copy the source code from the local machine to the container's /app directory
COPY src src

# Copy the Project Object Model (POM) file to the container's /app directory
COPY pom.xml .
RUN mvn clean install

# Define the entry point for the container, specifying Maven as the command to run
# ENTRYPOINT 

# Set the default command for the container to run the "test" goal when started
#CMD ["test"]

CMD "/startup.sh"