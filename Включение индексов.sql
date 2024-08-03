USE rashetbudget
EXEC sp_MSforeachtable 'ALTER INDEX ALL ON ? SET (ALLOW_PAGE_LOCKS = ON)' 
GO