<?php
header('Access-Control-Allow-Origin: *');

// Access-Control headers are received during OPTIONS requests
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    if (isset($_SERVER['HTTP_ACCESS_CONTROL_REQUEST_METHOD'])) {
        header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
    }

    if (isset($_SERVER['HTTP_ACCESS_CONTROL_REQUEST_HEADERS'])) {
        header("Access-Control-Allow-Headers:        {$_SERVER['HTTP_ACCESS_CONTROL_REQUEST_HEADERS']}");
    }

    exit(0);
}

$comm = $_GET['comm'];
$path =__DIR__.'\\';//"c:\\xampp\\htdocs\\";

if ($comm == 'input') {
    $amount = $_GET['amount'];
    $ordercode = $_GET['ordercode'];
    $timeout = $_GET['timeout'];

    $command ="start /B $path".'bill input '.$amount.' '.$ordercode.' '.$timeout;

    $p = popen($command, "r");
    if ($p == false) {
        echo '{"code":"-1"}';
    } else {
        pclose($p);
    }
    echo '{"code":"0"}';
} elseif ($comm == 'stop') {
    $filename = $path . 'log\\running';
    if (file_exists($filename)) {
        @unlink($filename);
    }
    echo '{"code":"0"}';
} elseif ($comm == 'status') {
    $filename = $path . 'log\\running';
    if (file_exists($filename)) {
        @unlink($filename);
        sleep(2);
    }
    $command =$path.'bill status';
    $return = exec($command);
    echo $return;
} elseif ($comm == 'init') {
    $filename = $path . 'log\\running';
    if (file_exists($filename)) {
        @unlink($filename);
        sleep(2);
    }
    $command =$path.'bill init';
    $return = exec($command);
    echo $return;
} else {
    $path = $path . "log\\";
    $ordercode = $_GET['ordercode'];
    $str = @file_get_contents($path.$ordercode.'.json');
    echo $str;
}