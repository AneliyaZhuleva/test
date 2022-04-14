--цифрите от 0 до 9 подредени по произволед ред

CREATE VIEW [dbo].[vwIntNumbers]
AS
SELECT TOP 10 *
FROM IntNumbers
ORDER BY NEWID()
GO
