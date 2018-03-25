<?php
 
/*
 * Following code will list all the products
 */
 
// array for JSON response
$response = array();
 
// include db connect class
require_once __DIR__ . '/hive/db_connect.php';
 
// connecting to db
$db = new DB_CONNECT();
 
// get all products from products table
$result = mysql_query("SELECT * FROM `moodhistory` WHERE 1") or die(mysql_error());
 
// check for empty result
if (mysql_num_rows($result) > 0) {
    // looping through all results
    // products node
    $response["moods"] = array();
 
    while ($row = mysql_fetch_array($result)) {
        // temp user array
        $product = array();
        $product["email"] = $row["email"];
        $product["mood"] = $row["mood"];
        $product["img"] = $row["img"];
        $product["ID"] = $row["ID"];
        $product["name"] = $row["name"];
        $product["profileImage"] = $row["profileImage"];
        $product["sortid"] = $row["sortid"];
        $product["time"] = $row["created_at"];
        // push single product into final response array
        array_push($response["moods"], $product);
    }
    // success
    $response["success"] = 1;
 
    // echoing JSON response
    echo json_encode($response);
} else {
    // no products found
    $response["success"] = 0;
    $response["message"] = "No products found";
 
    // echo no users JSON
    echo json_encode($response);
}
?>