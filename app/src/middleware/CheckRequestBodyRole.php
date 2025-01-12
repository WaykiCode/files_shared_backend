<?php namespace App\middleware;

use Psr\Http\Message\ServerRequestInterface as Request;
use Psr\Http\Server\RequestHandlerInterface as RequestHandler;
use Slim\Psr7\Response;

class CheckRequestBodyRole {
    public function _body(Request $request, RequestHandler $handler): Response
    {
        // get body of request
        $parsedBody = $request->getParsedBody();

        if (!array_key_exists('name', $parsedBody)) {
            $response = new Response();
            $response->getBody()->write(json_encode(['message' => 'La clave name está ausente en el cuerpo de la solicitud.']));
            return $response
            ->withHeader('Content-Type', 'application/json')
            ->withStatus(400);
        }

        if (!array_key_exists('status', $parsedBody)) {
            $response = new Response();
            $response->getBody()->write(json_encode(['message' => 'La clave status está ausente en el cuerpo de la solicitud.']));
            return $response
            ->withHeader('Content-Type', 'application/json')
            ->withStatus(400);
        }

        return $handler->handle($request);
    }
}

?>