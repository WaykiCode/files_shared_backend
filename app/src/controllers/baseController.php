<?php namespace App\Controllers;

use Psr\Container\ContainerInterface;

class baseController{

  protected $container;

  public function __construct(ContainerInterface $c){
    $this->container = $c;
  }
};