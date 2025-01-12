<?php
use Firebase\JWT\JWT;
use Firebase\JWT\Key;

function encript($tokenSettings, $text){
    $encrypted = openssl_encrypt($text, $tokenSettings->method, $tokenSettings->key, false, $tokenSettings->iv);
    return $encrypted;
};


function unencript($tokenSettings, $text){
    $decrypted = openssl_decrypt($text, $tokenSettings->method, $tokenSettings->key, false, $tokenSettings->iv);
    return $decrypted;
};

function getTokenInfo($request, $tokenSettings){
  $pass = $tokenSettings->keyToToken;

  $header = $request->getHeader("Authorization");
  $bearer = trim($header[0]);
  preg_match("/Bearer\s(\S+)/", $bearer, $matches);
  $token = $matches[1];
  
  $key = new Key($pass, "HS256");
  $dataToken = JWT::decode($token, $key);

  return $dataToken;
};