select 
	EngagementID,
	ContentID, 
	CampaignID,
	ProductID, 
	upper(replace(ContentType, 'Socialmedia' , 'Social Media')) as ContentType,
	left(ViewsClicksCombined, Charindex('-', ViewsClicksCombined) - 1 ) as Views,
	right(ViewsClicksCombined, len(ViewsClicksCombined) - Charindex('-', ViewsClicksCombined)) as Clicks,
	Likes, 
	format(convert(date,EngagementDate), 'dd.MM.yyyy') as EngagementDate
from 
	dbo.engagement_data
where 
	ContentType != 'newsletter'