-- Your answers here:
-- 1

select c.name, count(*) 
from countries c inner join states s 
on c.id = s.country_id 
group by c.name;

-- 2

select count(*) as employees_without_bosses
from employees
where supervisor_id is null;

-- 3

select co.name, off.address, count(*)
from countries co inner join offices off
on co.id = off.country_id
inner join employees emp
on off.id = emp.office_id
group by off.address, co.name
order by count desc
limit 5;

-- 4

select supervisor_id, count(*)
from employees 
where supervisor_id is not null 
group by supervisor_id 
order by count desc 
limit 3;

-- 5

select count(*) as list_of_office 
from offices 
where state_id = (select id from states where name = 'Colorado');

-- 6

select off.name, count(*)
from offices off inner join employees emp 
on off.id = emp.office_id 
group by off.name 
order by count desc;

-- 7

with employeesPerOffice as(select off.address, count(*) 
from offices off inner join employees emp
on off.id = emp.office_id 
group by off.address)

(select * from employeesPerOffice order by count desc limit 1) union ( select * from employeesPerOffice order by count limit 1);


