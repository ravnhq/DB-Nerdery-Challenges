-- Your answers here:
-- 1
select
    countries.name ,
    count(states)
from states
         left join countries on states.country_id = countries.id
group by
    countries.name;

-- 2
select count(*) as employees_without_bosses
from employees
where supervisor_id IS NULL;

-- 3
select
    countries.name,
    offices.address,
    count(office_id)
from employees
         left join offices on employees.office_id = offices.id
         left join countries on offices.country_id = countries.id
group by
    offices.address,
    countries.name
order by
    count(office_id) desc
    limit 5;

-- 4
select
    supervisor_id,
    count(supervisor_id)
from employees
group by
    supervisor_id
order by
    count(supervisor_id) desc
    limit 3;

-- 5
select
    count(*) as list_of_office
from offices
         left join states on offices.state_id = states.id
where
    states.name = 'Colorado';

-- 6
select
    offices.name,
    count(office_id)
from employees
         left join offices on offices.id = employees.office_id
group by
    offices.name
order by
    count(office_id) desc;

-- 7

(select
     offices.address,
     count(office_id)
 from employees
          left join offices on offices.id = employees.office_id
 group by
     offices.address
 order by
     count(office_id) desc
     limit 1)

union

(select
     offices.address,
     count(office_id)
 from employees
          left join offices on offices.id = employees.office_id
 group by
     offices.address
 order by
     count(office_id) asc
     limit 1);

-- 8
select
    e.uuid,
    e.first_name || ' ' || e.last_name as full_name,
    e.email,
    e.job_title,
    offices.name as company,
    countries.name as country,
    states.name as state,
    supervisors.first_name
from employees as e
         left join offices on offices.id = e.office_id
         left join countries on offices.country_id = countries.id
         left join states on offices.state_id = states.id
         left join employees as supervisors on e.supervisor_id = supervisors.id
where
    e.supervisor_id is not null;