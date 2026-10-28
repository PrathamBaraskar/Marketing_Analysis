select 
	ReviewID, 
	CustomerID, 
	ProductID, 
	ReviewDate, 
	Rating, 
	Replace(ReviewText, '  ',' ') as ReviewText
from 
	dbo.customer_reviews