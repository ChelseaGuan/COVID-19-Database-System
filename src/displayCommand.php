<?php
include_once("dbConnection.php");
class DisplayCommand extends AbstractCommand {

    public function execute(){
        $dbConn = new DBConnection();
        $conn = $dbConn->getConn();

        // Check if table exists
        $queryTableExists = "SELECT * FROM INFORMATION_SCHEMA.tables WHERE TABLE_SCHEMA = 'covid19_phcs' AND TABLE_NAME = '" . $this->tableName . "';";
        $resultTableExists = $conn->query($queryTableExists);
        if ($resultTableExists->num_rows == 0) {
            echo "The table does not exist.";
        }
        else {
            // Displaying a Person or a PublicHealthWorker requires joining tables so they have their own case.  
            switch ($this->tableName) {
                case "Person":
                    $query = "SELECT firstName, lastName, dateOfBirth, medicareNumber, phoneNumber, citizenship, email, address, city, province, postalCode 
                                FROM Person
                                LEFT JOIN LivesAt ON Person.id = LivesAt.personId
                                LEFT JOIN Address ON Address.addressId = LivesAt.addressId
                                WHERE Person.isDeleted=0;";
                    $result = $conn->query($query);
                    if ($result->num_rows > 0) {
                        // Output data of each row.
                        while($row = $result->fetch_assoc()) {
                          echo "firstName: " . $row["firstName"] . " | lastName: " . $row["lastName"] . " | dateOfBirth: " . $row["dateOfBirth"] . 
                          " | medicareNumber: " . $row["medicareNumber"] . " | phoneNumber: " . $row["phoneNumber"] . " | citizenship: " . $row["citizenship"] . 
                          " | email: " . $row["email"] . " | address: " . $row["address"] . " | city: " . $row["city"] . " | province: " . $row["province"] . 
                          " | postalCode: " . $row["postalCode"] . "<br>";
                        }
                    } 
                    else {
                        echo "0 results";
                      }
                break;

                case "PublicHealthWorker":

                    $query = "SELECT firstName, lastName, phcName, WorksAt.startDateTime, WorksAt.endDateTime
                                FROM Person, PublicHealthWorker, WorksAt, PublicHealthCenter
                                WHERE Person.id = PublicHealthWorker.phwId AND PublicHealthWorker.phwId = WorksAt.phwId AND PublicHealthCenter.phcId = WorksAt.phcId 
                                    AND Person.isDeleted=0 AND PublicHealthWorker.isDeleted=0;";
                    $result = $conn->query($query);
                    if ($result->num_rows > 0) {
                        // Output data of each row.
                        while($row = $result->fetch_assoc()) {
                          echo "firstName: " . $row["firstName"] . " | lastName: " . $row["lastName"] .
                          " | phcName: " . $row["phcName"] . " | startDateTime: " . $row["startDateTime"] . " | endDateTime: " . $row["endDateTime"] . "<br>";
                        }
                    } 
                    else {
                        echo "0 results";
                      }
                break;

                
                // The other tables can be displayed as is.
                default:
                    // Obtain column names.
                    $queryColumns = "SHOW COLUMNS FROM " . $this->tableName . ";";
                    $resultColumns = $conn->query($queryColumns);

                    while ($row = $resultColumns->fetch_assoc()) {
                        $columns[] = $row["Field"];
                    }
                    // Obtain table data.
                    $query = "SELECT * FROM " . $this->tableName . " WHERE isDeleted = 0;";
                    $result = $conn->query($query);
                
                    if ($result->num_rows > 0) {
                        // Output data of each row.
                        while ($row = $result->fetch_assoc()) {
                            foreach ($columns as $col) {
                                if ($col == "isDeleted") {
                                    continue;
                                }
                                echo $col . ": " . $row[$col] . " | ";
                            }
                            echo "<br>";
                        }
                    } 
                    else {
                        echo "0 results";
                    }
                
            }

        }
    }
}
    if (isset($_POST["command"])) new DisplayCommand();
?>


