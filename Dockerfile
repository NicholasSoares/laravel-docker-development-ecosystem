FROM php:7.4-fpm

# Arguments defined in docker-compose.yml
ARG user

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip

# Install node 16 into the application
RUN apt-get update -yq \
    && apt-get -yq install curl gnupg ca-certificates \
    && curl -L https://deb.nodesource.com/setup_16.x | bash \
    && apt-get update -yq \
    && apt-get install -yq nodejs

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create system user to run Composer and Artisan Commands
RUN mkdir -p /home/$user/.composer && \
    chown -R $user:$user /home/$user

# Set working directory
WORKDIR /var/www

USER $user
