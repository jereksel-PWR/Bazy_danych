DROP TABLE BigTable
DROP TABLE Orders1
DROP TABLE [Order Details1]
DROP TABLE Employees1
DROP TABLE Customers1
DROP TABLE Products1
DROP TABLE BigTable1

SELECT DISTINCT [OrderDate]
      ,[RequiredDate]
      ,[ShippedDate]
      ,[ShipVia]
      ,[Freight]
      ,[ShipName]
      ,[ShipAddress]
      ,[ShipCity]
      ,[ShipRegion]
      ,[ShipPostalCode]
      ,[ShipCountry]
	  ,[Order Details].[UnitPrice] AS "Order Details UnitPrice"
      ,[Quantity]
      ,[Discount]
      ,[CompanyName]
      ,[ContactName]
      ,[ContactTitle]
      ,Customers.[Address] as "Customer Address"
      ,Customers.[City] as "Customer City"
      ,Customers.[Region] as "Customer Region"
      ,Customers.[PostalCode] as "Customer PostalCode"
      ,Customers.[Country] as "Customer Country"
      ,[Phone]
      ,[Fax]
      ,[LastName]
      ,[FirstName]
      ,[Title]
      ,[TitleOfCourtesy]
      ,[BirthDate]
      ,[HireDate]
      ,Employees.[Address] AS "Employee Address"
      ,Employees.[City] AS "Employee City"
      ,Employees.[Region] AS "Employee Region"
      ,Employees.[PostalCode] AS "Employee PostalCode"
      ,Employees.[Country] AS "Employee Country"
      ,[HomePhone]
      ,[Extension]
  --    ,[Photo]
  --    ,[Notes]
      ,[ReportsTo]
      ,[PhotoPath]
      ,[ProductName]
      ,[QuantityPerUnit]
      ,Products.[UnitPrice] as "Product UnitPrice"
      ,[UnitsInStock]
      ,[UnitsOnOrder]
      ,[ReorderLevel]
      ,[Discontinued]
	  
INTO BigTable
FROM [Order Details]
INNER JOIN Orders ON Orders.OrderID = [Order Details].OrderID
INNER JOIN Customers ON Orders.CustomerID = Customers.CustomerID
INNER JOIN Employees ON Orders.EmployeeID = Employees.EmployeeID
INNER JOIN Products ON [Order Details].ProductID = Products.ProductID


/* Zadanie 2 */

/*
DECLARE @i int = 0
WHILE @i < 1000 BEGIN
    SET @i = @i + 1

	INSERT INTO BigTable
	SELECT * FROM 
	(SELECT TOP 1 [OrderDate],[RequiredDate],[ShippedDate],[ShipVia],[Freight],[ShipName],[ShipAddress],[ShipCity],[ShipRegion],[ShipPostalCode],[ShipCountry] FROM Orders ORDER BY NEWID() ) AS test4,
	(SELECT TOP 1 [Order Details].[UnitPrice] AS "Order Details UnitPrice" ,[Quantity] ,[Discount] FROM [Order Details] ORDER BY NEWID() ) AS test2,
	(SELECT TOP 1 [CompanyName],[ContactName],[ContactTitle],Customers.[Address] as "Customer Address",Customers.[City] as "Customer City",Customers.[Region] as "Customer Region",Customers.[PostalCode] as "Customer PostalCode",Customers.[Country] as "Customer Country",[Phone],[Fax] FROM Customers ORDER BY NEWID()) AS test1,
	(SELECT TOP 1 [LastName],[FirstName],[Title],[TitleOfCourtesy],[BirthDate],[HireDate],Employees.[Address] AS "Employee Address",Employees.[City] AS "Employee City",Employees.[Region] AS "Employee Region",Employees.[PostalCode] AS "Employee PostalCode",Employees.[Country] AS "Employee Country",[HomePhone],[Extension],[ReportsTo],[PhotoPath] FROM Employees ORDER BY NEWID() ) AS test3,
	(SELECT TOP 1 [ProductName],[QuantityPerUnit],Products.[UnitPrice] as "Product UnitPrice",[UnitsInStock],[UnitsOnOrder],[ReorderLevel],[Discontinued]FROM Products ORDER BY NEWID() ) AS test5

END
*/

/* Zadanie 2 (nowe) */


DECLARE @i int = 0
WHILE @i < 1000 BEGIN
    SET @i = @i + 1

	DECLARE @temp int;
	DECLARE @randimie AS varchar(30)
	DECLARE @randnazwisko AS varchar(30)
	DECLARE @randnazwaproduktu AS varchar(30)
	DECLARE @randnazwafirmy AS varchar(30)
	DECLARE @randnazwastatku AS varchar(30)

	SELECT @temp = CONVERT(INT, (20+1)*RAND())
	SET @randimie = 'Imie ' + CAST(@temp AS VARCHAR)
	SET @randnazwisko = 'Nazwisko ' + CAST(@temp AS VARCHAR)
	SET @randnazwaproduktu = 'Nazwa Produktu ' + CAST(@temp AS VARCHAR)
	SET @randnazwastatku = 'Nazwa statku ' + CAST(@temp AS VARCHAR)
	SET @randnazwafirmy = 'Nazwa firmy ' + CAST(@temp AS VARCHAR)

	insert into BigTable
	values (
NULL,NULL,NULL,NULL,NULL,@randnazwastatku,'aaaaa',NULL,NULL,NULL,
NULL,'4.60',7,6,@randnazwafirmy,NULL,NULL,NULL,NULL,NULL,
NULL,NULL,NULL,NULL,@randimie,@randnazwisko,NULL,NULL,NULL,NULL,
NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,@randnazwaproduktu,
NULL,'4.60',NULL,NULL,NULL,'false')




END





/* Zadanie 3 */

/* Employees */

SELECT DISTINCT [LastName]
      ,[FirstName]
      ,[Title]
      ,[TitleOfCourtesy]
      ,[BirthDate]
      ,[HireDate]
      ,"Employee Address"
      ,"Employee City"
      ,"Employee Region"
      ,"Employee PostalCode"
      ,"Employee Country"
      ,[HomePhone]
      ,[Extension]
   --   ,[Photo]
   --   ,[Notes]
      ,[ReportsTo]
      ,[PhotoPath]

INTO Employees1
FROM BigTable
 
ALTER TABLE Employees1
ADD EmployeeID INT IDENTITY(1,1)



/* Customers (o 2 mniej - nic nie zamówili) */

SELECT DISTINCT [CompanyName]
      ,[ContactName]
      ,[ContactTitle]
      ,[Customer Address]
      ,[Customer City]
      ,[Customer Region]
      ,[Customer PostalCode]
      ,[Customer Country]
      ,[Phone]
      ,[Fax]
	  
INTO Customers1
FROM BigTable

ALTER TABLE Customers1
ADD CustomerID INT IDENTITY(1,1)


/* Products */

SELECT DISTINCT [ProductName]
      ,[QuantityPerUnit]
      ,[Product UnitPrice]
      ,[UnitsInStock]
      ,[UnitsOnOrder]
      ,[ReorderLevel]
      ,[Discontinued]

INTO Products1
FROM BigTable

ALTER TABLE Products1
ADD ProductID INT IDENTITY(1,1)

/* Tutaj zaczynaj¹ siê schody */

/* Orders */

/* O 4 mniej ni¿ w Orders */

SELECT DISTINCT
       EmployeeID
	  ,CustomerID
	  ,[OrderDate]
      ,[RequiredDate]
      ,[ShippedDate]
      ,[ShipVia]
      ,[Freight]
      ,[ShipName]
      ,[ShipAddress]
      ,[ShipCity]
      ,[ShipRegion]
      ,[ShipPostalCode]
      ,[ShipCountry]

INTO Orders1
FROM BigTable

INNER JOIN Employees1 
ON
BigTable.FirstName = Employees1.FirstName AND
BigTable.LastName = Employees1.LastName

INNER JOIN Customers1
ON
BigTable.CompanyName = Customers1.CompanyName

ALTER TABLE Orders1
ADD OrderID INT IDENTITY(1,1)


 /* Order Details */

 SELECT DISTINCT [OrderID]
      ,[ProductID]
      ,"Order Details UnitPrice"
      ,[Quantity]
      ,[Discount]

INTO [Order Details1]
FROM BigTable

INNER JOIN Products1
ON

Products1.[ProductName] = BigTable.ProductName

INNER JOIN Orders1
ON

((BigTable.[OrderDate] = Orders1.[OrderDate]) OR (BigTable.[OrderDate] IS NULL AND Orders1.[OrderDate] IS NULL)) AND 
((BigTable.[RequiredDate] = Orders1.[RequiredDate]) OR (BigTable.[RequiredDate] IS NULL AND Orders1.[RequiredDate] IS NULL)) AND 
((BigTable.[ShippedDate] = Orders1.[ShippedDate]) OR (BigTable.[ShippedDate] IS NULL AND Orders1.[ShippedDate] IS NULL)) AND 
((BigTable.[ShipVia] = Orders1.[ShipVia]) OR (BigTable.[ShipVia] IS NULL AND Orders1.[ShipVia] IS NULL)) AND 
((BigTable.[Freight] = Orders1.[Freight]) OR (BigTable.[Freight] IS NULL AND Orders1.[Freight] IS NULL)) AND 
((BigTable.[ShipName] = Orders1.[ShipName]) OR (BigTable.[ShipName] IS NULL AND Orders1.[ShipName] IS NULL)) AND 
((BigTable.[ShipAddress] = Orders1.[ShipAddress]) OR (BigTable.[ShipAddress] IS NULL AND Orders1.[ShipAddress] IS NULL)) AND 
((BigTable.[ShipCity] = Orders1.[ShipCity]) OR (BigTable.[ShipCity] IS NULL AND Orders1.[ShipCity] IS NULL)) AND 
((BigTable.[ShipRegion] = Orders1.[ShipRegion]) OR (BigTable.[ShipRegion] IS NULL AND Orders1.[ShipRegion] IS NULL)) AND 
((BigTable.[ShipPostalCode] = Orders1.[ShipPostalCode]) OR (BigTable.[ShipPostalCode] IS NULL AND Orders1.[ShipPostalCode] IS NULL)) AND 
((BigTable.[ShipCountry] = Orders1.[ShipCountry]) OR (BigTable.[ShipCountry] IS NULL AND Orders1.[ShipCountry] IS NULL))


/* Ponowne z³¹czenie */

SELECT [OrderDate]
      ,[RequiredDate]
      ,[ShippedDate]
      ,[ShipVia]
      ,[Freight]
      ,[ShipName]
      ,[ShipAddress]
      ,[ShipCity]
      ,[ShipRegion]
      ,[ShipPostalCode]
      ,[ShipCountry]
	  ,"Order Details UnitPrice"
      ,[Quantity]
      ,[Discount]
      ,[CompanyName]
      ,[ContactName]
      ,[ContactTitle]
      ,[Customer Address]
      ,[Customer City]
      ,[Customer Region]
      ,[Customer PostalCode]
      ,[Customer Country]
      ,[Phone]
      ,[Fax]
      ,[LastName]
      ,[FirstName]
      ,[Title]
      ,[TitleOfCourtesy]
      ,[BirthDate]
      ,[HireDate]
      ,"Employee Address"
      ,"Employee City"
      ,"Employee Region"
      ,"Employee PostalCode"
      ,"Employee Country"
      ,[HomePhone]
      ,[Extension]
      ,[ReportsTo]
      ,[PhotoPath]
      ,[ProductName]
      ,[QuantityPerUnit]
      ,"Product UnitPrice"
      ,[UnitsInStock]
      ,[UnitsOnOrder]
      ,[ReorderLevel]
      ,[Discontinued]
	  
INTO BigTable1
FROM Orders1
INNER JOIN [Order Details1] ON Orders1.OrderID = [Order Details1].OrderID
INNER JOIN Customers1 ON Orders1.CustomerID = Customers1.[CustomerID]
INNER JOIN Employees1 ON Orders1.EmployeeID = Employees1.EmployeeID
INNER JOIN Products1 ON [Order Details1].ProductID = Products1.ProductID

