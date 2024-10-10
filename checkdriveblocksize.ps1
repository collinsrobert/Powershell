#Command to check block size with PowerShell

Get-CimInstance -ClassName Win32_Volume | Select-Object Label, BlockSize | Format-Table -AutoSize 
