use CSR ;

exec sp_help 'CSR_Report_2025-07-26';

--% of null/0 entries to percentage of valid entries

with sub as(
select count(*) as NUll_Entries from [CSR_Report_2025-07-26] --nul/0l entries count
where Project_Amount_Spent_In_INR_Cr is null or Project_Amount_Spent_In_INR_Cr = 0),
tot as ( --total entriees count
select count(*) as TOT from [CSR_Report_2025-07-26] 
)--% of null/0 entries to percentage of valid entries
select t.TOT , s.NUll_Entries , t.TOT  - s.NUll_Entries as Valid_Entries ,
CAST(s.NUll_Entries AS FLOAT) * 100.0 / NULLIF(t.TOT, 0) AS Percent_of_Null from tot t , sub as s;
--nullif(exp1,exp2) returns null if exp1=exp2, else returns exp1

--list of companies with 0/null entries
select Company_Name , Project_Amount_Spent_In_INR_Cr from [CSR_Report_2025-07-26] 
where  Project_Amount_Spent_In_INR_Cr = 0 or Project_Amount_Spent_In_INR_Cr is null ;

--grouping based on all factors and sum it
with dup as (
select Company_Name , Financial_Year, PSU_NPSU, CSR_State,CSR_Development_Sector,
CSR_Sub_Development_Sector, format (Project_Amount_Spent_In_INR_Cr , 'N2') as expense ,
ROW_NUMBER() over(partition by Company_Name , Financial_Year, PSU_NPSU, CSR_State,CSR_Development_Sector,
CSR_Sub_Development_Sector order by Project_Amount_Spent_In_INR_Cr ) as rk  from [CSR_Report_2025-07-26])
select d.Company_Name, d.Financial_Year, d.PSU_NPSU, d.CSR_State, d.CSR_Development_Sector, d.CSR_Sub_Development_Sector ,
sum(cast(d.expense as float)) as sums  from dup d 
group by d.Company_Name, d.Financial_Year, d.PSU_NPSU, d.CSR_State, d.CSR_Development_Sector, d.CSR_Sub_Development_Sector  ;

--no of companies
select distinct Company_Name, count(distinct Company_Name) from [CSR_Report_2025-07-26] group by  Company_Name

--no of companies with 0 or null csr
select  count(distinct Company_Name) from [CSR_Report_2025-07-26]
where Project_Amount_Spent_In_INR_Cr is null or Project_Amount_Spent_In_INR_Cr = 0 ;

--removing spaces and turning everything into lower to avoid case sensitivity

with rename as (
select Company_Name as C_name , TRIM(upper(Company_Name)) as CR_name from [CSR_Report_2025-07-26] )
update c set c.Company_Name = rename.CR_name from [CSR_Report_2025-07-26] c
join rename on c.Company_Name = rename.C_name ;

--in same way you can delete the fy prefix if needed
select trim(SUBSTRING(Financial_Year, 3, len(Financial_Year))) from [CSR_Report_2025-07-26]

--instead you can use stuff(nothing but substring + replace)
select stuff(Financial_Year,1,3,'') from [CSR_Report_2025-07-26];



--analysis

--pivoting the table by expenditure
select * from (select Company_Name , Financial_Year, Project_Amount_Spent_In_INR_Cr from [CSR_Report_2025-07-26]) as cs
pivot( sum(cs.Project_Amount_Spent_In_INR_Cr) FOR Financial_Year IN (
        [FY 2014-15], [FY 2015-16], [FY 2016-17], [FY 2017-18], [FY 2018-19],
        [FY 2019-20], [FY 2020-21], [FY 2021-22], [FY 2022-23], [FY 2023-24]
    )
) AS pvt;

--company with highest expenditure

select Company_Name , sum(Project_Amount_Spent_In_INR_Cr) as Contribution from [CSR_Report_2025-07-26] 
group by Company_Name order by Contribution desc ;

--sub development sector with highest fund

select CSR_Sub_Development_Sector , sum(Project_Amount_Spent_In_INR_Cr) as Contribution from [CSR_Report_2025-07-26] 
group by CSR_Sub_Development_Sector order by Contribution desc 

--development sector with highest fund

select CSR_Development_Sector , sum(Project_Amount_Spent_In_INR_Cr) as Contribution from [CSR_Report_2025-07-26] 
group by CSR_Development_Sector order by Contribution desc 

--expenditure by subsectors in sectors with ranks

with sub as (
select CSR_Sub_Development_Sector, sum(Project_Amount_Spent_In_INR_Cr) as funds from [CSR_Report_2025-07-26] 
group by CSR_Sub_Development_Sector ) , fin as (
select  distinct s.CSR_Sub_Development_Sector , c.CSR_Development_Sector , s.funds from sub as s
join [CSR_Report_2025-07-26] c on c.CSR_Sub_Development_Sector = s.CSR_Sub_Development_Sector 
) select *,  row_number() over(partition by fin.CSR_Development_Sector order by fin.funds desc) as ranks from fin  ; 

--statewise funding
select CSR_State, sum(Project_Amount_Spent_In_INR_Cr) as funding from [CSR_Report_2025-07-26] group by CSR_State order by funding desc;

--yearwise funding
select Financial_Year, sum(Project_Amount_Spent_In_INR_Cr) as funding from [CSR_Report_2025-07-26] 
group by Financial_Year ;

--diff between each years funds

with years as (
select Financial_Year, sum(Project_Amount_Spent_In_INR_Cr) as funding from [CSR_Report_2025-07-26] 
group by Financial_Year ), prev as ( select y.Financial_Year, y.funding, 
lag(y.funding) over(order by y.Financial_Year) as prev_Yr_fund from years as y) 
select *,  p.funding - p.prev_Yr_fund  as diff from prev p

--just a testing unrelated to the project
SELECT DIFFERENCE('dog', 'ice') AS diff;--said to check phonetic similarity but didnt work

--number of sub sectors in each sector

select CSR_Development_Sector, count(distinct CSR_Sub_Development_Sector) as NO_of_Sub_Sectors from [CSR_Report_2025-07-26]
group by CSR_Development_Sector ;

--sum of funds after classifying into subsector(for verification)

with sub as (
select CSR_Sub_Development_Sector, sum(Project_Amount_Spent_In_INR_Cr) as funds from [CSR_Report_2025-07-26] 
group by CSR_Sub_Development_Sector )select sum(funds) from sub ;

--actual sum of funds
select sum(Project_Amount_Spent_In_INR_Cr) from [CSR_Report_2025-07-26]

--contribution of psu/npsu

select PSU_NPSU , sum(Project_Amount_Spent_In_INR_Cr) as funds from [CSR_Report_2025-07-26] group by PSU_NPSU order by funds;

--top 3 companies in each state

with comp_exp as (
select  Company_Name , sum(Project_Amount_Spent_In_INR_Cr) as Contribution from [CSR_Report_2025-07-26] 
group by Company_Name ), stat as (
select e.Company_Name , c.CSR_State , e.Contribution , 
dense_rank() over(partition  by c.CSR_State order by e.Contribution desc) as ranks from comp_exp as e
join [CSR_Report_2025-07-26] as c on c.Company_Name = e.Company_Name )
select distinct Company_Name, CSR_State, Contribution, ranks from stat where ranks < 4 order by CSR_State, ranks;

--yearwise trend in dev sector contribution
  select  Financial_Year,
    CSR_Development_Sector,
    SUM(Project_Amount_Spent_In_INR_Cr) AS Total_Amount_Spent,
    RANK() OVER (
        PARTITION BY Financial_Year
        ORDER BY SUM(Project_Amount_Spent_In_INR_Cr) DESC
    ) AS Rank_In_Year
FROM 
    [CSR_Report_2025-07-26]
GROUP BY 
    Financial_Year,
    CSR_Development_Sector
ORDER BY 
    Financial_Year,
    Rank_In_Year;

--private vs public

select case
when Company_Name like '%private%' then 'PRIVATE'
else 'PUBLIC'
end as Types , sum(Project_Amount_Spent_In_INR_Cr) as Contribution
from [CSR_Report_2025-07-26] group by  case
when Company_Name like '%private%' then 'PRIVATE'
else 'PUBLIC'
end order by Contribution desc;


select avg(Project_Amount_Spent_In_INR_Cr) from [CSR_Report_2025-07-26]

