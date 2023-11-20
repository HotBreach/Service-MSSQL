
-------------------------------------------
-- НАСТРАИВАЕМЫЕ ПАРАМЕТРЫ
-- Условие для выборки, '%' - все базы данных 
DECLARE @namelike varchar(100) = '%'
-- Каталог для резервной копии
DECLARE @Path as nvarchar(400) --= '\\ek-backup-02\backupsqlnew\'

set @Path = case 
when day(getdate()) ='1' then '\\ek-backup-02\backup\Backup_sql_1year\'  --директория бэкапа на каждый первый день месяца
when day(getdate()) <>'1' and DATENAME(DW, GETDATE()) ='суббота' then '\\ek-backup-02\backup\Backup_sql_long_storage\' -- --директория бэкапа субботнего
when day(getdate()) <>'1' and DATENAME(DW, GETDATE()) <>'суббота' then '\\ek-backup-02\backup\backupsqlnew\'  --директория бэкапа на каждый день кроме сб и долгосрочных
else '\\ek-backup-02\backupsqlnew\' end

-- Тип резервного копирования:
--		0 - Полная резервная копия с флагом "Только резервное копирование"
--		1 - Полная резервная копия
--		2 - Разностная резервная копия
--		3 - Копия журнала транзакций
DECLARE @Type as int = 1
-- Сжимать резервные копии:
--		0 - Не сжимать или по умолчанию
--		1 - Сжимать
DECLARE @Compression as int = 1
-- Имя почтового профиля, для отправки электонной почты									
DECLARE @profilename as nvarchar(100) = 'sql_backup'
-- Получатели сообщений электронной почты, разделенные знаком ";"				
DECLARE @recipients as nvarchar(500) = 'rogoznikov@lamel.biz'

-------------------------------------------
-- СЛУЖЕБНЫЕ ПЕРЕМЕННЫЕ
DECLARE @SQLString NVARCHAR(4000)
DECLARE @DBName varchar(100)
DECLARE @subdir NVARCHAR(400) = ''
DECLARE @subject as NVARCHAR(100) = ''
DECLARE @finalmassage as NVARCHAR(1000) = ''

-------------------------------------------
-- ТЕЛО СКРИПТА
use master

-- Отбоерем базы для выполнения операций
DECLARE DBcursor CURSOR FOR 
(


			SELECT d.name as DatabaseName 
	FROM sys.databases d
	WHERE d.name <> 'tempdb'
		AND d.state_desc = 'ONLINE' -- база должна быть в сети
	and d.name not in (SELECT d.name FROM sys.databases d
left join msdb.dbo.backupset s on d.name=s.database_name
INNER JOIN msdb.dbo.backupmediafamily m ON s.media_set_id = m.media_set_id
WHERE d.name <>'temp' and m.physical_device_name like '\\%' and s.backup_start_date>dateadd(hour,-10,getdate())) --делает бэкап если не было сетевого бэкапа за последние 24 часа
		AND d.name like @namelike -- база должна содержать указанное слово 
)

-- Цикл по всем базам, попавшим в выборку
OPEN DBcursor
FETCH NEXT FROM DBcursor INTO @DBName
WHILE @@FETCH_STATUS = 0
BEGIN

	-- Создаем вложенный каталог с именем базы
	SET @subdir = @Path + '\' + @@SERVERNAME+ '\'+ @DBName
	BEGIN TRY 
		EXEC master.dbo.xp_create_subdir @subdir 
	END TRY
	BEGIN CATCH
		-- Ошбика выполнения операции
		SET @finalmassage = @finalmassage + 'Ошибка создания каталога: ' + @subdir + CHAR(13) + CHAR(13)
			+ 'Код ошибки: ' + CAST(ERROR_NUMBER() as nvarchar(10)) + CHAR(13) + CHAR(13)
			+ 'Текст ошибки: ' + ERROR_MESSAGE()  + CHAR(13) + CHAR(13)
			+ 'Текст T-SQL:' + CHAR(13) + @SQLString + CHAR(13) + CHAR(13) 
		SET @subdir = '' 
	END CATCH;
	
	IF @subdir <> ''
	BEGIN
		
		-- Формируем строку для исполнения
		IF @Type = 3 SET @SQLString = 
			N'BACKUP LOG [' + @DBName + ']
			TO DISK = N''' + @subdir + '\\' + @DBName + '_' + Replace(CONVERT(nvarchar, GETDATE(), 126),':','-') + '.trn'' '
		ELSE SET @SQLString = 
			N'BACKUP DATABASE [' + @DBName + ']
			TO DISK = N'''+ @subdir + '\\' + @DBName + '_' + Replace(CONVERT(nvarchar, GETDATE(), 126),':','-') + '.bak'' '
		set @SQLString = @SQLString +		  
			'WITH NOFORMAT, NOINIT,
			SKIP, NOREWIND, NOUNLOAD, STATS = 10'
		IF @Compression = 1 SET @SQLString = @SQLString + ', COMPRESSION'
		IF @Type = 0 SET @SQLString = @SQLString + ', COPY_ONLY'
		IF @Type = 2 SET @SQLString = @SQLString + ', DIFFERENTIAL'

		-- Выводим и выполняем полученную инструкцию
		PRINT @SQLString
		BEGIN TRY
			EXEC sp_executesql @SQLString
		END TRY
		BEGIN CATCH  
			-- Ошбика выполнения операции
			SET @finalmassage = @finalmassage + 'Ошибка создания резервной копии базы ' + @DBName + ' в каталог ' + @subdir + CHAR(13) + CHAR(13)
				+ 'Код ошибки: ' + CAST(ERROR_NUMBER() as nvarchar(10)) + CHAR(13) + CHAR(13)
				+ 'Текст ошибки: ' + ERROR_MESSAGE()  + CHAR(13) + CHAR(13)
				+ 'Текст T-SQL:' + CHAR(13) + @SQLString + CHAR(13) + CHAR(13)  
		END CATCH;
	END
	
	-- Следующий элемент цикла
    FETCH NEXT FROM DBcursor 
    INTO @DBName

END
CLOSE DBcursor;
DEALLOCATE DBcursor;

-- Формируем сообщение об успешном или не успешном выполнении операций
IF @finalmassage = ''
BEGIN
	-- Успешное выполнение всех операций
	SET @subject = 'Успешное создание резервных копий баз данных на сервере  ' + @@SERVERNAME 
	SET @finalmassage = 'Успешное создание резервных копий всех баз данных на сервере  ' + @@SERVERNAME 
END
ELSE
	-- Были ошибки
	SET @subject = 'БЫЛИ ОШИБКИ при создании резервных копий баз данных на сервере  ' + @@SERVERNAME 

-- Если задан профиль электронной почты, отправим сообщение
IF @profilename <> ''
EXEC msdb.dbo.sp_send_dbmail
    @profile_name = @profilename,
    @recipients = @recipients,
    @body = @finalmassage,
    @subject = @subject;

-- Выводим сообщение о результате
SELECT
	@subject as subject, 
	@finalmassage as finalmassage 

GO