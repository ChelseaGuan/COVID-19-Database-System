<?php
include_once("dbConnection.php");
class CreateCommand extends AbstractCommand {

    public function execute() {
        $dbConn = new DBConnection();
        $conn = $dbConn->getConn();
        
        // Check if table exists
        $queryTableExists = "SELECT * FROM INFORMATION_SCHEMA.tables WHERE TABLE_SCHEMA = 'tdc353_4' AND TABLE_NAME = '" . $this->tableName . "';";
        $resultTableExists = $conn->query($queryTableExists);
        if ($resultTableExists->num_rows == 0) {
            echo "The table does not exist.";
        }

        // Check if user input is missing the list of column names, the list of column values or both.
        else if ($this->args[0] === "" || $this->args[1] === "") {
            echo "Missing arguments for column names and/or column values.";
        }
            
        else {
            // Check if the length of the list of column names is equal to that of the list of column values.
            $columns = preg_split("/\s*,\s*/", $this->args[0]);
            $values = preg_split("/\s*,\s*/", $this->args[1]);

            // Needed for 6. since health recommendations can include commas.
            if ($this->tableName == "HealthRecommendations") {
                $values = [$this->args[1]];
            }
            if (count($columns) != count($values)) {
                echo "Number of column names and column values are not equal.";
            }
            
            // Insert passed values into passed columns.
            else {  

                switch ($this->tableName) {
                    // For 7. Set a new alert for a specific region, use args input format: 
                    // region, alertState, alertDate; Montreal, 3, 2021-04-14 (if not provided, date defaults to present date)
                    case "Region":
                        $region = $values[0];
                        $newAlertState = $values[1]; 
                        
                        if ($newAlertState < 1 || $newAlertState > 4) {
                            echo "An alert can only have values 1, 2, 3 or 4.";
                            break;
                        }
                        else {
                            $query = "SELECT MAX(alertState) FROM Region WHERE region = '" . $region . "';";
                            $result = $conn->query($query);
                            if ($result->num_rows > 0) {
                                while($row = $result->fetch_assoc()) {
                                    $oldAlertState = $row["MAX(alertState)"];
                                }
                            } 
                            if (abs($newAlertState - $oldAlertState) != 1) {
                                echo "An alert can only be upgraded or downgraded one level at a time.";
                                break;
                            }
                        }
                        
                    default:
                        $query = "INSERT INTO " . $this->tableName . " (" . $this->args[0] . ") " . "VALUES (";
                        for ($i = 0; $i < count($values) - 1; $i++) {
                            $query .= "'" . $values[$i] . "',";              
                        }
                        $query .= "'" . $values[count($values) - 1] . "');";
                        $conn->query($query);
                        echo "Entry created.";
                    }
            }
        }
    }
}
    if (isset($_POST["command"])) new CreateCommand();
?>