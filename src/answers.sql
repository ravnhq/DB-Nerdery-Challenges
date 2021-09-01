-- Your answers here:
-- 1
SELECT countries.name, COUNT(states.id)
FROM countries
INNER JOIN states ON countries.id = states.country_id
GROUP BY countries.name;
-- 2
SELECT COUNT(employees.id) AS employees_without_bosses
FROM employees
WHERE employees.supervisor_id IS NULL;
-- 3
SELECT c.name,
  employee_in_office.address, employee_in_office.count
FROM (
    SELECT o.country_id AS country_id,
        o.address AS address, COUNT(e.id) AS count
    FROM offices AS o
    INNER JOIN employees AS e ON e.office_id = o.id
    GROUP BY o.id
    ) AS employee_in_office
INNER JOIN countries AS c ON employee_in_office.country_id = c.id
ORDER BY employee_in_office.count DESC
LIMIT 5;
-- 4
SELECT s.supervisor_id, COUNT(e.id) as num_emp
FROM employees AS e
INNER JOIN employees AS s ON e.id = s.supervisor_id
GROUP BY s.supervisor_id
ORDER BY num_emp DESC
LIMIT 3;
-- 5
SELECT COUNT(offices.id)
FROM offices
INNER JOIN states ON offices.state_id = states.id
INNER JOIN countries ON offices.country_id = countries.id
WHERE countries.name = 'United States' AND states.name = 'Colorado';
-- 6
SELECT offices.name, COUNT(employees.id) AS count
FROM offices
INNER JOIN states ON offices.state_id = states.id
INNER JOIN employees ON offices.id = employees.office_id
GROUP BY offices.name
ORDER BY count DESC;
-- 7
WITH OfficeEmployee AS (
  SELECT offices.name AS name, COUNT(employees.id) AS count_emp
  FROM offices
  INNER JOIN states ON offices.state_id = states.id
  INNER JOIN employees ON offices.id = employees.office_id
  GROUP BY offices.id
)

(SELECT name, count_emp
FROM OfficeEmployee
ORDER BY count_emp
LIMIT 1)
UNION
(SELECT name, count_emp
FROM OfficeEmployee
ORDER BY count_emp DESC
LIMIT 1)
;
-- 8
SELECT e.uuid, CONCAT(e.first_name,' ', e.last_name) AS full_name,
  e.email, e.job_title, o.name AS company, c.name AS country, s.name as state,
  b.first_name AS boss_name
FROM employees AS e
INNER JOIN offices AS o ON e.office_id = o.id
INNER JOIN countries AS c ON o.country_id = c.id
INNER JOIN states AS s ON o.state_id = s.id
INNER JOIN employees AS b ON e.supervisor_id = b.id;
