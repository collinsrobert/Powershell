#########################################-----Default instance
$servername="MSSQLSERVER"
$in="."
$login="AD\DBA"

net stop $servername /Y
net start $servername /f /mSQLCMD

SQLCMD -S $in -Q "create login [$login] from windows; alter server role sysadmin add member [$login]"

net stop $servername
net start $servername 



##########################---Named instance


$servername="MSSQL`$COMMVAULT"
$in=".\COMMVAULT"
$login="AD\DBA"

net stop $servername /Y
net start $servername /f /mSQLCMD

SQLCMD -S $in -Q "create login [$login] from windows; alter server role sysadmin add member [$login]"

net stop $servername
net start $servername 
