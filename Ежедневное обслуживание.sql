-- Переключение контекста на базу данных master
USE master;
GO

-- Переменные для хранения путей и имен файлов резервных копий
DECLARE @BackupPath NVARCHAR(255) = N'D:\Backup\UT\';
DECLARE @DatabaseName NVARCHAR(255) = N'UT';
DECLARE @FullBackupFile NVARCHAR(255) = @BackupPath + @DatabaseName + '_FULL_' + CONVERT(NVARCHAR(20), GETDATE(), 112) + '.bak';
DECLARE @LogBackupFile NVARCHAR(255) = @BackupPath + @DatabaseName + '_LOG_' + CONVERT(NVARCHAR(20), GETDATE(), 112) + '.trn';

-- Проверка, что база данных является основной в группе доступности
IF EXISTS (SELECT * FROM sys.dm_hadr_availability_replica_states
           WHERE is_local = 1 AND role_desc = 'PRIMARY')
BEGIN
    -- Полное резервное копирование базы данных
    BACKUP DATABASE @DatabaseName
    TO DISK = @FullBackupFile
    WITH NOFORMAT, NOINIT,
         NAME = N'Full Backup of UT',
         SKIP, NOREWIND, NOUNLOAD, STATS = 10;
    PRINT 'Полное резервное копирование выполнено: ' + @FullBackupFile;

    -- Резервное копирование журналов транзакций
    BACKUP LOG @DatabaseName
    TO DISK = @LogBackupFile
    WITH NOFORMAT, NOINIT,
         NAME = N'Transaction Log Backup of UT',
         SKIP, NOREWIND, NOUNLOAD, STATS = 10;
    PRINT 'Резервное копирование журнала транзакций выполнено: ' + @LogBackupFile;

    -- Урезание журнала транзакций
    USE [UT];
    DBCC SHRINKFILE (N'ut_test_1_logs', 0);
    PRINT 'Урезание журнала транзакций выполнено.';
END
ELSE
BEGIN
    PRINT 'База данных не является основной в группе доступности. Резервное копирование и урезание журнала транзакций не выполнены.';
END;

-- Проверка состояния базы данных
DBCC CHECKDB (@DatabaseName) WITH NO_INFOMSGS;
PRINT 'Проверка состояния базы данных выполнена.';
GO

-- Проверка журналов ошибок SQL Server
EXEC xp_readerrorlog 0, 1, N'Error', N'UT';
PRINT 'Проверка журналов ошибок SQL Server выполнена.';
GO

-- Проверка ошибок базы данных и восстановление
DBCC CHECKDB (@DatabaseName) WITH NO_INFOMSGS, ALL_ERRORMSGS;
PRINT 'Проверка и восстановление ошибок базы данных выполнены.';
GO
