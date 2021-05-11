<?php
// Abstract class that different types of SQL commands will inherit from.
abstract class AbstractCommand {
    protected $command; // E.g., insert, delete, edit, select.
    protected $args = array();  // Can be null depending on the command type, e.g., null for SELECT and DELETE, but requires values for INSERT and EDIT.
    protected $where;   // Used for the WHERE clause. Can be null.
    protected $tableName;

    function __construct() {
        $this->command = htmlspecialchars(trim($_POST["command"]));
        $this->tableName = htmlspecialchars(trim($_POST["tableName"]));
        $this->args = preg_split("/\s*;\s*/", htmlspecialchars(trim($_POST["args"])));  
        $this->where = htmlspecialchars(trim($_POST["where"]));
    }

    function __destruct() {
        try {
            echo $this->execute();
        } 
        catch (Exception $e) {
            echo $e->getMessage();
        }
    }

    abstract public function execute();
}

// Look in folder for the .php file corresponding to the required command and run it.
if (isset($_POST["command"])) {

    $command = htmlspecialchars(trim($_POST["command"]));

    $fileIterator = new FileSystemIterator(__DIR__, FileSystemIterator::SKIP_DOTS);

    $success = false;
    foreach ($fileIterator as $file) {
        if (is_int(strpos(strtolower($file->getFilename()), strtolower($command)))) {
            include $file->getFilename();
            $success = true;
            break;
        }
    }
    if (!$success) {
        echo "No such command found.";
    }
}