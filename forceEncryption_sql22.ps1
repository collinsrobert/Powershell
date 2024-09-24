Set-ItemProperty HKLM:SOFTWARE\\Microsoft\\"Microsoft SQL Server"\\MSSQL16.MSSQLSERVER\\MSSQLServer\\SuperSocketNetLib -Name ForceEncryption -Value 1  ## This is for SQL Server 2022
Set-ItemProperty HKLM:SOFTWARE\\Microsoft\\"Microsoft SQL Server"\\MSSQL15.MSSQLSERVER\\MSSQLServer\\SuperSocketNetLib -Name ForceEncryption -Value 1  ## This is for SQL Server 2019
Set-ItemProperty HKLM:SOFTWARE\\Microsoft\\"Microsoft SQL Server"\\MSSQL14.MSSQLSERVER\\MSSQLServer\\SuperSocketNetLib -Name ForceEncryption -Value 1  ## This is for SQL Server 2017
Set-ItemProperty HKLM:SOFTWARE\\Microsoft\\"Microsoft SQL Server"\\MSSQL13.MSSQLSERVER\\MSSQLServer\\SuperSocketNetLib -Name ForceEncryption -Value 1  ## This is for SQL Server 2016
Set-ItemProperty HKLM:SOFTWARE\\Microsoft\\"Microsoft SQL Server"\\MSSQL12.MSSQLSERVER\\MSSQLServer\\SuperSocketNetLib -Name ForceEncryption -Value 1  ## This is for SQL Server 2014
Set-ItemProperty HKLM:SOFTWARE\\Microsoft\\"Microsoft SQL Server"\\MSSQL11.MSSQLSERVER\\MSSQLServer\\SuperSocketNetLib -Name ForceEncryption -Value 1  ## This is for SQL Server 2012
