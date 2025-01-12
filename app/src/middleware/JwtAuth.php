<?php namespace App\middleware;

use Slim\Psr7\Response as Response;
use Psr\Http\Message\ServerRequestInterface as Request;
use Psr\Http\Server\RequestHandlerInterface as RequestHandler;

use Firebase\JWT\JWT;
use Firebase\JWT\Key;

final class JwtAuth {
  private Response $response;

  public function __construct(Response $response) {
    $this->response = $response;
  }

  public function __invoke(Request $request, RequestHandler $han) {
    try {
      if ($request->hasHeader("Authorization")):
        $header = $request->getHeader("Authorization");
        
        if (!empty($header)):
          $bearer = trim($header[0]);
          preg_match("/Bearer\s(\S+)/", $bearer, $matches);
          $token = $matches[1];
          
          $key = new Key("f1L3sSh@r3s.T0k3n.2025", "HS256");
          $dataToken = JWT::decode($token, $key);
          $now = (new \DateTime("now"))->format("Y-m-d H:i:s");
          
          if ($dataToken->expired_at < $now):
            $this->response->getBody()->write(json_encode([
              "Error" => [
                "Message" => "Token Expirado!"
              ]]));
              
            return $this->response
              ->withHeader("Content-Type", "application/json")
              ->withStatus(401);

            endif;
          endif;
          else:
            $this->response->getBody()->write(json_encode([
              "Error" => [
                "Message" => "Acesso No Autorizado!"
              ]
            ]));
              
            return $this->response
              ->withHeader('Content-Type', 'application/json')
              ->withStatus(401);
            endif;
    } catch (\Exception $e) {
      $this->response->getBody()->write(json_encode([
        "Error" => [
          "Message" => $e->getMessage()
        ]
      ]));
        
      return $this->response
        ->withHeader('Content-Type', 'application/json')
        ->withStatus(500);
    }
    $res = $han->handle($request);
    return $res;
  }
}