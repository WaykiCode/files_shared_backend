<?php

$container -> set('db_settings', function(){
  return (object)[
    "DB_HOST" => $_ENV['DB_HOST'],
    "DB_PORT" => $_ENV['DB_PORT_DOCKER'],
    "DB_DATABASE" => $_ENV['DB_DATABASE'],
    "DB_USER" => $_ENV['DB_USERNAME'],
    "DB_PASS" => $_ENV['DB_PASSWORD'],
  ];
});

$container -> set('jwt_authentication', function(){
  return (object)[
    'secret' => $_ENV['JWT_SECRET'],
    'algorithm' => 'HS256',
    'secure' => false, // only for localhost for prod and test env set true
    'error' => static function ($response, $arguments) {
        $data['status'] = 401;
        $data['error'] = 'Unauthorized/'. $arguments['message'];
        return $response
            ->withHeader('Content-Type', 'application/json;charset=utf-8')
            ->getBody()->write(json_encode(
                $data,
                JSON_THROW_ON_ERROR | JSON_UNESCAPED_SLASHES | JSON_PRETTY_PRINT
            ));
    }
  ];
});

$container -> set('token_settings', function(){
  return (object)[
    'key' => $_ENV['TOKEN_KEY'],
    'method' => 'aes-256-cbc',
    'iv' => base64_decode($_ENV['TOKEN_IV']),
    'keyToToken' => $_ENV['TOKEN_KEY_TOKEN'], //Copiar este codigo dentro de middleware/JwtAuth.php linea: 28
  ];
});