<?php
$apnsServer = 'ssl://gateway.sandbox.push.apple.com:2195';
$privateKeyPassword = 'mykey';
$message = "My message here !";
$deviceToken ='MYTOKENHERE';

$pushCertAndKeyPemFile = 'pushcert.pem';
$stream = stream_context_create();
stream_context_set_option($stream,'ssl','MoodyMood_123',$privateKeyPassword);
stream_context_set_option($stream,'ssl','pushcert',$pushCertAndKeyPemFile);
$connectionTimeout = 30;
$connectionType = STREAM_CLIENT_CONNECT | STREAM_CLIENT_PERSISTENT;
$connection = stream_socket_client($apnsServer, $errorNumber, $errorString, $connectionTimeout,$connectionType,$stream);

if (!$connection){
    echo "Failed to connect to the APNS server. Error = $errorString <br/>";
    exit;
}
else{
    echo "Successfully connected to the APNS. Processing...</br>";
}
$messageBody['aps'] = array('alert' => $message,'badge' => 1, 'sound' => 'default');
$payload = json_encode($messageBody);
$notification = chr(0) . pack('n', 32) . pack('H*', $deviceToken) . pack('n', strlen($payload)) . $payload;
$wroteSuccessfully = fwrite($connection, $notification, strlen($notification));

if (!$wroteSuccessfully){
    echo "Could not send the message<br/>";
} else {
    echo "Successfully sent the message<br/>";
}
fclose($connection);			
?>