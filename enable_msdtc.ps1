##Use this to turn on MSDTC 

Set-ItemProperty HKLM:SOFTWARE\\Microsoft\\MSDTC\\Security -Name NetworkDtcAccess -value 1;
Set-ItemProperty HKLM:SOFTWARE\\Microsoft\\MSDTC\\Security -Name NetworkDtcAccessClients -value 1;
Set-ItemProperty HKLM:SOFTWARE\\Microsoft\\MSDTC\\Security -Name NetworkDtcAccessInbound -value 1;
Set-ItemProperty HKLM:SOFTWARE\\Microsoft\\MSDTC\\Security -Name NetworkDtcAccessOutbound -value 1;
Set-ItemProperty HKLM:SOFTWARE\\Microsoft\\MSDTC\\Security -Name NetworkDtcAccessTransactions -value 1;
