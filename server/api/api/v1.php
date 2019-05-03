<?php
ini_set('display_errors', 1);
error_reporting(E_ALL);
    define('__ROOT__', dirname(__FILE__));
    require_once(__ROOT__ . DIRECTORY_SEPARATOR . '..' . DIRECTORY_SEPARATOR .'configs' . DIRECTORY_SEPARATOR . 'config.inc.php');

    // DB
    require_once (__ROOT__ . DIRECTORY_SEPARATOR . '..' . DIRECTORY_SEPARATOR . 'classes' . DIRECTORY_SEPARATOR . 'database.pdo.class.php');
    $db = new DataBase($mysqlip, $mysqluser, $mysqlpassword, $db, $mysqlport, $charset);
    $dbh = $db->getDBHandler();

function current_url()
{
    $url      = $_SERVER['REQUEST_URI'];
    $validURL = str_replace("&", "&amp", $url);
    return $validURL;
}

$offerUrl = current_url();

$paths = explode("/", $offerUrl);

$request = $paths[3];
$requestHope = isset($paths[4]) ? $paths[4] : "";


function result_json_array($arr, $code) {
    $arrCode = array('code' => $code);
    header('Content-Type: application/json');
    echo json_encode(array_merge($arr, $arrCode));
    die();
}

if (isset($_SERVER["HTTP_CF_CONNECTING_IP"])) {
  $_SERVER['REMOTE_ADDR'] = $_SERVER["HTTP_CF_CONNECTING_IP"];
}

switch ($request) {
    case 'auth':
        if(!isset($_POST['email']) || !isset($_POST['hash'])) {
            result_json_array(array(), 400);
        }

        $email = $_POST['email'];
        $hash =  $_POST['hash'];
        $res = array();

        $token = "";
        $sql = "SELECT * FROM `chater`.`users` WHERE `email` = ? AND `password` = ?;";
        $result = returnResult($sql, array($email, $hash), $dbh, false, "auth");

        if (!empty($result)) {
            $sql = "UPDATE `chater`.`users` SET `token` = ? WHERE `email` = ? AND `password` = ?;";
            $token = "";

            try
            {
                $token = bin2hex(random_bytes(16));
                $stmt = $dbh->prepare($sql);
                $stmt->execute(array($token, $email, $hash));
            }
            catch(PDOException $e)
            {
                die();
            }
        }
    
        if(empty($token)) {
            result_json_array(array(), 403);
            die();
        }

        $res['id'] = $result["id"];
        $res['token'] = $token;
        result_json_array($res, 200);

        break;
    case "history": 
        $sql = "SELECT `chater`.`history`.*, `chater`.`users`.nickname FROM `chater`.`history` LEFT JOIN `chater`.`users`
        ON `chater`.`history`.userid = `chater`.`users`.id ORDER BY `date` ASC;";
        $result = returnResult($sql, array(), $dbh, true, "auth");

        $res = array();

        foreach ($result as $message) {
            array_push($res, $message);
        }

        header('Content-Type: application/json');
        echo json_encode($res);
        die();

        break;
    default:
        header("HTTP/1.0 402 Not Found");
        break;
}

?>