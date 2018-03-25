<?php
/* --------------------------- */
/*  Author : Dipin Krishna     */
/*  Website: dipinkrishna.com  */
/* --------------------------- */

header('Content-type: application/json');
if($_POST) {
	$email   = $_POST['email'];
	$mood   = $_POST['mood'];
	$ID   = $_POST['ID'];
	$veryhappy = "http://138.201.61.97/~moodymood/img/veryhappy.png";
	$happy = "http://138.201.61.97/~moodymood/img/happy.png";
	$normal = "http://138.201.61.97/~moodymood/img/normal.png";
	$sad = "http://138.201.61.97/~moodymood/img/sad.png";
	$verysad = "http://138.201.61.97/~moodymood/img/verysad.png";
	$depressed = "http://138.201.61.97/~moodymood/img/depressed.png";
	$veryhappysortid = "6";
	$happysortid = "5";
	$normalsortid = "4";
	$sadsortid = "3";
	$verysadsortid = "2";
	$depressedsortid = "1";
	if($_POST['email']) {
		

			$db_name     = 'moodymood_amr';
			$db_user     = 'moodymood_admin';
			$db_password = 'moodymood_admin123';
			$server_url  = 'localhost';

			$mysqli = new mysqli('localhost', $db_user, $db_password, $db_name);

			/* check connection */
			if (mysqli_connect_errno()) {
				error_log("Connect failed: " . mysqli_connect_error());
				echo '{"success":0,"error_message":"' . mysqli_connect_error() . '"}';
			} else {				
				$stmt = $mysqli->prepare("SELECT `email` FROM `usermood` WHERE `email`= ?");
				$stmt->bind_param('s', $email);
				$stmt->execute();
				$stmt->store_result();
				$row_count_select = $stmt->num_rows;
				$stmt->close();
				if ($row_count_select > 0){ // User Exists need to update
					$stmt = $mysqli->prepare("UPDATE `usermood` SET `email`=?,`mood`=?,`img`=?,`ID`=?,`sortid`=? WHERE `email`=?");				
					switch ($mood) {
    				case "veryhappy":
        				$stmt->bind_param('ssssss', $email, $mood, $veryhappy, $ID, $veryhappysortid,$email);
        				break;
    				case "happy":
        				$stmt->bind_param('ssssss', $email, $mood, $happy, $ID,$happysortid, $email);
        				break;
    				case "normal":
       		 			$stmt->bind_param('ssssss', $email, $mood, $normal, $ID,$normalsortid, $email);
       	 				break;
       	 			case "sad":
       		 			$stmt->bind_param('ssssss', $email, $mood, $sad, $ID,$sadsortid, $email);
       	 				break;
       	 			case "verysad":
       		 			$stmt->bind_param('ssssss', $email, $mood, $verysad, $ID,$verysadsortid, $email);
       	 				break;
       	 			case "depressed":
       		 			$stmt->bind_param('ssssss', $email, $mood, $depressed, $ID,$depressedsortid, $email);
       	 				break;
    				default:
        				echo "Error!";
					}	
					$stmt->execute();
					if ($stmt->error) {
						error_log("Error: " . $stmt->error); 
						echo '{"success":0,"error_message":"Error."}';
					}else{
						echo '{"success":1,"error_message":"Inserted Successfully."}';
					}
					$stmt->close();
					
				}else{ // Needs Insertion
					$stmt = $mysqli->prepare("INSERT INTO usermood (email, mood, img, ID, sortid) VALUES (?, ?, ?, ?, ?)");				
					switch ($mood) {
    				case "veryhappy":
        				$stmt->bind_param('sssss', $email, $mood, $veryhappy, $ID, $veryhappysortid);
        				break;
    				case "happy":
        				$stmt->bind_param('sssss', $email, $mood, $happy, $ID, $happysortid);
        				break;
    				case "normal":
       		 			$stmt->bind_param('sssss', $email, $mood, $normal, $ID, $normalsortid);
       	 				break;
       	 			case "sad":
       		 			$stmt->bind_param('sssss', $email, $mood, $sad, $ID, $sadsortid);
       	 				break;
       	 			case "verysad":
       		 			$stmt->bind_param('sssss', $email, $mood, $verysad, $ID, $verysadsortid);
       	 				break;
       	 			case "depressed":
       		 			$stmt->bind_param('sssss', $email, $mood, $depressed, $ID, $depressedsortid);
       	 				break;
    				default:
        				echo "Error!";
					}	
					$stmt->execute();
					if ($stmt->error) {error_log("Error: " . $stmt->error); }							
					$stmt->close();
					echo '{"success":1,"error_message":"Inserted Successfully."}';
				}	
			}
	} else {
		echo '{"success":0,"error_message":"Invalid Email."}';
	}
}else {
	echo '{"success":0,"error_message":"Invalid Data."}';
}
?>
