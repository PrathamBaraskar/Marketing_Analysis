

select ProductID,ProductName , Price, 
case 
	when Price < 50 then 'low'
	when Price between 51 and 200 then 'medium'
	else 'high'
end as PriceCategory
from dbo.products;
