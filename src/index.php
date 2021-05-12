<?php
include_once("dbConnection.php");
?>
<!DOCTYPE html>
<html>

<body>
    <h2>Connect to database covid19_phcs</h2>

    <form method="post">
        <input type="submit" name="connectButton" value="Connect" />
    </form>

    
    <?php
    if (isset($_POST["connectButton"])) {
        echo '<script>window.location = "./db.php" </script>';          
    }
    
    ?>
</body>

</html>
