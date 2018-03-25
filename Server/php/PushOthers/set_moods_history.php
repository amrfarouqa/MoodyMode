<?php
/* --------------------------- */
/*  Author : Dipin Krishna     */
/*  Website: dipinkrishna.com  */
/* --------------------------- */

header('Content-Type: application/json');
if($_POST) {
	$email   = $_POST['email'];
	$mood   = $_POST['mood'];
	$ID   = $_POST['ID'];
	$name = $_POST['name'];
	$profileImage = $_POST['profileimage'];
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
				$stmt = $mysqli->prepare("INSERT INTO `moodhistory`(`email`, `ID`, `mood`, `img`, `name`, `profileImage`, `sortid`) VALUES (?,?,?,?,?,?,?)");
				switch ($mood) {
    				case "veryhappy":
        				$stmt->bind_param('sssssss',$email, $ID, $mood, $veryhappy, $name, $profileImage, "6");
        			break;
    			case "happy":
        				$stmt->bind_param('sssssss',$email, $ID, $mood, $happy, $name, $profileImage, "5");
        			break;
    			case "normal":
       		 			$stmt->bind_param('sssssss',$email, $ID, $mood, $normal, $name, $profileImage, "4");
       	 			break;
       	 		case "sad":
       		 			$stmt->bind_param('sssssss',$email, $ID, $mood, $sad, $name, $profileImage, "3");
       	 			break;
       	 		case "verysad":
       		 			$stmt->bind_param('sssssss',$email, $ID, $mood, $verysad, $name, $profileImage, "2");
       	 			break;
       	 		case "depressed":
       		 			$stmt->bind_param('sssssss',$email, $ID, $mood, $depressed, $name, $profileImage, "1");
       	 			break;
    			default:
        			echo "Error!";
				}				
				/* execute prepared statement */
				$stmt->execute();
				if ($stmt->error) {
				error_log("Error: " . $stmt->error); 
				$error = [
				'success'=>0,
				'error_message'=> '',
				'error'=> $stmt->error,
				'email'=>$email,
				'ID'=>$ID,
				'mood'=>$mood,
				'name'=>$depressed,
				'profileimage'=>$profileImage
				];
				echo json_encode($error);
				}else{
					echo '{"success":1,"error_message":"MoodHistory Updated."}';
				}
				/* close statement and connection */
				$stmt->close();
			}
	} else {
		echo '{"success":0,"error_message":"Invalid Email."}';
	}
}else {
	echo '{"success":0,"error_message":"Invalid Data."}';
}
?>
