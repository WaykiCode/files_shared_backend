<?php

use Psr\Container\ContainerInterface;
use Tuupola\Middleware\JwtAuthentication;

$container -> set('db', function(ContainerInterface $c){
  $config = $c->get('db_settings');

  $dbHost = $config->DB_HOST;
  $dbPort = $config->DB_PORT;
  $dbDatabase = $config->DB_DATABASE;
  $dbUser = $config->DB_USER;
  $dbPass = $config->DB_PASS;

  $opt = [
    PDO:: ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_OBJ,
  ];

  $dsn = "mysql:host=$dbHost;port=$dbPort;dbname=$dbDatabase";

  return new PDO($dsn, $dbUser, $dbPass, $opt);
});

$container -> set('JwtAuthentication', function(ContainerInterface $c):  JwtAuthentication{
  return $c->get('jwt_authentication');
});

$container -> set('tokenSettings', function(ContainerInterface $c){
  return $c->get('token_settings');
});