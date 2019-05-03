<?php
use Ratchet\MessageComponentInterface;
use Ratchet\ConnectionInterface;

require __DIR__ . '/configs/config.inc.php'; 
require __DIR__ . '/classes/database.pdo.class.php'; 

    // Make sure composer dependencies have been installed
    require __DIR__ . '/vendor/autoload.php';

/**
 * chat.php
 * Send any incoming messages to all connected clients (except sender)
 */

$db = new DataBase($mysqlip, $mysqluser, $mysqlpassword, $db, $mysqlport, $charset);
$dbh = $db->getDBHandler();

class MyChat implements MessageComponentInterface {
    protected $clients;
    protected $userinfo = array();

    private $history = array();

    public function __construct() {
        $this->clients = new \SplObjectStorage;
    }

    public function onOpen(ConnectionInterface $conn) {
        $authHeader = $conn->httpRequest->getHeaders()["Authorization"];

        if(isset($authHeader[0]) && !empty($authHeader[0])) {
            global $dbh;

            $token = base64_decode(explode(" ", $authHeader[0])[1]);

            print("Checking token ".$token."\n");

            $sql = "SELECT * FROM `chater`.`users` WHERE `token` = ? LIMIT 1;";
            $result = returnResult($sql, array($token), $dbh, false, "auth");

            if (!empty($result)) {
                print("Join! Nice token. ".$result['nickname']." succsess registred to chat!"."\n");
                $this->clients->attach($conn);

                $clientInfo = array(
                    "id" => $result['id'],
                    "nickname" => $result['nickname']
                );

                $this->userinfo[$conn->resourceId] = $clientInfo;
            } else {
                print("Bad token ".$token."\n");
                $this->clients->detach($conn);
            }
        }

        echo "New connection! ({$conn->resourceId})\n";
    }

    public function onMessage(ConnectionInterface $from, $msg) {
        $numRecv = count($this->clients) - 1;
        echo sprintf('Connection %d sending message "%s" to %d other connection%s' . "\n"
            , $from->resourceId, $msg, $numRecv, $numRecv == 1 ? '' : 's');

        $data = array(
            "type" => "message",
            "userid" => $this->userinfo[$from->resourceId]["id"],
            "user" => $this->userinfo[$from->resourceId]["nickname"],
            "time" => date("Y-m-d H:i:s"),
            "msg" => $msg
        );

        echo "Send data: \n";
        var_dump($data);
        echo "END DATA! \n";

        foreach ($this->clients as $client) {
            if (true || $from != $client) {
                $client->send(json_encode($data));
            }
        }

        $sql = "INSERT INTO `history` (`id`, `userid`, `msg`, `date`) VALUES (NULL, ?, ?, NOW());";
        global $dbh;

        try
        {
            $stmt = $dbh->prepare($sql);
            $stmt->execute(array($data['userid'], $data['msg']));
        }
        catch(PDOException $e)
        {
            echo $e->getMessage();
            die();
        }
    }

    public function onClose(ConnectionInterface $conn) {
        $this->clients->detach($conn);

        echo "Connection {$conn->resourceId} has disconnected\n";
    }

    public function onError(ConnectionInterface $conn, \Exception $e) {
        $conn->close();
    }
}
    echo "Server has started!" . "\n";

    // Run the server application through the WebSocket protocol on port 8080
    $app = new Ratchet\App('127.0.0.1', 8090);
    $app->route('/chat', new MyChat, array('*'));
    $app->run();