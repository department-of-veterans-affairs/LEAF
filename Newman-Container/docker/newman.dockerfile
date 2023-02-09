FROM node:19
RUN apt update
RUN apt install -y vim
# Set environment variables
ENV LANG="en_US.UTF-8" LANGUAGE="en_US.UTF-8" 

RUN npm install -g npm
RUN npm install -g newman
RUN npm install -g async

WORKDIR /var/newman/scripts
COPY ../scripts /var/newman/scripts

# ENTRYPOINT ["newman"]
