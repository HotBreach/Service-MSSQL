USE {database_name};  
GO  

SELECT
  OBJECT_NAME(i.object_id) AS TableName,
  i.name                   AS IndexName,
  i.index_id               AS IndexID,
  8 * SUM(a.used_pages)    AS 'Indexsize(KB)'
FROM
  sys.indexes AS i
  JOIN sys.partitions AS p ON p.object_id = i.object_id AND p.index_id = i.index_id
  JOIN sys.allocation_units AS a ON a.container_id = p.partition_id
GROUP BY
  i.OBJECT_ID, i.index_id, i.name
ORDER BY
  OBJECT_NAME(i.object_id),
  i.index_id