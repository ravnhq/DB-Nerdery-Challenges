-- Your answers here:
-- 1
-- Count the total number of states in each country.
SELECT cou.name name, count(sta.id) count
FROM countries cou
RIGHT JOIN states sta ON cou.id = sta.country_id
GROUP BY cou.name;

-- 2
-- How many employees do not have supervisores.
SELECT count(emp.id) employees_without_bosses
FROM employees emp
WHERE emp.supervisor_id IS NULL;

-- 3
-- List the top five offices address with the most amount of employees,
-- order the result by country and display a column with a counter.
SELECT cou.name name, ofi.address address, count(emp.id) count
FROM offices ofi
RIGHT JOIN employees emp ON ofi.id = emp.office_id
RIGHT JOIN countries cou ON ofi.country_id = cou.id
GROUP BY ofi.address, cou.name
ORDER BY count DESC
LIMIT 5;

-- 4
-- Three supervisors with the most amount of employees they are in charge.
SELECT sup.id supervisor_id, count(emp.id) count
FROM employees sup
RIGHT JOIN employees emp ON sup.id = emp.supervisor_id
WHERE emp.supervisor_id IS NOT NULL
GROUP BY sup.id
ORDER BY count DESC
LIMIT 3;

-- 5
-- How many offices are in the state of Colorado (United States).
SELECT count(ofi.id) list_of_office
FROM offices ofi
RIGHT JOIN states sta ON ofi.state_id = sta.id
RIGHT JOIN countries cou ON sta.country_id = cou.id
WHERE cou.id = 1 AND sta.name = 'Colorado' AND sta.abbr = 'CO';

-- 6
-- The name of the office with its number of employees
-- ordered in a desc.
select ofi.name, count(emp.id) count
from offices ofi
RIGHT JOIN employees emp ON ofi.id = emp.office_id
GROUP BY ofi.name
ORDER BY count DESC;

-- 7
-- The office with more and less employees.
(SELECT ofi.address, count(emp.office_id) count
FROM employees emp
LEFT JOIN offices ofi on ofi.id = emp.office_id
GROUP BY ofi.address
ORDER BY count DESC
LIMIT 1)
UNION ALL
(SELECT ofi.address, count(emp.office_id) count
FROM employees emp
LEFT JOIN offices ofi on ofi.id = emp.office_id
GROUP BY ofi.address
ORDER BY count
LIMIT 1);

-- 8
-- Show the uuid of the employee, first_name and lastname
-- combined, email, job_title, the name of the office they belong to,
-- the name of the country, the name of the state and the name of
-- the boss (boss_name)
SELECT emp.uuid uuid, emp.first_name || ' ' || emp.last_name full_name, emp.email email, emp.job_title job_title,
       ofi.name company, cou.name country, sta.name state,
       COALESCE(bos.first_name, 'Not Available') boss_name
FROM employees emp
RIGHT JOIN offices ofi ON emp.office_id = ofi.id
RIGHT JOIN countries cou ON cou.id = ofi.country_id
RIGHT JOIN states sta ON sta.id = ofi.state_id
INNER JOIN employees bos ON emp.supervisor_id = bos.id;