<?php
require __DIR__ . '/../../vendor/autoload.php';

use DI\Container;
use Slim\Factory\AppFactory;

use Psr\Http\Message\ServerRequestInterface;
use Slim\Exception\HttpNotFoundException;
use Slim\Exception\HttpMethodNotAllowedException;
use Slim\Psr7\Response;

use Psr\Http\Message\ServerRequestInterface as Request;
use Psr\Http\Server\RequestHandlerInterface;
use Slim\Routing\RouteCollectorProxy;
use Slim\Routing\RouteContext;
use Spipu\Html2Pdf\Html2Pdf;
use Phplot\Phplot;


date_default_timezone_set('America/Guayaquil');

// Create Container using PHP-DI
$auxContainer = new Container();

// Set container to create App with on AppFactory
AppFactory::setContainer($auxContainer);

// Cargar variables de entorno desde el archivo .env
$dotenv = Dotenv\Dotenv::createImmutable(__DIR__ . '');
$dotenv->load();

$app = AppFactory::create();
$app->addBodyParsingMiddleware();

$app->options('/{routes:.+}', function ($request, $response, $args) {
  return $response;
});

// Habilita CORS (Cross-Origin Resource Sharing)
$app->add(function ($request, $handler) {
  $response = $handler->handle($request);
  return $response
      ->withHeader('Access-Control-Allow-Origin', 'http://localhost:4200') // Reemplaza con el origen de tu aplicación Angular
      ->withHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization')
      ->withHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE')
      ->withHeader('Access-Control-Allow-Credentials', 'true');

});

$app->addRoutingMiddleware();

$errorMiddleware = $app->addErrorMiddleware(true, true, true);

// Set the Not Found Handler
$errorMiddleware->setErrorHandler(
  HttpNotFoundException::class,
  function (ServerRequestInterface $request, Throwable $exception, bool $displayErrorDetails) {
      $response = new Response();
      $response->getBody()->write(json_encode(['message' => '404 NOT FOUND']));

      return $response
      ->withHeader('Content-Type', 'application/json')
      ->withStatus(404);
  }
);

// Set the Not Allowed Handler
$errorMiddleware->setErrorHandler(
  HttpMethodNotAllowedException::class,
  function (ServerRequestInterface $request, Throwable $exception, bool $displayErrorDetails) {
      $response = new Response();
      $response->getBody()->write(json_encode(['message' => '405 NOT ALLOWED']));

      return $response
      ->withHeader('Content-Type', 'application/json')
      ->withStatus(405);
  }
);

$container = $app->getContainer();

require __DIR__ . '/routes.php';
require __DIR__ . '/configs.php';
require __DIR__ . '/dependencies.php';
require __DIR__ . '/functions.php';
require __DIR__ . '/../services/audit.php';

$app->run();