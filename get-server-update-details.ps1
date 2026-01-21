#This will only work on servers you are a local admin on
#Update the list of servres here:
$ServerList = @("Server1","Server2")


#Script block to get server information - it is called from an invoke command below it
$sb = {
    Function Get-PendingUpdates() {
            $ret = $null
            Try {
                $ret = @(Get-WmiObject -Namespace "Root\ccm\ClientSDK" -Query "SELECT * FROM CCM_SoftwareUpdate" -ErrorAction Stop).Count 
            }
            Catch {
                return $null
            }
            return $ret
    }

    Function Get-Uptime() {
            $uptime = $null
            Try {
                $OS = Get-WmiObject win32_operatingsystem -ErrorAction Stop
                $uptime = [math]::Round(((Get-Date) - ($OS.ConvertToDateTime($OS.lastbootuptime))).TotalHours, 1)
            }
            Catch {
                #powershell versions prior to 3.0 don't support get-ciminstance
                $uptime = $null
            }
            return $uptime
    }

    Function Get-FreeCSpace() {
        $Free = $null
        Try {
            $Free = Get-PSDrive C -ErrorAction Stop
            $Free = [math]::Round(($Free.Free / 1GB), 1)
        }
        Catch {
            $Free = $null
        }
        return $Free
    }

    $ret = @{
        Name            = $env:COMPUTERNAME;
        OperatingSystem = (Get-WmiObject win32_operatingsystem -ErrorAction SilentlyContinue).caption
        Online          = $True;
        FreeC           = Get-FreeCSpace;
        UptimeHours     = Get-Uptime;
        PendingUpdates  = Get-PendingUpdates;
        TimeStamp       = "{0:MM/dd/yy HH:mm:ss}" -f (Get-Date);
    }

    New-Object psobject -Property $ret
}

#Loop through the servers
foreach ($Server in $ServerList) {
    $ret = $null
    $job = $null
    $i++
    Write-Host "Validating $Server -- $i of $($ServerList.Count)"
    If (Test-Connection -ComputerName $Server -quiet -count 1) {
        Try {
            $job = Invoke-Command -ComputerName $Server -AsJob -JobName $Server -ScriptBlock $sb -ErrorAction Stop
            }
        Catch {
                $ret += New-Object psobject -Property @{ Name = $Server; Online = "Error"; TimeStamp = "{0:MM/dd/yy HH:mm:ss}" -f (Get-Date); OperatingSystem = (Get-ADComputer -Identity $Server -Property OperatingSystem -ErrorAction SilentlyContinue).OperatingSystem 
                }
            }
        }
        else {
            $ret += New-Object psobject -Property @{ Name = $Server; Online = $False; TimeStamp = "{0:MM/dd/yy HH:mm:ss}" -f (Get-Date); OperatingSystem = (Get-ADComputer -Identity $Server -Property OperatingSystem -ErrorAction SilentlyContinue).OperatingSystem }
        }
}
While (Get-Job -State "Running") {
        $job = Get-Job
        Start-Sleep 2
}   
$ret += Get-job | Receive-Job -Keep -ErrorAction SilentlyContinue
Remove-Job *  

$ret
