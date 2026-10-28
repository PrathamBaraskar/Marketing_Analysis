select 
	c.CustomerID,
	c.CustomerName,
	c.Email,
	c.Gender,
	c.Age,
	g.Country,
	g.City
from 
	dbo.customers as c 
left join 
	dbo.geography as g
on 
	c.GeographyID = g.GeographyID;
	