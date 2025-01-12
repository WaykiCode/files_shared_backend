<?php namespace App\middleware;

use Psr\Http\Message\ServerRequestInterface as Request;
use Psr\Http\Server\RequestHandlerInterface as RequestHandler;

use Slim\Psr7\Response;

class CheckRequestBodyAuth {
    public function _body(Request $request, RequestHandler $handler): Response
    {
        // Obtener el cuerpo de la solicitud
        $parsedBody = $request->getParsedBody();

        // Verificar si la clave está presente en el cuerpo de la solicitud
        if (!isset($parsedBody['username'])) {
            // Puedes mostrar un mensaje de error o tomar otra acción apropiada
            $response = new Response();

            $response->getBody()->write(json_encode(['message' => 'La clave username está ausente en el cuerpo de la solicitud.']));
            return $response
            ->withHeader('Content-Type', 'application/json')
            ->withStatus(400); // Código de respuesta 400 (Bad Request) u otro adecuado
        }

        if (!isset($parsedBody['pass'])) {
            $response = new Response();
            $response->getBody()->write(json_encode(['message' => 'La clave pass está ausente en el cuerpo de la solicitud.']));
            return $response
            ->withHeader('Content-Type', 'application/json')
            ->withStatus(400);
        }
        
        return $handler->handle($request);
    }
}

?>