use hr_db;

-- total employee (active and inactive)
select sum(Employee_Count) as total_employee 
from hr_data;

-- total active employee
select sum(Employee_Count) as total_active_employee 
from hr_data
where CF_current_Employee = '1';

-- total attrition 
select sum(case when Attrition = 'Yes' then 1 else 0 end) total_attrition 
from hr_data;

-- attrition rate 
select round(sum(case when Attrition = 'Yes' then 1 else 0 end)*1.0/count(attrition),2) as attrition_rate 
from hr_data;

-- total active employee and total attrition by job role 
with active_cte as (select job_role, sum(employee_count) as total_active from hr_data
where CF_current_Employee = '1'
group by job_role),
attrition_cte as (select job_role, sum(case when attrition = 'Yes' then 1 else 0 end) as total_attrition
from hr_data	
group by job_role)

select a.job_role, a.total_active, b.total_attrition 
from active_cte as a
inner join attrition_cte as b 
on a.job_role = b.job_role
order by a.total_active desc, b.total_attrition desc;

-- total active employee by age band 
with active_cte as (select CF_age_band, sum(employee_count) as total_active_employee 
from hr_data
where CF_current_Employee = '1'
group by CF_age_band),
attrition_cte as (select CF_age_band, sum(case when attrition = 'Yes' then 1 else 0 end) as total_attrition 
from hr_data	
group by CF_age_band)

select a.cf_age_band, a.total_active_employee, b.total_attrition from active_cte as a
inner join attrition_cte as b 
on a.CF_age_band = b.CF_age_band
order by total_active_employee desc, total_attrition desc;

-- avarage monthly income by job role 
select Job_Role, avg(monthly_income) as avarage_monthly_income 
from hr_data
group by Job_Role
order by avarage_monthly_income desc;

-- total attrition by education 
select Education, sum(case when attrition='Yes' then 1 else 0 end) as total_attrition  
from hr_data 
group by Education
order by total_attrition desc;

-- total attrition by department 
with cte as(select Department, sum(case when attrition='Yes' then 1 else 0 end) as total_attrition from hr_data
group by Department)
select Department, concat(cast(total_attrition * 1.0 /(select sum(total_attrition) from cte) * 100 as decimal (5,2)), '%') as percentage_attrition 
from cte;

--total active employee by job satisfaction and job role in pivot table
with cte as (select Job_Role, Job_Satisfaction, sum(employee_count) as total_active_employee
from hr_data
where CF_current_Employee = '1'
group by job_role, Job_Satisfaction)
select job_role, 
	sum(case when job_satisfaction = 1 then total_active_employee end) as '1', 
	sum(case when job_satisfaction = 2 then total_active_employee end) as '2',
	sum(case when job_satisfaction = 3 then total_active_employee end) as '3',
	sum(case when job_satisfaction = 4 then total_active_employee end) as '4',
	sum(total_active_employee) as Total_Row
from cte
group by job_role
union all
select 'Total', sum(case when job_satisfaction = 1 then total_active_employee end) as '1', 
	sum(case when job_satisfaction = 2 then total_active_employee end) as '2',
	sum(case when job_satisfaction = 3 then total_active_employee end) as '3',
	sum(case when job_satisfaction = 4 then total_active_employee end) as '4',
	sum(total_active_employee) as total_row
from cte;