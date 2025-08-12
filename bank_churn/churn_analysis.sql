-- analisis loyalitas customer suatu bank 
-- 

use student_db;

select * from customer_churn;

-- total active member
select count(CustomerId) as total_customer from customer_churn;

-- point earned
select avg(Point_Earned) as avarage_pointearned from customer_churn;

-- avarage creditscore
select avg(CreditScore) as avarage_CreditScore from customer_churn;

-- avarage balance
select round(avg(Balance),2) as avarage_balance from customer_churn

-- avarage tenure 
select avg(tenure) as avarage_tenure from customer_churn

-- avarage sallary
select round(avg(EstimatedSalary),2) as avarage_estimatedSalary from customer_churn


-- exited based satisfaction score 
select exited, avg(Satisfaction_Score) as avg_satisfaction_score from customer_churn
group by exited;


-- exited by total active number
select Exited, sum(IsActiveMember) as total_active_member from customer_churn
group by Exited

-- total customer where not active member and exit
select count(CustomerId) as total_inactive_exited from customer_churn
where Exited = '1' and IsActiveMember='0'


-- total complain and not complain by exited and not member customer
select sum(complain) as total_complain from customer_churn
where Exited = '1' and IsActiveMember='0'

-- total customer and total complain who exit and active member
select count(CustomerId) as total_customer, sum(complain) as total_complain from customer_churn
where Exited = '1' and IsActiveMember='1'