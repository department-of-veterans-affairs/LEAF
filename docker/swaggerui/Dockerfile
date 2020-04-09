FROM node:8

MAINTAINER Lilly Wang <liping.wang@ablevets.com>

ENV SWAGGER_UI_VERSION 3.2.2
ENV SWAGGER_SPEC_PATH /swaggerui/swagger/

# Create app directories and install unzip
RUN mkdir -p /usr/src/app && \
    mkdir -p /swaggerui/swagger && \
    apt-get update && \
    apt-get install -y unzip

WORKDIR /swaggerui

# Download Swagger UI
#ADD https://github.com/swagger-api/swagger-ui/archive/v${SWAGGER_UI_VERSION}.zip /swaggerui/${SWAGGER_UI_VERSION}.zip
COPY /docker/swaggerui/src/nexus-swagger.json /swaggerui/swagger/nexus-swagger.json
COPY /docker/swaggerui/src/portal-swagger.json /swaggerui/swagger/portal-swagger.json

# Unzip Swagger archive, copy dist files, and change the default endpoint
# from LEAF_Nexus to the local API
#RUN unzip ${SWAGGER_UI_VERSION}.zip && \
#    rm ${SWAGGER_UI_VERSION}.zip && \
#    mv swagger-ui-${SWAGGER_UI_VERSION}/dist/* . && \
#    rm -r swagger-ui-${SWAGGER_UI_VERSION}/ && \
#    sed -i "s|https://localhost/LEAF_Nexus/nexus-swagger.json|/spec|g" index.html

COPY /docker/swaggerui/dist/* ./

WORKDIR /usr/src/app

# Install app dependencies
COPY /docker/swaggerui/src/package.json .
RUN npm install
RUN npm install cors

# Bundle app source
COPY /docker/swaggerui/src/server.js .

#RUN chmod +x /usr/src/app


EXPOSE 8080
CMD ["npm", "start"]
