DECLARE @NameTable varchar(100) 
DECLARE Employee_Cursor CURSOR FOR 
SELECT DISTINCT OBJECT_NAME(T1.object_id) AS NameTable
FROM sys.dm_db_index_physical_stats (NULL, NULL, NULL, NULL, NULL) AS T1
WHERE index_id > 0 
 AND avg_fragmentation_in_percent > 5.0 AND page_count > 128
 AND OBJECT_NAME(T1.database_id) NOT LIKE 'sys%'
OPEN Employee_Cursor;    
FETCH NEXT FROM Employee_Cursor INTO @NameTable;  WHILE @@FETCH_STATUS = 0  
BEGIN
 DBCC DBREINDEX (@NameTable);
 PRINT(@NameTable);
    FETCH NEXT FROM Employee_Cursor INTO @NameTable;
END;    
CLOSE Employee_Cursor;  DEALLOCATE Employee_Cursor;
EXEC sp_updatestats;
DBCC FREEPROCCACHE;