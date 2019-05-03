<?php
	class DataBase
	{
		private $dbh; // DataBase Handler
		
		public function __construct($ip, $user, $password, $db, $port, $charset)
		{
			try
			{
				$dsn = "mysql:host=$ip;port=$port;dbname=$db;charset=$charset";
				$opt = array
				(
					PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
					PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
					PDO::MYSQL_ATTR_INIT_COMMAND => 'SET NAMES ' . $charset,
				);
				
				$this->dbh = new PDO($dsn, $user, $password, $opt);
			}
			catch(PDOException $e) 
			{
				echo 'Произошла ошибка подключения к базе данных!<br>';
				echo $e->getMessage();
				die();
			}
		}
		
		function __destruct() 
		{
			try 
			{
				$this->dbh = null; // Close connection
			}
			catch (PDOException $e) 
			{
				echo 'Произошла ошибка во время заверщения работы с базой данных!<br>';
				echo $e->getMessage();
				die();
			}
		}
		
		public function getDBHandler()
		{
			return $this->dbh;
		}
	}
	
	function returnResult($sql, $paramarray, PDO &$dbh, $isfetchAll = true, $namecallfunction = "")
	{
		if($dbh === null)
			die("You must send init DataBase Handler $namecallfunction");
			
		try
		{
			$stmt = $dbh->prepare($sql);
			$stmt->execute($paramarray);
		}
		catch(PDOException $e) 
		{
			echo "DB for $namecallfunction return error:<br>";
			echo $e->getMessage();
			die();
		}
		
		return ($isfetchAll ? $stmt->fetchAll() : $stmt->fetch());
	}
?>