<?php
include_once("dbConnection.php");
include("abstractCommand.php");
include("displayCommand.php");
?>

<!DOCTYPE html>
<html>

<head>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/css/bootstrap.min.css">
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/js/bootstrap.min.js"></script>
</head>

<body>

<div class="app-container" style="margin: 5px 20px;">

    <h2>A Simple Database Application System for the COVID-19 Public Health Care</h2>
    <ul class="nav nav-pills">
        <li class="active"><a data-toggle="pill" href="#commands">Commands</a></li>
        <li><a data-toggle="pill" href="#follow-up-form">Follow-up Form</a></li>
        <li><a data-toggle="pill" href="#queries">Queries</a></li>
    </ul>

    <div class="tab-content">
        <!--Form for user to fill out if they want to Insert/Create, Delete, Edit or Display a table-->
        <div id="commands" class="tab-pane fade in active">
            <h2>Modify database data</h2>
            <form method="post" id="commands">
                Command: <input type="text" name="command" value="">
                <br/><br/>
                Table name: <input type="text" name="tableName" value="">
                <br/><br/>
                Arguments list: <input type="text" name="args" value="">
                <br/><br/>
                Where clause: <input type="text" name="where" value="">
                <br/><br/>
                <input type="submit" name="submit" value="Submit"/>
            </form>
            <p id="commands-output"></p>
        </div>
        <div id="follow-up-form" class="tab-pane fade in">
            <h2>Follow-up Form</h2>
            <p>Please input the medicare number of the person and his/her date of birth [yyyy-mm-dd]</p>
            <form method="post" id="follow-up">
                Medicare Number: <input type="text" name="medicare-number" placeholder="AAAA 0000 0000" value="">
                <br/><br/>
                Date of birth: <input type="text" name="dob" placeholder = "yyyy-mm-dd" value="">
                <br/><br/>
                <input type="submit" name="submit" value="Submit"/>
            </form>
            <div id="follow-up-match-output"></div>
            <div>
                <h4>Symptoms list</h4>
                <div id="follow-up-symptoms-output"></div>
            </div>
            <div id="follow-up-form-container" style="display: none;">
                <h3>Follow-up Form</h3>
                <form method="post" id="follow-up-form-values">
                    <!-- Medicare Number: <input type="text" name="medicare-number" placeholder="AAAA 0000 0000" value="">
                    <br/><br/> -->
                    Test Result Date: <input type="date" id="date"
                            name="testResultDate" value="now"
                            min="2020-06-07" max="2021-06-14">
                    Date & Time: <input type="datetime-local" id="date-time"
                            name="date-time" value="now"
                            min="2020-06-07T00:00" max="2021-06-14T00:00">
                    <br/><br/>
                    Temperature: <input type="text" name="temp" value="">
                    <br/><br/>
                    Symptoms: <input type="text" name="Symptoms" value="">
                    <br/><br/>
                    <input type="submit" name="submit" value="Submit"/>
                </form>
                <div id="follow-up-form-result"></div>
            </div>
        </div>

        <div id="queries" class="tab-pane fade in">
            <h2>Queries</h2>
            <form method="post" id="queries">
                Query number: <input type="text" name="queryNumber" value="">
                <br/><br/>
                Arguments list: <input type="text" name="args" value="">
                <br/><br/>
                <input type="submit" name="submit" value="Submit"/>
            </form>
            <p id="queries-output"></p>


        </div>
    </div>  
</div>


    
    <script>
        $("#commands").on("submit", function(event) {
            event.preventDefault();
            $.ajax({
                url: "abstractCommand.php",
                async: true,
                success: function() {
                    $('#commands-output').load("abstractCommand.php", {
                        // Get input values from form and sets AbstractCommand attributes.
                        command: event.target.getElementsByTagName("input")[0].value,
                        tableName: event.target.getElementsByTagName("input")[1].value,
                        args: event.target.getElementsByTagName("input")[2].value,
                        where: event.target.getElementsByTagName("input")[3].value
                    });
                }
            })
        })
        
        $("#follow-up").on("submit", function(event) {
            event.preventDefault();
            $.ajax({
                url: "abstractCommand.php",
                async: true,
                success: function() {
                    $('#follow-up-match-output').load("abstractCommand.php", {
                        // Get input values from form and sets AbstractCommand attributes.
                        command: "followUp",
                        tableName: "Person",
                        args: [event.target.getElementsByTagName("input")[0].value, event.target.getElementsByTagName("input")[1].value].join(";"),
                        where: ""
                    }, function(responseText, textStatus, jqXHR) {
                        if(responseText.includes("Person Found!") && !responseText.includes("No positive test results")){
                            $('#follow-up-form-container').show();   
                        }
                        else {
                            $('#follow-up-form-container').hide(); 
                        }
                    });
                }
            })

        })

        $.ajax({
            url: "abstractCommand.php",
                async: true,
                success: function() {
                    $('#follow-up-symptoms-output').load("abstractCommand.php", {
                        // Get input values from form and sets AbstractCommand attributes.
                        command: "followUp",
                        tableName: "Symptoms",
                        args: "",
                        where: ""
                    });
                }
               
        })

        $("#follow-up-form-values").on("submit", function(event) {
            event.preventDefault();
            alert("Here")
            $.ajax({
                url: "abstractCommand.php",
                async: true,
                success: function() {
                    $('#follow-up-form-result').load("abstractCommand.php", {
                        // Get input values from form and sets AbstractCommand attributes.
                        command: "followUp",
                        tableName: "SymptomsHistory",
                        args: event.target.getElementsByTagName("input")[0].value.concat(" ; ", event.target.getElementsByTagName("input")[1].value, " ; ", 
                            event.target.getElementsByTagName("input")[2].value, " ; ", event.target.getElementsByTagName("input")[3].value),
                        where: ""
                    });
                }
               
            })

        })



        $("#queries").on("submit", function(event) {
            event.preventDefault();
            $.ajax({
                url: "abstractCommand.php",
                async: true,
                success: function() {
                    $('#queries-output').load("abstractCommand.php", {
                        // Get input values from form and sets AbstractCommand attributes.
                        command: "queries",
                        queryNumber: event.target.getElementsByTagName("input")[0].value,
                        args: event.target.getElementsByTagName("input")[1].value,
                        tableName: "",
                        where: ""
                    });
                }
            })
        })
    </script>
    


</body>

</html>