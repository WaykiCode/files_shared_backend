<?php namespace App\Controllers;

use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;
use App\controllers\baseController;

class filesController extends baseController{
  
  public function create(Request $request, Response $response, $args = []){
    
    try {
      $db = $this->container->get('db');
      
      $uploadedFiles = $request->getUploadedFiles();

      if (empty($uploadedFiles['file'])) {
        $response->getBody()->write(json_encode(['error' => 'No file uploaded']));
        return $response->withHeader('Content-Type', 'application/json')->withStatus(400);
      }

      $file = $uploadedFiles['file'];

      if ($file->getError() === UPLOAD_ERR_OK) {        
        $filename = uniqid() . "_" . $file->getClientFilename();
        $uploadDir = __DIR__ . '/../../uploads/';

        if (!is_dir($uploadDir)) {
          mkdir($uploadDir, 0755, true);
        }

        $file->moveTo($uploadDir . $filename);

        $fileUrl = "/uploads/" . $filename;

        $sqlNoRepeat="select p_filename from pdf_files where p_filename='".$filename."';";

        $resultNoRepeat = $db -> query($sqlNoRepeat);

        if($resultNoRepeat -> rowCount() > 0){
          $db = null;
          $response->getBody()->write(json_encode(['message' => 'Error, File with that name exist.']));
          
          return $response
            ->withHeader('Content-Type', 'application/json')
            ->withStatus(400);
        } else {
          
          $sql="INSERT INTO pdf_files (p_filename, p_file_url) VALUES (:filename, :file_url);";

          $result = $db -> prepare($sql) -> execute(['filename' => $filename, 'file_url' => $fileUrl]);

          if($result){
            audit($db, 'File save success: '.$filename, 'API_REST');

            $db = null;
            $response->getBody()->write(json_encode(['message' => 'success']));
          
            return $response
              ->withHeader('Content-Type', 'application/json')
              ->withStatus(200);
          } else {

            $db = null;
            $response->getBody()->write(json_encode(['message' => "We're sorry, but there was a problem save data, please contact the system administrator.", 'result' => $result]));
          
            return $response
              ->withHeader('Content-Type', 'application/json')
              ->withStatus(400);
          }
        }
      }

      $response->getBody()->write(json_encode(['message' =>'Upload failed']));
    
      return $response
        ->withHeader('Content-Type', 'application/json')
        ->withStatus(500);

    } catch (PDOException $e) {
      $response->getBody()->write(json_encode(['message' => "We're sorry, but there was a problem with the PDOserver, please contact the system administrator.", 'error' => $e->getMessage()]));
        
      return $response
        ->withHeader('Content-Type', 'application/json')
        ->withStatus(500);
    }
  }

  // public function update(Request $request, Response $response, $args = []){
    
  //   try {
  //     $db = $this->container->get('db');
      
  //     $id = $args['id'];

  //     $body = $this->toSave($request->getParsedBody());
  //     $body['id'] = $id;

  //     $sqlFound="select r_id_role from tbl_role where r_id_role='$id';";

  //     $resultFound = $db -> query($sqlFound);

  //     if($resultFound -> rowCount() == 0){
  //       $db = null;
  //       $response->getBody()->write(json_encode(['message' => 'Error, data not found in our database.']));
        
  //       return $response
  //         ->withHeader('Content-Type', 'application/json')
  //         ->withStatus(400);
  //     } else {
  //       $sql="UPDATE tbl_role set 
  //         r_name=:name, 
  //         r_status=:status,
  //         r_date_modify=now()
  //         where r_id_role=:id";
          
  //       $result = $db -> prepare($sql) -> execute($body);

  //       if($result){
  //         audit($db, 'Role update: '.$id.' success: '.$body['name'], 'API_REST');

  //         $db = null;
  //         $response->getBody()->write(json_encode(['message' => 'success', 'id' => $id]));
        
  //         return $response
  //           ->withHeader('Content-Type', 'application/json')
  //           ->withStatus(200);
  //       } else {

  //         $db = null;
  //         $response->getBody()->write(json_encode(['message' => "We're sorry, but there was a problem save data, please contact the system administrator.", 'result' => $result]));
        
  //         return $response
  //           ->withHeader('Content-Type', 'application/json')
  //           ->withStatus(400);
  //       }
  //     }

  //   } catch (PDOException $e) {
  //     $response->getBody()->write(json_encode(['message' => "We're sorry, but there was a problem with the PDOserver, please contact the system administrator.", 'error' => $e->getMessage()]));
        
  //     return $response
  //       ->withHeader('Content-Type', 'application/json')
  //       ->withStatus(500);
  //   }
  // }

  // public function delete(Request $request, Response $response, $args = []){
    
  //   try {
  //     $db = $this->container->get('db');
      
  //     $id = $args['id'];

  //     $sqlFound="select r_id_role from tbl_role where r_id_role='$id' and r_status=true;";

  //     $resultFound = $db -> query($sqlFound);

  //     if($resultFound -> rowCount() == 0){
  //       $db = null;
  //       $response->getBody()->write(json_encode(['message' => 'Error, data not found in our database.']));
        
  //       return $response
  //         ->withHeader('Content-Type', 'application/json')
  //         ->withStatus(400);
  //     } else {
        
  //       $sql="UPDATE tbl_role set r_status=false, r_date_modify=now() where r_id_role='$id'";
          
  //       $result = $db -> prepare($sql) -> execute();

  //       if($result){
  //         audit($db, 'Role delete: '.$id.' success', 'API_REST');

  //         $db = null;
  //         $response->getBody()->write(json_encode(['message' => 'success', 'id' => $id]));
        
  //         return $response
  //           ->withHeader('Content-Type', 'application/json')
  //           ->withStatus(200);
  //       } else {

  //         $db = null;
  //         $response->getBody()->write(json_encode(['message' => "We're sorry, but there was a problem save data, please contact the system administrator.", 'result' => $result]));
        
  //         return $response
  //           ->withHeader('Content-Type', 'application/json')
  //           ->withStatus(400);
  //       }
  //     }

  //   } catch (PDOException $e) {
  //     $response->getBody()->write(json_encode(['message' => "We're sorry, but there was a problem with the PDOserver, please contact the system administrator.", 'error' => $e->getMessage()]));
        
  //     return $response
  //       ->withHeader('Content-Type', 'application/json')
  //       ->withStatus(500);
  //   }
  // }

  // public function getAll(Request $request, Response $response, $args = []){
    
  //   try {
  //     $db = $this->container->get('db');

  //     $sql="select * from tbl_role;";

  //     $result = $db -> query($sql);
  //     $db = null;
      
  //     if($result -> rowCount() > 0){
  //       $data = $this->toViewAll($result -> fetchAll());

  //       $response->getBody()->write(json_encode(['message' => 'success', 'result' => $result -> rowCount(), 'data' => $data]));
        
  //       return $response
  //         ->withHeader('Content-Type', 'application/json')
  //         ->withStatus(200);

  //     } else {
  //       $response->getBody()->write(json_encode(['message' => 'Error, no results.']));
        
  //       return $response
  //         ->withHeader('Content-Type', 'application/json')
  //         ->withStatus(400);
  //     }
  //   } catch (PDOException $e) {
  //     $response->getBody()->write(json_encode(['message' => "We're sorry, but there was a problem with the PDOserver, please contact the system administrator.", 'error' => $e->getMessage()]));
        
  //     return $response
  //       ->withHeader('Content-Type', 'application/json')
  //       ->withStatus(500);
  //   }   
  // }

  // public function get(Request $request, Response $response, $args = []){
    
  //   try {
  //     $db = $this->container->get('db');

  //     $sql="select * from tbl_role where r_status=true;";

  //     $result = $db -> query($sql);
  //     $db = null;
      
  //     if($result -> rowCount() > 0){
  //       $data = $this->toViewAll($result -> fetchAll());

  //       $response->getBody()->write(json_encode(['message' => 'success', 'result' => $result -> rowCount(), 'data' => $data]));
        
  //       return $response
  //         ->withHeader('Content-Type', 'application/json')
  //         ->withStatus(200);

  //     } else {
  //       $response->getBody()->write(json_encode(['message' => 'Error, no results.']));
        
  //       return $response
  //         ->withHeader('Content-Type', 'application/json')
  //         ->withStatus(400);
  //     }
  //   } catch (PDOException $e) {
  //     $response->getBody()->write(json_encode(['message' => "We're sorry, but there was a problem with the PDOserver, please contact the system administrator.", 'error' => $e->getMessage()]));
        
  //     return $response
  //       ->withHeader('Content-Type', 'application/json')
  //       ->withStatus(500);
  //   }   
  // }

  // public function getById(Request $request, Response $response, $args = []){
    
  //   try {
  //     $id = $args['id'];
  //     $db = $this->container->get('db');

  //     $sql="select * from tbl_role where r_id_role='$id';";

  //     $result = $db -> query($sql);
  //     $db = null;
      
  //     if($result -> rowCount() > 0){
  //       $data = $this->toView($result -> fetch());

  //       $response->getBody()->write(json_encode(['message' => 'success', 'result' => $result -> rowCount(), 'data' => $data]));
        
  //       return $response
  //         ->withHeader('Content-Type', 'application/json')
  //         ->withStatus(200);

  //     } else {
  //       $response->getBody()->write(json_encode(['message' => 'Error, no results.']));
        
  //       return $response
  //         ->withHeader('Content-Type', 'application/json')
  //         ->withStatus(400);
  //     }
  //   } catch (PDOException $e) {
  //     $response->getBody()->write(json_encode(['message' => "We're sorry, but there was a problem with the PDOserver, please contact the system administrator.", 'error' => $e->getMessage()]));
        
  //     return $response
  //       ->withHeader('Content-Type', 'application/json')
  //       ->withStatus(500);
  //   }   
  // }

  // Create function to convert view
  private function toView ($result) {
    return [
      'id_role' => $result->r_id_role,
      'name' => $result->r_name,
      'status' => $result->r_status,
      'date_register' => $result->r_date_register,
      'date_modify' => $result->r_date_modify,
    ];
  }

  private function toViewAll ($data) {
    return array_map(function ($result) {
      return [
        'id_role' => $result->r_id_role,
        'name' => $result->r_name,
        'status' => $result->r_status,
        'date_register' => $result->r_date_register,
        'date_modify' => $result->r_date_modify,
      ];
    }, $data);
  }

  private function toSave ($result) {
    return [
      'name' => $result['name'],
      'status' => $result['status'],
    ];
  }

};
