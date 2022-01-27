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

select co.name, off.address, count(*) as count
from countries co inner join offices off
on co.id = off.country_id
inner join employees emp
on off.id = emp.office_id
group by co.name,off.address
order by count desc, co.name desc
limit 5;

-- 4

select supervisor_id, count(*) as count 
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

-- 7

