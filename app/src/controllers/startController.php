<?php namespace App\Controllers;

use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;

class startController{
  public function info(Request $request, Response $response, $args = []){
     $response->getBody()->write("App it's on!");
     return $response;
  }
};