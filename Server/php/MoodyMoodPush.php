<?php
if ($_POST){
	$deviceToken = $_POST['token'];
	// Put your private key's passphrase here:
	$passphrase = 'MoodyMood_123';

	// Put your alert message here:
	$message = 'MoodyMood!';
	$ctx = stream_context_create();
	stream_context_set_option($ctx, 'ssl', 'local_cert', 'pushcert.pem');
	stream_context_set_option($ctx, 'ssl', 'passphrase', $passphrase);
	
	// Open a connection to the APNS server
	$fp = stream_socket_client(
        'ssl://gateway.sandbox.push.apple.com:2195', $err, $errstr, 60, STREAM_CLIENT_CONNECT | STREAM_CLIENT_PERSISTENT, $ctx);
        if (!$fp)
    exit("Failed to connect: $err $errstr" . PHP_EOL);

	echo 'Connected to APNS' . PHP_EOL;

	// Create the payload body
	$body['aps'] = array
    	(
    	'title' => "MoodyMood!",
    	'message' => "Don't Forget To Update Your Mode Today",
    	'notId' => rand(),
    	"cardId" => 0,
    	'type' => "update",
    	'image' => "http://138.201.61.97/~moodymood/img/proticonsmall.png",
		'sound' => 'default',
            	'badge' => 0,
				"alert" => array(
                	"action-loc-key" => "Open",
                	"body" => "Don't Forget To Update Your Mode Today"
            	),
	);
	// Encode the payload as JSON
	$payload = json_encode($body);

	// Build the binary notification
	$msg = chr(0) . pack('n', 32) . pack('H*', $deviceToken) . pack('n', strlen($payload)) . $payload;

	// Send it to the server
	$result = fwrite($fp, $msg, strlen($msg));

	if (!$result)
    	echo '{"success":0,"error_message":"Notification Not Delivered."}' . PHP_EOL;
	else
		echo '{"success":1,"error_message":"Success Notification."}' . PHP_EOL;

	// Close the connection to the server
	fclose($fp);
}else{
	echo '{"success":0,"error_message":"Post Error."}';
}
?>