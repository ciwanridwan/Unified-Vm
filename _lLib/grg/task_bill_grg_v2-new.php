<?php
header('Access-Control-Allow-Origin: *');

// Access-Control headers are received during OPTIONS requests
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {

    if (isset($_SERVER['HTTP_ACCESS_CONTROL_REQUEST_METHOD']))
        header("Access-Control-Allow-Methods: GET, POST, OPTIONS");

    if (isset($_SERVER['HTTP_ACCESS_CONTROL_REQUEST_HEADERS']))
        header("Access-Control-Allow-Headers:        {$_SERVER['HTTP_ACCESS_CONTROL_REQUEST_HEADERS']}");

    exit(0);
}

$comm = $_GET['comm'];
$pathMain = "c:\\xampp\\htdocs\\";

if($comm == 'input'){
    $path = $pathMain . "bill\\";
    $amount = $_GET['amount'];
    $ordercode = $_GET['ordercode'];
    $timeout = $_GET['timeout'];
	$counter = $_GET['counter'];
    $command ="start /B $path".'bill input '.$amount.' '.$ordercode.' '.$timeout.' '.$counter;

    $p = popen($command, "r");
    if ($p == False){
        echo '{"code":"-1"}';
    } else {
        pclose($p);
    }
    echo '{"code":"0"}';

}elseif($comm == 'stop'){
	$filename = $pathMain . 'bill\\log\\running';
//    $filename = 'c:\\xampp\\htdocs2\\bill\\lock';

    if (file_exists($filename)) {
        unlink($filename);
        echo '{"code":"0"}';
    } else {
        echo '{"code":"0"}';
    }

}elseif($comm == 'init') {
    $filename = $pathMain . 'bill\\log\\running';
//    $filename = 'c:\\xampp\\htdocs2\\bill\\lock';

    if (file_exists($filename)) {
        @unlink($filename);
    }

    sleep(2);

    $path = $pathMain . "bill\\";
    $amount = $_GET['amount'];
    $ordercode = $_GET['ordercode'];
    $timeout = $_GET['timeout'];

    $command =$path.'bill init';

    $return = exec($command);
    echo $return;
}else{
    $path = $pathMain . "bill\\log\\";
    $ordercode = $_GET['ordercode'];
	$counter = $_GET['counter'];
    $str = @file_get_contents($path.$ordercode.'-'.$counter.'.json');
    echo $str;
}

?>