<?php
include_once("dbConnection.php");
class FollowUpCommand extends AbstractCommand {

    function is_input_valid($medicareNum, $dob) : bool {
        $error_message = "";
        $isValid = true;
        if(strlen($medicareNum) != 14) {
            $isValid = false;
            $error_message .= "Medicare number was not in the correct format, try again. <br />";
        }

        if(strlen($dob) != 10){
            $isValid = false;
            $error_message .= "Date of birth was not in the correct format, try again.";
        }
        echo $error_message;
        return $isValid;
    }


    public function execute() {
        session_start();
        $dbConn = new DBConnection();
        $conn = $dbConn->getConn();
        $personId = null;

        // Check if table exists
        switch($this->tableName) {
            case "Person":
                $medicareNumber = $this->args[0];
                $dob = $this->args[1];
                if(!$this->is_input_valid($medicareNumber, $dob)) {
                    break;
                }
                $_SESSION["user"] = $medicareNumber;
                $queryisMatchFound = "SELECT * FROM Person WHERE  medicareNumber ='" . $medicareNumber ."' AND dateOfBirth ='"  . $dob . "';";
                $resultMatchFound = $conn->query($queryisMatchFound);
                if($resultMatchFound == false) {
                    echo "An error occured when processing your query."; //Should never be echoed.
                    return;
                }
                if ($resultMatchFound->num_rows == 0) {
                    echo "No match was found...";
                }
                else {
                    while($row = $resultMatchFound->fetch_assoc()) { //only one match should exist
                        $personId = $row["id"];
                        echo "<p style = \"margin-top:10px;\">Person Found! <br />firstName: ". $row["firstName"] . "\t|\tlastName: ". $row["lastName"] ."\t|\tDate of Birth: ". $row["dateOfBirth"] . "\t|\t
                        medicareNumber: ". $row["medicareNumber"] . "\t|\tPhone Number: ". $row["phoneNumber"] . "\t|\tCitizenship: ". $row["citizenship"] ."\t|\tEmail: ". $row["email"]."<br /></p>";
                    }
                }
                // Query to check if there is a positive active (within past 14 days) diagnosis 
                $today = date_create();
                $min_date_temp = date_sub($today, date_interval_create_from_date_string('14 days'));
                $min_date = date_format($min_date_temp, 'Y-m-d');
                // To uncomment: 
                $queryDiagnosis = "SELECT * FROM Diagnosis WHERE  personId ='" . $personId ."' AND testResult = 'positive' AND testResultDate >='"  . $min_date . "';";
                //$queryDiagnosis = "SELECT * FROM Diagnosis WHERE  personId ='" . $personId ."' LIMIT 1;";
                $resultDiagnosis = $conn->query($queryDiagnosis);
                if ($resultDiagnosis->num_rows == 0) {
                    echo "No positive test results within the past 14 days for this person.<br />";
                }
                else {
                    // Obtain column names.
                    $queryColumns = "SHOW COLUMNS FROM Diagnosis;";
                    $resultColumns = $conn->query($queryColumns);
                    while ($row = $resultColumns->fetch_assoc()) {
                        $columns[] = $row["Field"];
                    }
                    while ($row = $resultDiagnosis->fetch_assoc()) {;
                        echo "Test result was found <br />";
                        foreach ($columns as $col) {
                            if ($col == "isDeleted") {
                                continue;
                            }
                            echo $col . ": " . $row[$col] . " | ";
                        }
                        echo "<br>";
                    }
                }
                break;
            case "Symptoms":
                $query = "SELECT * FROM ". $this->tableName .";";
                $queryResult = $conn->query($query);
                if($queryResult == false) {
                    echo "An error occured when processing your query."; // Should never be echoed.
                    return;
                }
                if ($queryResult->num_rows == 0) {
                    echo "No match was found...";
                }
                else {
                    while($row = $queryResult->fetch_assoc()) { // Only one match should exist
                        echo "Symptom Name: ". $row["symptom"] . "\t|\ttype: ". $row["symptomType"] ."<br />";
                    }
                }
                break;
            case "SymptomsHistory":
                $medicareNumber = $_SESSION["user"];
                $testResultDate = $this->args[0];
                $dateTimeOfSymptom = $this->args[1];
                $temperature = $this->args[2];
                $symptoms = $this->args[3];
                $query = "INSERT INTO SymptomsHistory (personId, dateTimeOfSymptom, testResultDate, temperature, symptoms) VALUES (
                    (SELECT Person.id FROM Person, Diagnosis WHERE Person.medicareNumber = '" . $medicareNumber . "' AND Person.id = Diagnosis.personId AND Diagnosis.testResultDate = CONVERT('" . $testResultDate . "', DATE)), 
                    CONVERT('" . $dateTimeOfSymptom . "', DATETIME), CONVERT('" . $testResultDate. "', DATE), '" . $temperature . "', '" . $symptoms . "')";
                $conn->query($query);
                echo "Symptoms recorded.";

                // Symptoms args input format: conjunctivitis, loss of taste and smell
                $newSymptoms = preg_split("/\s*,\s*/", $symptoms);  

                foreach ($newSymptoms as $s) {

                    $query = "SELECT symptom 
                                FROM Symptoms 
                                WHERE (Symptoms.symptomType = 'main' OR Symptoms.symptomType = 'other') AND Symptoms.symptom = '" . $s . "';";
                    $result = $conn->query($query);
                    if ($result->num_rows == 0) {
                        $query = "INSERT INTO Symptoms (symptom, symptomType) VALUES ('" . $s . "', 'non-listed');";
                        $conn->query($query);
                    }
                }
                // Remove all session variables
                session_unset();

                // Destroy the session
                session_destroy();
                break;

        }

        
        
    }
}
    if (isset($_POST["command"])) new FollowUpCommand();
?>