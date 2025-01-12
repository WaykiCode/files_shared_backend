# files_shared_backend
Backend para el proyecto

## Versiones Usadas
mysql:8.3.0
php:8.2.11-apache

## En el caso de no encontrar el archivo .env en la raiz del proyecto
copiar el archivo .env_example

## Para iniciar Docker
docker-compose up --build

Una vez realizado, puede ingresarse a la consola del docker e instalar las dependencias de composer
  -composer install

Despues de ejecutar por favor editar al archivo: 
  - /etc/apache2/sites-available/000-default.conf

  y agrear public en la linea de DocumentRoot
  - DocumentRoot /var/www/html/public

  Reiniciar Apache

## Para entrar a la consola
docker exec -i -t idContenedor /bin/bash 

## Para instalar las dependencias del Framework slim
composer install

## Cambiar las credenciales de BD en:
app/src/app/.env

## En caso de problemas con dotenv:
copiar el archivo .env a la caperta app/src/app/.env

## Informacion adicional acerca del In
// Generar un nuevo IV aleatorio
$token_iv = base64_encode(openssl_random_pseudo_bytes(16)); // 16 bytes para AES-256-CBC

// Usa $token_iv en tu proceso de cifrado
echo "Nuevo IV: $token_iv\n";