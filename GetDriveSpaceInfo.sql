USE [msdb]
GO

/****** Object:  Job [Get Drive Space Info]    Script Date: 8/29/2025 5:36:34 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Priority 1 - 24/7]    Script Date: 8/29/2025 5:36:35 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Priority 1 - 24/7' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Priority 1 - 24/7'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Get Drive Space Info', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'PowerShell script to gather drive space information for all database servers (as found in vw_server_listings)', 
		@category_name=N'Priority 1 - 24/7', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Get Drive Info]    Script Date: 8/29/2025 5:36:35 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Get Drive Info', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'PowerShell', 
		@command=N'Import-Module “sqlps” -DisableNameChecking
$ServerName = Invoke-Sqlcmd -Query "select server_name from vw_server_listing" -ServerInstance "dbserver" -Database "Liusight"
$databaseName = "IMG_DataServices"
$ConvertToGB = (1024 * 1024 * 1024)
$date = get-date -Format "yyyy-MM-dd HH:mm:ss"
    $conn = New-Object System.Data.SQLClient.SQLConnection
    $ConnectionString ="Server=dbserver;Database=$databaseName;trusted_connection=true;"
    $conn.ConnectionString=$ConnectionString 
    $conn.Open()
foreach ($Server in $ServerName) 
        {
        $wmiObject = Get-WmiObject Win32_Volume -ComputerName $Server.server_name  | Where-Object { $_.DriveLetter -ge ''C:'' } | Where-Object { $_.DriveType -eq 3 }
        Foreach ($logicalDisk in $wmiObject)
        {
    $commandText = "INSERT All_DB_Server_Drive_Space VALUES (''"+$logicalDisk.SystemName +"'',''"+$logicalDisk.DriveLetter+"'',''"+$logicalDisk.Capacity+"'',''"+($logicalDisk.Capacity/$ConvertToGB)+"'',''"+$logicalDisk.FreeSpace+"'',''"+($logicalDisk.FreeSpace/$ConvertToGB)+"'',''"+$date+"'',''"+(($logicalDisk.FreeSpace/$logicalDisk.Capacity)*100 -as [int])+"'')" 
    $command = $conn.CreateCommand()
    $command.CommandText = $commandText
    $command.ExecuteNonQuery()
    Write-Output $commandText
    }

} #foreach
$conn.Close()', 
		@flags=0, 
		@proxy_name=N'PowershellProxy'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Purge records older than 1 year]    Script Date: 8/29/2025 5:36:35 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Purge records older than 1 year', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE IMG_DataServices
GO

DELETE FROM All_DB_Server_Drive_Space
WHERE UpdatedOn < DATEADD(YEAR,-1,GETDATE())', 
		@database_name=N'IMG_DataServices', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'On the 6''s', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=12, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20141120, 
		@active_end_date=99991231, 
		@active_start_time=53000, 
		@active_end_time=52959, 
		@schedule_uid=N'41ebd8d0-36c2-45a3-bbaf-389cfbca5188'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


