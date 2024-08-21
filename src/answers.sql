-- Your answers here:
-- 1 
select
c.name,
COUNT(s.country_id)  
FROM states s
INNER JOIN countries c 
ON s.country_id = c.id
group  by s.country_id , c.name;

-- 2
select count(id) 
from employees 
where supervisor_id is null;


-- 3

select  c.id , 
c.name ,
o.address,
count(e.office_id) as offices_employee
from employees e 
inner join offices o
on e.office_id  = o.id
inner join countries c 
on c.id  = o.country_id 
group by c.id , 
c.name, 
o.address
order by offices_employee desc 
limit 5;


-- 4

select  supervisor_id, count(id) as employess_count
from employees 
where supervisor_id  
is not null group by supervisor_id 
order by employess_count desc
limit  3

-- 5

select  count(id) as list_office 
from offices o  
where state_id  = 8 

-- 6

select o.name, count(e.id) as employee_counter from offices o 
inner join employees e
on o.id  = e.office_id
group by o.name 
order by employee_counter desc;

-- 7

WITH RankedEmployeeCounts AS (
    SELECT  
        c.id, 
        c.name,
        o.address,
        COUNT(e.office_id) AS offices_employee,
        ROW_NUMBER() OVER (ORDER BY COUNT(e.office_id) DESC) AS rn_max,
        ROW_NUMBER() OVER (ORDER BY COUNT(e.office_id) ASC) AS rn_min
    FROM 
        employees e
    INNER JOIN 
        offices o ON e.office_id = o.id
    INNER JOIN 
        countries c ON c.id = o.country_id 
    GROUP BY 
        c.id, 
        c.name, 
        o.address
)
SELECT 
    c.id, 
    c.address,
    offices_employee
FROM 
    RankedEmployeeCounts c
WHERE 
    rn_max = 1
    OR rn_min = 1 order by offices_employee desc ;


-- 8

SELECT 
    e.uuid,
    CONCAT(e.first_name, ' ', e.last_name) AS full_name,
    e.email,
    e.job_title,
    o.name AS office_name,
    c.name AS country_name,
    s.name AS state_name,
    bm.first_name || ' ' || bm.last_name AS boss_name
FROM 
    employees e
INNER JOIN 
    offices o ON e.office_id = o.id
INNER JOIN 
    countries c ON o.country_id = c.id
INNER JOIN 
    states s ON o.state_id = s.id
LEFT JOIN 
    employees bm ON e.uuid = bm.uuid;    

