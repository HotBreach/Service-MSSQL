SELECT DB_NAME(T1.database_id) AS BaseName,
       OBJECT_NAME(T1.object_id, T1.database_id) AS TableName,
       T2.name AS IndexName,
       T1.page_count,
       T1.index_type_desc,
       T1.avg_fragmentation_in_percent
FROM sys.dm_db_index_physical_stats (NULL, NULL, NULL, NULL, 'LIMITED') AS T1
LEFT JOIN sys.indexes AS T2
    ON T1.object_id = T2.object_id
    AND T1.index_id = T2.index_id
WHERE T1.index_id > 0 
  AND T1.avg_fragmentation_in_percent > 5.0 
  AND T1.page_count > 128
  AND OBJECT_NAME(T1.object_id, T1.database_id) NOT LIKE 'sys%'
ORDER BY T1.avg_fragmentation_in_percent DESC;
