-- Fixing the anamolly by updating the correct date in year founded which 2013
update plum.unicorn_companies pc
set pc.`Year Founded` = 2013
where pc.Company = 'Yidian Zixun';

-- Fixing column names
Alter table plum.unicorn_companies 
change column `Year Founded` year_founded varchar(50);

Alter table plum.unicorn_companies 
change column `Country/Region` country_or_region varchar(50);

Alter table plum.unicorn_companies 
change column `Select Investors` select_investors varchar(200);

--
Select 
year(pc.date_joined),
count(pc.Company)
from plum.unicorn_companies pc
group by 1
order by 1 desc;

-- count of companies becoming unicorn by years
 Select 
 year(pc.date_joined),
 count(pc.Company)
 from plum.unicorn_companies pc
 group by 1
 order by 2 desc;

-- Years taken by companie to become unicorn
Select 
pc.Company,
((pc.date_joined) - pc.year_founded) as year_to_join 
from plum.unicorn_companies pc
order by 2 asc;

-- Average years taken to become unizorn
Select 
round(avg(year_to_join),0) as avg_years_to_unicorn
from (Select ((pc.date_joined) - pc.year_founded) as year_to_join 
		from plum.unicorn_companies pc) as avg_years;

-- Companies which took greater than average years to become unicorn
Select pc.Company,
((pc.date_joined) - pc.year_founded) as no_of_years 
from plum.unicorn_companies pc 
where ((pc.date_joined) - pc.year_founded)  >= (Select round(avg(year_to_join),0) as avg_years_to_unicorn
												  from 
                                                  (Select ((pc.date_joined) - pc.year_founded) as year_to_join 
												   from plum.unicorn_companies pc
												   ) as avg_years
												   );
                                                   
 -- No.of companies which took atleast 7 or more years to become unicorn
 Select count(pc.Company) as no_of_companies from plum.unicorn_companies pc 
	where ((pc.date_joined) - pc.year_founded)  >= (Select round(avg(year_to_join),0) as avg_years_to_unicorn
														from (Select ((pc.date_joined) - pc.year_founded) as year_to_join 
																from plum.unicorn_companies pc
															  ) as avg_years
													 );
                                                     
 -- No.of companies which took less than 7 years to become unicorn
Select 
count(pc.Company) as no_of_companies 
from plum.unicorn_companies pc 
where ((pc.date_joined) - pc.year_founded) < (Select round(avg(year_to_join),0) as avg_years_to_unicorn
														from (Select ((pc.date_joined) - pc.year_founded) as year_to_join 
																from plum.unicorn_companies pc
															  ) as avg_years
													 );
											
 --  Most unicorns per continent  
Select pc.continent,
count(pc.Company) as count_unicorns
from plum.unicorn_companies pc
group by 1
order by 2 desc;              
 
-- Most unicorns per country
Select pc.country_or_region,
count(pc.Company) as count_companies
from plum.unicorn_companies pc
group by 1
order by 2 desc;   
 
 -- Most unicorns per city
Select pc.City,
count(pc.Company) as count_companies
from plum.unicorn_companies pc
group by 1
order by 2 desc
 ;   
 
-- Average years to unicorn per country sorted by most uncorn
Select 
pc.country_or_region,
count(pc.Company) as count_companies,
round(avg(year(pc.Date_joined) - pc.year_founded),1) as avg_years_to_unicorn
from plum.unicorn_companies pc
group by 1
order by 2 desc;

-- Most valued country by valuations
Select 
pc.country_or_region,
count(pc.Company),
sum(replace(replace(pc.Valuation,'$',''),'B','')) as $valuation
from plum.unicorn_companies pc
group by 1
order by 2 desc;

-- Checking for irregularities in Funding
Select * from plum.unicorn_companies pc
where pc.Company not in (Select pc.company 
						 from plum.unicorn_companies pc
						 where pc.Funding like '%B' or pc.Funding like '%M');
 
 -- Funding per country excluding unknown funding
 select 
 country, 
 sum(actual_value)/1000000000 as valuation_billions
 from (select pc.country_or_region as country,
	   case when right(pc.funding,1) = 'B' then cast(substring(pc.funding, 2 ,length(pc.funding) - 2) as decimal(10,2)) * 1000000000
			when right(pc.funding,1) = 'M' then cast(substring(pc.funding, 2 ,length(pc.funding) - 2) as decimal(10,2)) * 1000000
				ELSE CAST(funding AS DECIMAL(10, 2)) end as actual_value
	   from plum.unicorn_companies pc
	   where pc.Company in (Select pc.company 
							from plum.unicorn_companies pc
							where pc.Funding like '%B' or pc.Funding like '%M')
							group by 1,2
							) as total_valuations
group by 1
order by 2 desc
;

