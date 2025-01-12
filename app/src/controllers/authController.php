<?php namespace App\Controllers;

use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;
use App\controllers\baseController;
use Firebase\JWT\JWT;

final class authController extends baseController {

  public function __invoke(Request $request, Response $response): Response {
    try {
      $body = $request->getParsedBody();
      $username = $body['username'];
      $tokenSettings = $this->container->get('tokenSettings');
      $pass = encript($tokenSettings, $body['pass']);
      
      $db = $this->container->get('db');

      $sql="select e_id_user, e_complete_name, e_email, e_pass, e_username, r_name, e_fk_role from vta_user where e_username='$username' and e_pass='$pass' and e_status=true;";

      $result = $db -> query($sql);
      $db = null;
      
      if($result -> rowCount() > 0){
        $data = $result -> fetch();
        
        $expire = (new \DateTime("now"))->modify("+8 hour")->format("Y-m-d H:i:s");
        $token = JWT::encode([
          "expired_at" => $expire,
          "idRole" => $data->e_fk_role,
          "id" => $data->e_id_user,
          "email" => $data->e_email,
          "pass" => $data->e_pass,
          "e_username" => $data->e_username,
        ], $tokenSettings->keyToToken);
        
        $response->getBody()->write(json_encode([
          "name" => $data->e_complete_name,
          "role" => $data->r_name,
          "email" => $data->e_email,
          "message" => "success",
          "token" => $token,
          "expire" => $expire,
        ]));
          
        return $response
          ->withHeader('Content-Type', 'application/json')
          ->withStatus(200);

      } else {
        $response->getBody()->write(json_encode(['message' => 'User or Pass Incorrect.']));
        
        return $response
          ->withHeader('Content-Type', 'application/json')
          ->withStatus(500);
      }
    } catch (PDOException $e) {
      $response->getBody()->write(json_encode(['message' => "We're sorry, but there was a problem with the PDOserver, please contact the system administrator.", 'error' => $e->getMessage()]));
        
      return $response
        ->withHeader('Content-Type', 'application/json')
        ->withStatus(500);
    };
  }
}