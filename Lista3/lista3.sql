/* Zadanie 1 */

DROP PROCEDURE odwrocTabele

CREATE PROCEDURE odwrocTabele @Agregacja varchar(50)
AS

DROP TABLE Obroty

/* Stworzenie nowej tabeli */
/* Do kt�rej wrzucimy istniej�ce towary */


SELECT DISTINCT Towar
INTO Obroty
FROM Sprzeda�;

/* Tworzenie kolumn z nazwami miesi�cy */

Declare @Pieniadze int
Declare @result varchar(50)
Declare @SQL NVARCHAR(1000)
Declare @SQL2 VarChar(1000)
declare @Miesiac varchar(20)
declare @Towar varchar(20)
declare kolumnaMiesiace cursor for
select DISTINCT Miesi�c from [Lista3].[dbo].[Sprzeda�]
open kolumnaMiesiace
fetch next from kolumnaMiesiace into @Miesiac
while @@FETCH_STATUS = 0
begin
select @Miesiac

SELECT @SQL = 'ALTER TABLE [Lista3].[dbo].[Obroty] ADD ' + @Miesiac + ' varchar(20)'

Exec (@SQL)

/******************************/


declare cursorTowar cursor for
select DISTINCT Towar from [Lista3].[dbo].[Sprzeda�]
open cursorTowar
fetch next from cursorTowar into @Towar
while @@FETCH_STATUS = 0
begin
select @Towar

SELECT @result = NULL

SELECT @SQL = 'SELECT @result=' + @Agregacja + '(Warto��) FROM Sprzeda� WHERE Towar = ''' + @Towar + ''' AND Miesi�c = ''' + @Miesiac + ''' GROUP BY Towar'


exec sp_executesql @SQL, 
                    N'@result varchar(50) output', @result output;


/*SELECT @SQL2 = 'UPDATE Obroty SET ' + @Miesiac + ' = ' + cast(@result, VARCHAR(50)) + ' WHERE Towar = ''' + @Towar + ''''*/

SELECT @SQL2 = 'UPDATE Obroty SET ' + @Miesiac + ' = ' + @result + ' WHERE Towar = ''' + @Towar + ''''

EXEC (@SQL2)

PRINT (@result)





fetch next from cursorTowar into @Towar
End
close cursorTowar
deallocate cursorTowar

/******************************/

fetch next from kolumnaMiesiace into @Miesiac
End
close kolumnaMiesiace
deallocate kolumnaMiesiace
GO


EXEC odwrocTabele "SUM"



/* Zadanie 2 */

DROP TRIGGER InsKoncerty

CREATE TRIGGER InsKoncerty ON Koncerty
INSTEAD OF INSERT
AS
BEGIN

Declare @adres VarChar(100), @nazwaZespolu VarChar(100), @nazwaKlubu VarChar(100), @iloscCzlonkow int, @data date;

Declare @zespolIstnieje bit;

select @zespolIstnieje = 0;

Declare @klubIstnieje bit;

select @klubIstnieje = 0;


select
    @nazwaKlubu = [nazwa klubu],
    @adres = [adres],
    @nazwaZespolu = [nazwa zespolu],
	@iloscCzlonkow = [ilo�� cz�onk�w],
	@data = [data]
from
    inserted
	

/* Czy krotka ju� istnieje ? */

IF EXISTS (SELECT *
  FROM Koncerty
WHERE
    [nazwa klubu] = @nazwaKlubu AND 
	[adres] = @adres AND 
    [nazwa zespolu] =  @nazwaZespolu AND 
	[ilo�� cz�onk�w] = @iloscCzlonkow AND
	[data] = @data 
	)

BEGIN
RAISERROR ('Krotka ju� istnieje', 16, 1);
RETURN 
END;


/* Czy ten zesp� ju� istnieje ? */

IF EXISTS (SELECT *
  FROM Zesp�
WHERE
    [nazwa] =  @nazwaZespolu
	)

BEGIN

/* Zesp� istnieje */
IF NOT EXISTS (SELECT *
  FROM Zesp�
WHERE
    [nazwa] =  @nazwaZespolu AND 
	[ilo�� cz�onk�w] = @iloscCzlonkow
	)

BEGIN
/* Ale ma podane z�e dane */
RAISERROR ('Nieprawid�owe dane o zespole', 16, 1);
RETURN 
END;
/* Ma podane dobre dane - nie b�dziemy po p�niej tworzy� */
select @zespolIstnieje = 1;
END;


/* Czy ten Klub ju� istnieje ? */

IF EXISTS (SELECT *
  FROM Klub
WHERE
    [nazwa] =  @nazwaKlubu
	)

BEGIN

/* Klub istnieje */
IF NOT EXISTS (SELECT *
  FROM Klub
WHERE
    [nazwa] =  @nazwaKlubu AND 
	[adres] = @adres
	)

BEGIN
/* Ale ma podane z�e dane */
RAISERROR ('Nieprawid�owe dane o klubie', 16, 1);
RETURN 
END;
/* Ma podane dobre dane - nie b�dziemy po p�niej tworzy� */
select @klubIstnieje = 1;
END;



/* Tworzymy nowy zesp� je�li on jeszcze nie istnieje */

IF (@zespolIstnieje = 0)
BEGIN

INSERT INTO [Zesp�]
VALUES (@nazwaZespolu,@iloscCzlonkow);
END

/* Tworzymy nowy klub je�li on jeszcze nie istnieje */

IF (@klubIstnieje = 0)
BEGIN

INSERT INTO Klub
VALUES (@nazwaKlubu,@adres);
END


INSERT INTO Koncert
VALUES (@nazwaKlubu,@nazwaZespolu, @data);

END




DROP TRIGGER UpdKoncerty


CREATE TRIGGER UpdKoncerty ON [Koncerty]
INSTEAD OF UPDATE AS
BEGIN

DECLARE @nowaData date
DECLARE @staraData date
DECLARE @nazwaKlubu varchar(50)
DECLARE @nazwaZespo�u varchar(50)
DECLARE @nazwa varchar(50)
DECLARE @nowyAdres varchar(100)
DECLARE @staraNazwa varchar(100)
DECLARE @nowaNazwa varchar(100)
DECLARE @nowaIloscCzlonkow int
DECLARE @adres varchar(100)
DECLARE @iloscCzlonkow int

IF (UPDATE([ilo�� cz�onk�w])) -- Robimy update ilo�ci cz�onk�w
BEGIN

	SET @nowaIloscCzlonkow = (SELECT [ilo�� cz�onk�w] FROM inserted)
	SET @nazwa = (SELECT [nazwa zespolu] FROM inserted)
	UPDATE Zesp� SET [ilo�� cz�onk�w] = @nowaIloscCzlonkow WHERE [nazwa] = @nazwa

END;

IF (UPDATE([adres])) -- Robimy update adresu klubu
BEGIN

	SET @nowyAdres = (SELECT [adres] FROM inserted)
	SET @nazwa = (SELECT [nazwa klubu] FROM inserted)
	UPDATE Klub SET [adres] = @nowyAdres WHERE [nazwa] = @nazwa

END;

IF (UPDATE([nazwa zespolu])) -- Robimy update nazwy zespo�u
BEGIN

	SET @staraNazwa = (SELECT [nazwa zespolu] FROM deleted)
	SET @nowaNazwa = (SELECT [nazwa zespolu] FROM inserted)
	SET @iloscCzlonkow =  (SELECT [ilo�� cz�onk�w] FROM inserted)

	INSERT INTO Zesp� VALUES (@nowaNazwa, @iloscCzlonkow)

	UPDATE Koncert SET [nazwa zespolu] = @nowaNazwa WHERE [nazwa zespolu] = @staraNazwa

	DELETE FROM Zesp� WHERE nazwa = @staraNazwa

END;


IF (UPDATE([nazwa klubu])) -- Robimy update nazwy klubu
BEGIN

	SET @staraNazwa = (SELECT [nazwa klubu] FROM deleted)
	SET @nowaNazwa = (SELECT [nazwa klubu] FROM inserted)
	SET @adres =  (SELECT adres FROM inserted)

	INSERT INTO Klub VALUES (@nowaNazwa, @adres)

	UPDATE Koncert SET [nazwa klubu] = @nowaNazwa WHERE [nazwa klubu] = @staraNazwa

	DELETE FROM Klub WHERE nazwa = @staraNazwa

END;



IF (UPDATE(data)) -- Robimy update daty
BEGIN

	SET @staraData = (SELECT data FROM deleted)
	SET @nowaData = (SELECT data FROM inserted)
	SET @nazwaKlubu = (SELECT [nazwa klubu] FROM inserted)
	SET @nazwaZespo�u = (SELECT [nazwa zespolu] FROM inserted)

	UPDATE Koncert SET data = @nowaData WHERE data = @staraData AND [nazwa klubu] = @nazwaKlubu AND [nazwa zespolu] = @nazwaZespo�u


END;


END




DROP TRIGGER DelKoncerty


CREATE TRIGGER DelKoncerty ON [Koncerty]
INSTEAD OF DELETE AS
BEGIN


Declare @adres VarChar(100), @nazwaZespolu VarChar(100), @nazwaKlubu VarChar(100), @iloscCzlonkow int, @data date;

select
    @nazwaKlubu = [nazwa klubu],
    @adres = [adres],
    @nazwaZespolu = [nazwa zespolu],
	@iloscCzlonkow = [ilo�� cz�onk�w],
	@data = [data]
from
    deleted



delete FROM Koncert WHERE [nazwa klubu] = @nazwaKlubu AND [nazwa zespolu] = @nazwaZespolu AND data = @data



IF NOT EXISTS (SELECT *
  FROM Koncert
WHERE
	[nazwa klubu] = @nazwaKlubu
	)

BEGIN

delete FROM Klub WHERE nazwa = @nazwaKlubu

END;

IF NOT EXISTS (SELECT *
  FROM Koncert
WHERE
	[nazwa zespolu] = @nazwaZespolu
	)

BEGIN

delete FROM Zesp� WHERE nazwa = @nazwaZespolu

END;



END


INSERT INTO Koncerty

VALUES('Hawana','Imprezowa 10','Metallica','2011-12-04','4')



INSERT INTO Koncerty

VALUES('test','test','test','2011-12-04','23')



UPDATE Koncerty
SET [ilo�� cz�onk�w]=2
WHERE [nazwa zespolu]='Doda';

UPDATE Koncerty
SET [adres] = 'testowa 20a'
WHERE [nazwa klubu]='test';

UPDATE Koncerty
SET [nazwa zespolu] = 'Doda'
WHERE [nazwa zespolu] = 'test';

UPDATE Koncerty
SET [nazwa klubu] = 'Nowy klub'
WHERE [nazwa klubu] = 'test';

UPDATE Koncerty
SET data = '07-11-1994'
WHERE [nazwa klubu] = 'Medyk';


DELETE From Koncerty
WHERE [nazwa zespolu] = 'Doda'