FROM php:8.2-fpm
RUN docker-php-ext-install pdo pdo_mysql

RUN apt-get update && apt-get install -y \
		libfreetype-dev \
		libjpeg62-turbo-dev \
		libpng-dev \
		ssmtp \
		parallel \
	&& docker-php-ext-configure gd --with-freetype --with-jpeg \
	&& docker-php-ext-install -j$(nproc) gd

# install minimal procps (ps aux) and cleanup afterwards
RUN apt update && apt install --no-install-recommends -y procps && apt clean

WORKDIR /var/www/html
