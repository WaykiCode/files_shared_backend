<?php

use Slim\Routing\RouteCollectorProxy;
use App\middleware\JwtAuth;

$app->group('', function(RouteCollectorProxy $group){
	$group->get('/', 'App\controllers\startController:info');
	
	$group->post('/auth', 'App\controllers\authController')
				->add('App\middleware\CheckRequestBodyAuth:_body');

});

$app->group('/files', function(RouteCollectorProxy $group){
	
	$group->post('/upload', 'App\controllers\filesController:create');

	// $group->put('/update/{id}', 'App\controllers\roleController:update')
	// 			->add('App\middleware\CheckRequestBodyRole:_body')
	// 			->add(JwtAuth::class);

	// $group->delete('/delete/{id}', 'App\controllers\roleController:delete')
	// 			->add(JwtAuth::class);
	
	// $group->get('/getAll', 'App\controllers\roleController:getAll')
	// 			->add(JwtAuth::class);

	// $group->get('/get', 'App\controllers\roleController:get')
	// 			->add(JwtAuth::class);

	// $group->get('/get/{id}', 'App\controllers\roleController:getById')
	// 			->add(JwtAuth::class);

	// $group->get('/getByIdDepartment/{id}', 'App\controllers\roleController:getByIdDepartment')
	// 			->add(JwtAuth::class);
});


