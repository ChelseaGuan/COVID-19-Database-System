<?php
include_once("dbConnection.php");
class DeleteCommand extends AbstractCommand {

    public function execute() {
        $dbConn = new DBConnection();
        $conn = $dbConn->getConn();
        
        // Check if table exists
        $queryTableExists = "SELECT * FROM INFORMATION_SCHEMA.tables WHERE TABLE_SCHEMA = 'tdc353_4' AND TABLE_NAME = '" . $this->tableName . "';";
        $resultTableExists = $conn->query($queryTableExists);
        if ($resultTableExists->num_rows == 0) {
            echo "The table does not exist.";
        }

        // Check if user input for WHERE clause is empty.
        else if ($this->where === "") {         
            echo "Missing where clause.";
        }
            
        else {
            // Insert passed values into passed columns.
            $query = "UPDATE " . $this->tableName . " SET isDeleted=1 WHERE " . $this->where . ";";
            $conn->query($query); 
            echo "Entry (entries) deleted.";   
        }
        
    }
}
    if (isset($_POST["command"])) new DeleteCommand();
?>