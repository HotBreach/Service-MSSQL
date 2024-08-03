DECLARE @operatorName as NVARCHAR(100);
DECLARE @operatorEmail as NVARCHAR(100);
  
SET @operatorName = N'AdminDB'; -- REPLACE THIS WITH THE OPERATOR NAME
SET @operatorEmail = N''; -- REPLACE THIS WITH THE OPERATOR EMAIL
  
IF NOT EXISTS(SELECT * FROM msdb..sysoperators WHERE name = @operatorName) 
BEGIN
    EXEC msdb.dbo.sp_add_operator @name=@operatorName, 
            @enabled=1, 
            @weekday_pager_start_time=100, 
            @weekday_pager_end_time=235959, 
            @saturday_pager_start_time=100, 
            @saturday_pager_end_time=235959, 
            @sunday_pager_start_time=100, 
            @sunday_pager_end_time=235959, 
            @pager_days=127, 
            @email_address=@operatorEmail, 
            @category_name=N'[Uncategorized]';
END
  
  
  
EXEC msdb.dbo.sp_add_alert @name=N'ERROR 823', 
        @message_id=823, 
        @severity=0, 
        @enabled=1, 
        @delay_between_responses=0, 
        @include_event_description_in=1, 
        @category_name=N'[Uncategorized]', 
        @job_id=N'00000000-0000-0000-0000-000000000000';
         
EXEC msdb.dbo.sp_add_notification @alert_name=N'ERROR 823', 
          @operator_name=@operatorName , 
            @notification_method = 1;
 
EXEC msdb.dbo.sp_add_alert @name=N'ERROR 824', 
        @message_id=824, 
        @severity=0, 
        @enabled=1, 
        @delay_between_responses=0, 
        @include_event_description_in=1, 
        @category_name=N'[Uncategorized]', 
        @job_id=N'00000000-0000-0000-0000-000000000000';
         
EXEC msdb.dbo.sp_add_notification @alert_name=N'ERROR 824', 
          @operator_name=@operatorName , 
            @notification_method = 1;
 
EXEC msdb.dbo.sp_add_alert @name=N'ERROR 825', 
        @message_id=825, 
        @severity=0, 
        @enabled=1, 
        @delay_between_responses=0, 
        @include_event_description_in=1, 
        @category_name=N'[Uncategorized]', 
        @job_id=N'00000000-0000-0000-0000-000000000000';
         
EXEC msdb.dbo.sp_add_notification @alert_name=N'ERROR 825', 
          @operator_name=@operatorName , 
            @notification_method = 1;
 
 
  
  
IF NOT EXISTS (SELECT * FROM [msdb].[dbo].[sysalerts] WITH ( NOLOCK ) WHERE [severity] = 19 )
BEGIN
  
    EXEC msdb.dbo.sp_add_alert @name=N'Severity 19 - Fatal Error In Resource', 
            @message_id=0, 
            @severity=19, 
            @enabled=1, 
            @delay_between_responses=900, -- 15 minutes
            @include_event_description_in=1, 
            @job_id=N'00000000-0000-0000-0000-000000000000';
  
    EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 19 - Fatal Error In Resource', 
            @operator_name=@operatorName , 
            @notification_method = 1;
END
  
IF NOT EXISTS (SELECT * FROM [msdb].[dbo].[sysalerts] WITH ( NOLOCK ) WHERE [severity] = 20 )
BEGIN
    EXEC msdb.dbo.sp_add_alert @name=N'Severity 20 - Fatal Error In Current Process', 
            @message_id=0, 
            @severity=20, 
            @enabled=1, 
            @delay_between_responses=900, -- 15 minutes
            @include_event_description_in=1, 
            @job_id=N'00000000-0000-0000-0000-000000000000';
  
    EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 20 - Fatal Error In Current Process', 
            @operator_name=@operatorName, 
            @notification_method = 1;
END
  
IF NOT EXISTS (SELECT * FROM [msdb].[dbo].[sysalerts] WITH ( NOLOCK ) WHERE [severity] = 21 )
BEGIN
    EXEC msdb.dbo.sp_add_alert @name=N'Severity 21 - Fatal Error In Database Process', 
            @message_id=0, 
            @severity=21, 
            @enabled=1, 
            @delay_between_responses=900, -- 15 minutes
            @include_event_description_in=1, 
            @job_id=N'00000000-0000-0000-0000-000000000000';
  
    EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 21 - Fatal Error In Database Process', 
            @operator_name=@operatorName, 
            @notification_method = 1;
END
  
IF NOT EXISTS (SELECT * FROM [msdb].[dbo].[sysalerts] WITH ( NOLOCK ) WHERE [severity] = 22 )
BEGIN
    EXEC msdb.dbo.sp_add_alert @name=N'Severity 22 - Fatal Error Table Integrity Suspect', 
            @message_id=0, 
            @severity=22, 
            @enabled=1, 
            @delay_between_responses=900, -- 15 minutes
            @include_event_description_in=1, 
            @job_id=N'00000000-0000-0000-0000-000000000000';
  
    EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 22 - Fatal Error Table Integrity Suspect', 
            @operator_name=@operatorName, 
            @notification_method = 1;
END
  
IF NOT EXISTS (SELECT * FROM [msdb].[dbo].[sysalerts] WITH ( NOLOCK ) WHERE [severity] = 23 )
BEGIN
    EXEC msdb.dbo.sp_add_alert @name=N'Severity 23 - Fatal Error Database Integrity Suspect', 
            @message_id=0, 
            @severity=23, 
            @enabled=1, 
            @delay_between_responses=900, -- 15 minutes
            @include_event_description_in=1, 
            @job_id=N'00000000-0000-0000-0000-000000000000';
  
    EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 23 - Fatal Error Database Integrity Suspect', 
            @operator_name=@operatorName, 
            @notification_method = 1;
END
  
  
IF NOT EXISTS (SELECT * FROM [msdb].[dbo].[sysalerts] WITH ( NOLOCK ) WHERE [severity] = 24 )
BEGIN
    EXEC msdb.dbo.sp_add_alert @name=N'Severity 24 - Hardware Error', 
            @message_id=0, 
            @severity=24, 
            @enabled=1, 
            @delay_between_responses=900, -- 15 minutes
            @include_event_description_in=1, 
            @job_id=N'00000000-0000-0000-0000-000000000000';
  
    EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 24 - Hardware Error', 
            @operator_name=@operatorName, 
            @notification_method = 1;
END
  
IF NOT EXISTS (SELECT * FROM [msdb].[dbo].[sysalerts] WITH ( NOLOCK ) WHERE [severity] = 25 )
BEGIN
    EXEC msdb.dbo.sp_add_alert @name=N'Severity 25 - System Error', 
            @message_id=0, 
            @severity=25, 
            @enabled=1, 
            @delay_between_responses=900, -- 15 minutes
            @include_event_description_in=1, 
            @job_id=N'00000000-0000-0000-0000-000000000000';
  
    EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 25 - System Error', 
            @operator_name=@operatorName, 
            @notification_method = 1;
END