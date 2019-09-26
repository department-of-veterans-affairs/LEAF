FROM phpdockerio/php71-fpm:latest
MAINTAINER Dastan Rahimi <dastan.rahimi@ablevets.com>

# Install selected extensions and other stuff
RUN apt-get update \
    && apt-get -y --no-install-recommends install zip unzip php7.1-mysql php7.1-intl php7.1-mbstring php7.1-sqlite3\
    && apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*


WORKDIR "/var/www/leaf/"
