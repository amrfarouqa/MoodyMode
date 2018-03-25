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
	$name   = $_POST['name'];
	$profile   = $_POST['profileimage'];
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
					$stmt = $mysqli->prepare("INSERT INTO moodhistory (email, mood, img, ID, sortid, name, profileImage) VALUES (?, ?, ?, ?, ?, ?, ?)");				
					switch ($mood) {
    				case "veryhappy":
        				$stmt->bind_param('sssssss', $email, $mood, $veryhappy, $ID, $veryhappysortid, $name, $profile);
        				break;
    				case "happy":
        				$stmt->bind_param('sssssss', $email, $mood, $happy, $ID, $happysortid, $name, $profile);
        				break;
    				case "normal":
       		 			$stmt->bind_param('sssssss', $email, $mood, $normal, $ID, $normalsortid, $name, $profile);
       	 				break;
       	 			case "sad":
       		 			$stmt->bind_param('sssssss', $email, $mood, $sad, $ID, $sadsortid, $name, $profile);
       	 				break;
       	 			case "verysad":
       		 			$stmt->bind_param('sssssss', $email, $mood, $verysad, $ID, $verysadsortid, $name, $profile);
       	 				break;
       	 			case "depressed":
       		 			$stmt->bind_param('sssssss', $email, $mood, $depressed, $ID, $depressedsortid, $name, $profile);
       	 				break;
    				default:
        				echo "Error!";
					}	
					$stmt->execute();
					if ($stmt->error) {error_log("Error: " . $stmt->error);
						echo '{"success":0,"error_message":"' . $stmt->error . '"}';
					}else{
						echo '{"success":1,"error_message":"Inserted Successfully."}';
					}							
					$stmt->close();
			}
	} else {
		echo '{"success":0,"error_message":"Invalid Email."}';
	}
}else {
	echo '{"success":0,"error_message":"Invalid Data."}';
}
?>
