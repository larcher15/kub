/* CRIME PROJECT SQL CODE */

----------------------
-------CONTENTS-------
----------------------
/*
1. Load and Clean code
2. Make Database diagrams
3. Basic analysis
*/

-- Load the crime database
use crime
go

----------------------------------------
------	Load and clean the data	  ------
----------------------------------------

----------------------------------------
--- Data table number 1 - crime data ---
----------------------------------------

-- The total crime dataset containts all counties so select Welsh police forces and put the data into a separate table "Walesdata"
select
      *
	into [dbo].[Walesdata]
from [Crime].[dbo].[Cdata1]
where [reported by] in ('South Wales Police','North Wales Police','Gwent Police','Dyfed-Powys Police')

/*
A number of the data crime points were not from Wales so filtered out those with LSOA code not 
beginning with W. A  number were beginning with E (1688) which are england LSOAs, a number were also 
blank (17845) - decided to remove both of these since they are not a huge number out of the total.
*/

-- Delete crime data from July and August 2018 as other data obtained is not available for these dates
DELETE FROM [dbo].[Walesdata]
where [Month] in ('2018-07','2018-08')

-- Clean the Wales crime data, seperate month and year, add identity column
select
	identity(int) as CrimeIDnew -- add identity column
	,left([Month],4) as [Year] -- separate up month and year
	,right([Month],2) as [Months]
	,[reported by] as [Policedep]
	,[Longitude]
	,[Latitude]
	,[Location]
	,[LSOA code]
	,[LSOA name]
	,[Crime type]
into dbo.walesdataclean
from [dbo].[Walesdata]
where [LSOA code] like 'W%' -- filter out non wales LSOA or blank LSOAs

-- Clarify number of rows 
select
	count(*)
from dbo.walesdataclean -- correct number of rows 1,533,662

-- Assign each area to a healthboard area (the areas of the health data) and combine some crime types

;with CTE
as
(
select
	*,
	LEFT([LSOA name],len([LSOA name])-4) [area] -- Grab the area name from LSOA name column
from dbo.Walesdataclean
)
select
	*
	,case -- Assign the areas to their healthboards
		when [area] = 'Powys' then 'Powys Teaching Local Health Board'
		when [area] in ('Cardiff','The Vale of Glamorgan') then 'Cardiff and Vale University Local Health Board'
		when [area] in ('Bridgend','Neath Port Talbot','Swansea') then 'Abertawe Bro Morgannwg University Local Health Board'
		when [area] in ('Carmarthenshire','Ceredigion','Pembrokeshire') then 'Hywel Dda University Local Health Board'
		when [area] in ('Rhondda Cynon Taf') then 'Cwm Taf University Local Health Board'
		when [area] in ('Flintshire','Gwynedd','Isle of Anglesey','Conwy','Denbighshire','Wrexham') then 'Betsi Cadwaladr University Local Health Board'
		else 'Aneurin Bevan University Local Health Board'
	end [healthboardarea]
	,case -- Combine some crime types
		when [Crime type] in ('Bicycle theft','Other theft','Theft from the person') then 'Bike and other theft'
		when [Crime type] in ('Public disorder and weapons','Public order') then 'Public disorder'
		when [Crime type] in ('Violence and sexual offences','Violent crime') then 'Violence and sexual offences'
		when [Crime type] = 'Anti-social behaviour' then 'Anti-social behaviour'
		when [Crime type] = 'Burglary' then 'Burglary'
		when [Crime type] = 'Criminal damage and arson' then 'Criminal damage and arson'
		when [Crime type] = 'Drugs' then 'Drugs'
		when [Crime type] = 'Other crime' then 'Other crime'
		when [Crime type] = 'Possession of weapons' then 'Posession of weapons'
		when [Crime type] = 'Robbery' then 'Robbery'
		when [Crime type] = 'Shoplifting' then 'Shoplifting'
		when [Crime type] = 'Vehicle crime' then 'Vehicle crime'
		else NULL
	end [Crimetypealter]
into dbo.Walesdataclean1
from CTE

drop table Walesdataclean3
-----------------------------------------------
--- Data table number 2 - welsh health data ---
-----------------------------------------------

-- Have imported 9 data tables that need to be unpivoted

-- The CTE below was repeated nine times for the 9 different variables
select
	[F1]
	,[Date]
	,numofpatswhowaitover56daysfromLPMtoTherapyIntervention
into Tableii
from
(
select
	*
from [dbo].[Tablei]
) p
unpivot
(numofpatswhowaitover56daysfromLPMtoTherapyIntervention for [Date] in (
	[April 2013 ]
      ,[May 2013 ]
      ,[June 2013 ]
      ,[July 2013 ]
      ,[August 2013 ]
      ,[September 2013 ]
      ,[October 2013 ]
      ,[November 2013 ]
      ,[December 2013 ]
      ,[January 2014 ]
      ,[February 2014 ]
      ,[March 2014 ]
      ,[May 2014 ]
      ,[April 2014 ]
      ,[June 2014 ]
      ,[July 2014 ]
      ,[August 2014 ]
      ,[September 2014 ]
      ,[October 2014 ]
      ,[November 2014 ]
      ,[December 2014 ]
      ,[January 2015 ]
      ,[February 2015 ]
      ,[March 2015 ]
      ,[April 2015 ]
      ,[May 2015 ]
      ,[June 2015 ]
      ,[July 2015 ]
      ,[August 2015 ]
      ,[September 2015 ]
      ,[October 2015 ]
      ,[November 2015 ]
      ,[December 2015 ]
      ,[January 2016 ]
      ,[February 2016 ]
      ,[March 2016 ]
      ,[April 2016 ]
      ,[May 2016 ]
      ,[June 2016 ]
      ,[July 2016 ]
      ,[August 2016 ]
      ,[September 2016 ]
      ,[October 2016 ]
      ,[November 2016 ]
      ,[December 2016 ]
      ,[January 2017 ]
      ,[February 2017 ]
      ,[March 2017 ]
      ,[April 2017 ]
      ,[May 2017 ]
      ,[June 2017 ]
      ,[July 2017 ]
      ,[August 2017 ]
      ,[September 2017 ]
      ,[October 2017 ]
      ,[November 2017 ]
      ,[December 2017 ]
      ,[January 2018 ]
      ,[February 2018 ]
      ,[March 2018 ]
      ,[April 2018 ]
      ,[May 2018 ]
      ,[June 2018 ])) as unpvt

-- Join all the mental health data into one table
select
	a.*
	,b.[numofpatswaitedupto28daysfromreferaltoLMP] -- some of these are typos LMP and LPM are the same thing
	,c.[numofpatswaitedbet28and56daysfromreferaltoLMP]
	,d.[numofpatswhowaitedover56daysfromreferaltoLMP]
	,e.[totnumofLPMassessmentstakenduringmonth]
	,f.[totnumoftheraputicinterventionsstartduringmon]
	,g.[numofpatswaitupto28daysfromLPMtoTherapyIntervention]
	,h.[numofpatswaitbet28and56daysfromLPMtoTherapyIntervention]
	,i.[numofpatswhowaitover56daysfromLPMtoTherapyIntervention]
into mhealthcomb -- (mental health combined)
from tableaa a
join tablebb b
on b.F1 = a.F1 and b.[Date] = a.[Date]
join tablecc c
on c.F1 = b.F1 and c.[Date] = b.[Date]
join tabledd d
on d.F1 = c.F1 and d.[Date] = c.[Date]
join tableee e
on e.F1 = d.F1 and e.[Date] = d.[Date]
join tableff f
on f.F1 = e.F1 and f.[Date] = e.[Date]
join tablegg g
on g.F1 = f.F1 and g.[Date] = f.[Date]
join tablehh h
on h.F1 = g.F1 and h.[Date] = g.[Date]
join tableii i
on i.F1 = h.F1 and i.[Date] = h.[Date]

-- seperate month and year
select
	*
	,month([Date]) [Months]
	,year([Date]) [Year]
into mhealthclean
from mhealthcomb

-- join the healthboard IDs on and remove the Wales total

select
	a.*
	,b.HealthboardID
into mhealthclean1
from mhealthclean a
right join dimhealthboard1 b
on b.healthboard = a.F1
where [F1] != 'Wales'

-----------------------------------------------
--- Data table number 3 - welsh survey data ---
-----------------------------------------------

-- Data from the welsh health survey for number of those currently being treated for a mental illness
-- Note column "Number with any mental illness" is "Number of those 

select
*
from walesdatatab2

-- rename two column names as currently misleading
exec sp_rename 'walesdatatab2.[Number with any mental illness]', 'NumcurrtxforMI','COLUMN'
exec sp_rename 'walesdatatab2.[Mean comp score]', 'MeanSF36score','COLUMN'

---------------------------------------------
---  Data table number 4 Population data  ---
---------------------------------------------

-- Import and clean the population data 
select
	[Column 1] as Area
	,substring([Year],10,4) [Years]
	,PopulationofLA
into PopPiv
from
(
select
	*
from [dbo].populationdata
) p
unpivot
(PopulationofLA for [Year] in (
	   [Mid-year 2013]
      ,[Mid-year 2014]
      ,[Mid-year 2015]
      ,[Mid-year 2016]
      ,[Mid-year 2017]
)) as unpvt
where [Column 1] != ''

update PopPiv -- make spelling of one area consistent with other formats
set Area = 'The Vale of Glamorgan'
where Area = 'Vale of Glamorgan'

-- get population by HB area included

select distinct
	healthboardarea,
	area
into areajoin
from walesdataclean3

;with CTE
as
(
select
	a.*
	,b.healthboardarea
from poppiv a
inner join areajoin b
on a.area = b.area
)
select
	*
	,sum(cast(populationofLA as numeric)) over (partition by healthboardarea,[years]) [PopulationofHB]
into poppiv1
from CTE

----------------------------------------------------
--- Data table number 5 - welsh deprivation data ---
----------------------------------------------------

select distinct
	*
into [dbo].['Walesdeprivation1']
from [dbo].['Walesdeprivation']
----------------------------------------------
------------DATABASE DIAGRAM CREATION --------
----------------------------------------------

---- Create geo_id dim table

select distinct
	[LSOA code]
	,[LSOA Name (English)]
	,[Local Authority (LA) code] as LAcode
	,[LA Name (English)] as AreaID
	,[BUA Population Proportion]
	,[WIMD 2014 LSOA Rank] as [DeprivationScore]
into DimGeo
from [dbo].['Walesdeprivation']

update Dimgeo -- make spelling of one area consistent with other formats
set AreaID = 'The Vale of Glamorgan'
where AreaID = 'Vale of Glamorgan'

-- update dimgeo with the area id
select distinct
	a.[LSOA Code]
	,a.[LSOA Name (English)]
	,a.LAcode
	,a.[BUA Population Proportion]
	,a.DeprivationScore
	,b.AreaID
into DimGeog1
from DimGeo a
left join AreaID b
	on a.AreaID = b.area

-- make lsoa code the primary key but make not null first
alter table DimGeog1
alter column [LSOA code] varchar(30) not null

alter table DimGeog1
add constraint pk_geog1 Primary key ([LSOA code])

---- Health board ID dim table

select
	[HealthboardID]
	,[healthboard] + ' ' + 'Local Health Board' as [Healthboard]
into dimHealthBoard1
from dimhealthboard

update [dimHealthboard1]
set Healthboard = 'Cwm Taf University Local Health Board'
where Healthboard = 'Cwm Taf Local Health Board'

update [dimHealthboard1]
set Healthboard = 'Aneurin Bevan University Local Health Board'
where Healthboard = 'Aneurin Bevan Local Health Board'

update [dimHealthboard1]
set Healthboard = 'Hywel Dda University Local Health Board'
where Healthboard = 'Hywel Dda Local Health Board'

update [dimHealthboard1]
set Healthboard = 'Cardiff and Vale University Local Health Board'
where Healthboard = 'Cardiff & Vale University Local Health Board'

alter table [dimHealthboard1]
add constraint pk_healthboard1 Primary key ([HealthboardID])

---- areaid dim table
select distinct
	[area]
	,identity(int) [AreaID]
into [AreaID]
from walesdatatab2

alter table AreaID
add constraint pk_areaid Primary key ([AreaID])

------crimetype dim table
select distinct
	[Crimetypealter]
	,identity(int) [CrimetypeID]
into [dimCrimetype]
from Walesdataclean1

alter table [dimCrimetype]
add constraint pk_crimetype1 Primary key ([crimetypeID])

-------Police type dim table
select distinct
	[Policedep]
	,identity(int) [PolicedepID]
into [DimPolicedep]
from Walesdataclean1

alter table DimPolicedep
add constraint pk_policetype Primary key ([PolicedepID])

-----------------------
--- Make Fact Table ---
-----------------------

select
	a.CrimeIDnew
	,a.[Year]
	,a.[Months]
	,a.[Longitude]
	,a.[Latitude]
	,b.PolicedepID
	,c.[LSOA Code]
	,d.CrimetypeID
	,e.AreaID
	,f.numofpatswaitbet28and56daysfromLPMtoTherapyIntervention
	,f.numofpatswaitedbet28and56daysfromreferaltoLMP
	,f.numofpatswaitedupto28daysfromreferaltoLMP
	,f.numofpatswaitupto28daysfromLPMtoTherapyIntervention
	,f.numofrefersforLMPreceivedduringmonth
	,f.numofpatswhowaitover56daysfromLPMtoTherapyIntervention
	,f.numofpatswhowaitedover56daysfromreferaltoLMP
	,f.healthboardID
	,g.[WIMD 2014 LSOA Rank]
	,i.[PopulationofLA]
	,i.[PopulationofHB]
	,j.[NumcurrtxforMI]
	,j.[MeanSF36score]
into Facttablev1
from [dbo].Walesdataclean1 a 
left join DimPolicedep b
on b.Policedep = a.Policedep
left join DimGeog1 c
on c.[LSOA Code] = a.[LSOA code]
left join dimCrimetype d
on d.[Crimetypealter] = a.[Crimetypealter]
left join AreaID e
on e.area = a.area
left join mhealthclean1 f
on f.F1 = a.[healthboardarea] and f.Months = a.[Months] and f.[Year] = a.[Year] 
left join ['Walesdeprivation1'] g
on g.[LSOA Code] = a.[LSOA code]
left join PopPiv1 i
on i.Area = a.area and i.Years = a.[Year]
left join walesdatatab2 j
on j.[Year] = a.[Year] and j.HB = a.healthboardarea and j.LA = a.area

--- Add foreign keys

alter table facttablev1
add constraint FK_police1 foreign key (PolicedepID) references dimpolicedep(PolicedepID)

alter table facttablev1
add constraint FK_crime1 foreign key (CrimetypeID) references dimcrimetype(CrimetypeID)

alter table facttablev1
add constraint FK_area foreign key (areaID) references [dbo].[AreaID](areaID)

alter table facttablev1
add constraint FK_healthboard1 foreign key (healthboardID) references dimhealthboard1(healthboardID)

alter table facttablev1
add constraint FK_geor1 foreign key ([LSOA code]) references dimgeog1([LSOA code])

alter table dimgeog1
add constraint FK_area2 foreign key ([AreaID]) references AreaID([AreaID])

---------------------------------------------------
--- Some further tables to assist with analysis ---
---------------------------------------------------

---------------- table with it aggregated to a month level - crimes combined
select
[Year]
	,[Months]
	,[healthboardid]
	,avg([numofpatswaitbet28and56daysfromLPMtoTherapyIntervention]) [28to56TI]
	,avg([numofpatswaitedbet28and56daysfromreferaltoLMP]) [28to56LMP]
	,avg([numofpatswaitedupto28daysfromreferaltoLMP]) [upto28LMP]
	,avg([numofpatswaitupto28daysfromLPMtoTherapyIntervention]) [upto28TI]
	,avg([numofrefersforLMPreceivedduringmonth]) [numofLMPrecpermon]
	,avg([numofpatswhowaitover56daysfromLPMtoTherapyIntervention]) [over56TI]
	,avg([numofpatswhowaitedover56daysfromreferaltoLMP]) [over56LMP]
	,count(crimetypeID) [numofcrimes]
into Aggregatedtomonthlevel
from Facttablev2
group by [Year],[Months],[HealthboardID]
order by [Year],[Months],[HealthboardID]

--- table v2 to analyse the mental health data
select
	[Year]
	,count([CrimeIDnew]) [numofcrimes]
	,[areaid]
	,avg([NumcurrtxforMI]) [numwithanyMI]
	,avg([MeanSF36score]) [meanMCscore]
	,avg(cast(populationofLA as numeric)) [populaiton]
	,count([CrimeIDnew])/avg(cast(populationofLA as numeric)) [crimeperpop]
into aggregatedtable2
from facttablev3
where [year] in ('2014','2015')
group by [Year],[areaID]

---------------------------------------------
----Edited version for the waiting times ----
/* The following code edits the months for the waiting time for between 28 and 56 days and
over 56 days - reason for this can be found in the report. So the figure for those waiting 
between 28 and 56 days is compared to the previous months crimes and those waiting over 56 
days is compared to two months ago crimes */

select
	*
	,[Months] as [Curmonth]
	,case 
		when [Months] = '01' then '12'
		else [Months] - 1 
	end as [Month-1]
	,case
		when [Months] = '01' then '11'
		when [Months] = '02' then '12'
		else [Months] - 2
	end as [Month-2]
	,[Year] as [CurYear]
	,case
		when [Months] = '01' then [Year] - 1
		else [Year]
	end as [Year-1]
	,case
		when [Months] in ('01','02') then [Year] - 1
		else [Year]
	end as [Year-2]
into Editedmonths
from Aggregatedtomonthlevel

select
	[Year]
	,[Months]
	,[numofcrimes]
	,[healthboardid]
	,[upto28LMP]
	,[upto28TI]
	,[numofLMPrecpermon]
into part1editedmonths
from Editedmonths

select
	a.*
	,b.[28to56LMP]
	,b.[28to56TI]
	,c.over56LMP
	,c.over56TI
into Editedmonthsfinal
from part1editedmonths a
left join Editedmonths b
on a.months = b.[Month-1] and a.[Year] = b.[Year-1] and a.[HealthboardID] = b.[HealthboardID]
left join Editedmonths c
on a.months = c.[Month-2] and a.[Year] = c.[Year-2] and a.[HealthboardID] = c.[HealthboardID]
order by a.[Year],a.[Months]

select *
from dimCrimetype