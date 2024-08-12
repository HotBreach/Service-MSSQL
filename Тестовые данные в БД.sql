DECLARE @cnt INT = 10

DELETE FROM dbo.Customers

;WITH
    E1(N) AS (
        SELECT * FROM (
            VALUES
                (1),(1),(1),(1),(1),
                (1),(1),(1),(1),(1)
        ) t(N)
    ),
    E2(N) AS (SELECT 1 FROM E1 a, E1 b),
    E4(N) AS (SELECT 1 FROM E2 a, E2 b),
    E8(N) AS (SELECT 1 FROM E4 a, E4 b)
INSERT INTO dbo.Customers (FullName, Email, Phone)
SELECT TOP(@cnt)
      [FullName] = txt
    , [Email] = LOWER(txt) + LEFT(ABS(CHECKSUM(NEWID())), 3) + '@gmail.com'
    , [Phone] =
        '+38 (' + LEFT(ABS(CHECKSUM(NEWID())), 3) + ') ' +
            STUFF(STUFF(LEFT(ABS(CHECKSUM(NEWID())), 9)
                , 4, 1, '-')
                    , 7, 1, '-')
FROM E8
CROSS APPLY (
    SELECT TOP(CAST(RAND(N) * 10 AS INT)) txt
    FROM (
        VALUES
            (N'Boris_the_Blade'),
            (N'John'), (N'Steve'),
            (N'Mike'), (N'Phil'),
            (N'Sarah'), (N'Ann'),
            (N'Andrey'), (N'Liz'),
            (N'Stephanie')
    ) t(txt)
    ORDER BY NEWID()
) 