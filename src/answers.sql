-- Your answers here:
-- 1 select c.name as country_name, count(s.name) as number_of_states_by_country from countries c inner join states s on s.country_id = c.id group by c.id;

-- 2 select count(e.uuid) as total_of_employees_without_supervisor from employees e where e.supervisor_id is null;

-- 3 select c.name, o.address, count(e.id) as count from offices o inner join countries c on o.country_id  = c.id inner join employees e on o.id = e.office_id group by o.id, c.id order by count desc limit 5;

-- 4 select e.supervisor_id, count(e.supervisor_id) as count from employees e where e.supervisor_id is not null group by e.supervisor_id order by count desc limit 3;

-- 5 select count(s.name) as list_of_office from offices o inner join states s on o.state_id = s.id where s.name = 'Colorado';

-- 6 select o.name, count(e.office_id) from offices o inner join employees e on e.office_id = o.id group by o.id order by count desc;

-- 7 SELECT * FROM (select o.address, count(e.office_id) as count from offices o inner join employees e on e.office_id = o.id group by o.id order by count desc limit 1) AS max_office union all SELECT * FROM (select o.address, count(e.office_id) as count from offices o inner join employees e on e.office_id = o.id group by o.id order by count asc limit 1) AS min_office;

-- 8 select e.uuid, concat_ws(' ', e.first_name, e.last_name) as full_name, e.email, e.job_title, o.name as company, c.name as country, s.name as state, (select e.first_name from employees e2 where e2.id = e.supervisor_id) as boss_name from employees e inner join offices o on e.office_id = o.id inner join countries c on o.country_id = c.id inner join states s on o.state_id = s.id where e.supervisor_id is not null;

