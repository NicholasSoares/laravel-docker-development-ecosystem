FROM php:7.4-fpm

USER root
# Copy composer.lock and composer.json into the working directory
COPY composer.lock composer.json /var/www/html/

# Set working directory
WORKDIR /var/www/html/

# Install dependencies for the operating system software
RUN apt-get update && apt-get install -y \
 build-essential \
 libpng-dev \
 libjpeg62-turbo-dev \
 libfreetype6-dev \
 locales \
 zip \
 jpegoptim optipng pngquant gifsicle \
 vim \
 libzip-dev \
 unzip \
 git \
 libonig-dev \
 curl

# Install node 12 into the application
RUN apt-get update -yq \
    && apt-get -yq install curl gnupg ca-certificates \
    && curl -L https://deb.nodesource.com/setup_12.x | bash \
    && apt-get update -yq \
    && apt-get install -yq nodejs

# Install node extensions
COPY ./package*.json ./
COPY ./webpack.mix.js ./

RUN npm install

# change node modules user group for the app standard
RUN chown -R www-data:www-data /var/www/html/node_modules

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install extensions for php
RUN docker-php-ext-install pdo_mysql mbstring zip exif pcntl
RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-install gd

# Install composer (php package manager)
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copy existing application directory composer dependency filers
COPY composer.json composer.json
COPY composer.lock composer.lock

# Copy existing application directory contents to the working directory
COPY . /var/www/html

# Assign permissions of the working directory to the www-data user
RUN chown -R www-data:www-data /var/www/

#change user to default aplication user and group for runtime enviroment
USER www-data

# configure node dependent resources with application default user
RUN npm run prod

# Install composer application dependencies
RUN composer install

# HEALTHCHECK setup
HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost/ || exit 1

# Expose port 9000 and start php-fpm server (for FastCGI Process Manager)
EXPOSE 9000

CMD ["php-fpm"]
