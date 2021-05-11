<?php
include_once("dbConnection.php");
class EditCommand extends AbstractCommand {

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

            switch ($this->tableName) {
                case "Person":
                    
                    $query = "UPDATE Person, LivesAt, Address
                                SET " . $this->args[0] . "='" . $this->args[1] . 
                                "' WHERE " . $this->where . " AND Person.id = LivesAt.personId AND Address.addressId = LivesAt.addressId;";
                    break;

                case "PublicHealthWorker":
                
                    $query = "UPDATE Person, PublicHealthWorker, WorksAt, PublicHealthCenter
                                SET " . $this->args[0] . "='" . $this->args[1] . 
                                "' WHERE " . $this->where . " AND Person.id = PublicHealthWorker.phwId AND PublicHealthWorker.phwId = WorksAt.phwId;";
                    break;

                case "GroupZone":
            
                    $query = "UPDATE Person, GroupZone
                                SET " . $this->args[0] . "='" . $this->args[1] . 
                                "' WHERE " . $this->where . " AND Person.id = GroupZone.personId;";
                    break;
    

                default:
                // Insert passed values into passed columns.
                $query = "UPDATE " . $this->tableName . " SET " . $this->args[0] . "='" . $this->args[1] . "' WHERE " . $this->where . ";";     
            }

            $conn->query($query);    
            echo "Entry (entries) edited.";            
        }
    }
}
    if (isset($_POST["command"])) new EditCommand();
?>