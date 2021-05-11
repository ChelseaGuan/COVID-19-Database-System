<?php
class DBConnection {
protected $conn;

function __construct(){
    $this->connect();
}

protected function connect() {
    $hostname = "localhost:3306";
    $username = "root";
    $password = "!2SgAcF@T28VBHU";
    $dbname = "covid19_PHCS";

    if (!isset($this->conn)) { 
        $this->conn = new mysqli($hostname, $username, $password, $dbname); 
    }

    if ($this->conn->connect_errno) {
        trigger_error('Database connection failed: ' . $this->conn->connect_error);
        exit();
    }    
}

function __destruct(){
    $this->conn->close();
}

function getConn(){
     if (!isset($this->conn)) { 
        $this->connect(); 
     }
     return $this->conn;
  }
}
  
?>