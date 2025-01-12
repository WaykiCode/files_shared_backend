<?php

function audit($db, $action, $user){

  //Audit logs
  $sqlAudit = "INSERT INTO tbl_audit (u_id_audit, u_action, u_user) 
    VALUES (uuid(), ?, ?); ";

  $result = $db -> prepare($sqlAudit) -> execute([$action, $user]);

  $result = null;
  $db = null;

}
  
