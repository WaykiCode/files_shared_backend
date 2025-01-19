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
	
	$group->put('/recover/{id}', 'App\controllers\filesController:recover');

	$group->get('/get', 'App\controllers\filesController:get');

	$group->get('/getInactive', 'App\controllers\filesController:getInactive');

	$group->get('/uploads/{filename}', 'App\controllers\filesController:getFile');
	
	$group->delete('/delete/{id}', 'App\controllers\filesController:delete');

	$group->delete('/deletePermanent/{id}', 'App\controllers\filesController:deletePermanent');
	
	// $group->get('/getAll', 'App\controllers\roleController:getAll')
	// 			->add(JwtAuth::class);
	
	// $group->get('/get/{id}', 'App\controllers\roleController:getById')
	// 			->add(JwtAuth::class);

	// $group->get('/getByIdDepartment/{id}', 'App\controllers\roleController:getByIdDepartment')
	// 			->add(JwtAuth::class);
});


