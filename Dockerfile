# Utiliza la imagen base de PHP con Apache
FROM php:8.0.30-apache

# Instala las dependencias necesarias
RUN apt-get update && apt-get install -y \
    libpq-dev \
    libzip-dev \
    libjpeg-dev \
    libpng-dev \
    zlib1g-dev \
    unzip \
    p7zip-full \
    git \
    nano \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Instala las extensiones necesarias para MySQL
RUN docker-php-ext-install pdo pdo_mysql zip gd

# Instala Composer en el contenedor
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Habilitar el módulo mod_rewrite
RUN a2enmod rewrite

# Copia el contenido de tu proyecto al directorio del servidor web
COPY ./app/ /var/www/html

# Copia el archivo .env a la ubicación necesaria
COPY .env /var/www/html/src/app/.env

# Establece el directorio de trabajo
WORKDIR /var/www/html

# Instala las dependencias de Composer automáticamente
RUN composer install --no-interaction --prefer-dist --optimize-autoloader

# Modifica DocumentRoot para apuntar a /public
RUN sed -i 's|DocumentRoot /var/www/html|DocumentRoot /var/www/html/public|g' /etc/apache2/sites-available/000-default.conf

# Agrega la directiva ServerName al archivo apache2.conf
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Reinicia Apache para aplicar los cambios
CMD ["apache2-foreground"]
