<?php
include_once("dbConnection.php");
?>
<!DOCTYPE html>
<html>

<body>

    <h1>COMP 353 Project</h1>

    <h4>Connect to database tdc353_4</h4>

    <form method="post">
        <input type="submit" name="connectButton" value="Connect" />
    </form>

    
    <?php
    if (isset($_POST["connectButton"])) {
        echo '<script>window.location = "./db.php" </script>';   // https://tdc353.encs.concordia.ca/db.php for web server
        
    }
    
    ?>
</body>

</html>
