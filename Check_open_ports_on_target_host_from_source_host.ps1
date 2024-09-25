New-Object System.Net.Sockets.TcpClient('FQDN',445) #checks if SMB port is opened using Servers FQDN i.e servername.example.com
Test-NetConnection FQDN -Port 445  #checks if SMB port is opened using Servers FQDN  i.e servername.example.com


New-Object System.Net.Sockets.TcpClient('IP',445) #checks if SMB port is opened using Servers IP i.e 192.168.1.1
Test-NetConnection IP -Port 445 #checks if SMB port is opened using Servers IP i.e 192.168.1.1
