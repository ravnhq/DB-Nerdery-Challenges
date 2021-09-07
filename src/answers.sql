-- Your answers here:
-- 1

SELECT c.name, count(s.name)
  FROM countries c
INNER JOIN states s
  ON s.country_id = c.id
GROUP BY c.name;

-- 2

SELECT count(*) as employees_without_bosses
  FROM employees e
WHERE e.supervisor_id IS NULL;

-- 3

SELECT c.name, o.address, COUNT(e.id)
  FROM countries c
INNER JOIN offices o
  ON o.country_id = c.id
INNER JOIN employees e
  ON e.office_id = o.id
GROUP BY c.name, o.address
ORDER BY COUNT(e.id) DESC
LIMIT 5;

-- 4

SELECT supervisor_id, count(supervisor_id)
  FROM employees
WHERE supervisor_id IS NOT NULL
GROUP BY supervisor_id
ORDER BY count DESC
LIMIT 3;

-- 5

SELECT count(o.*) as list_of_office
  FROM offices o
INNER JOIN states s
  ON o.state_id = s.id
INNER JOIN countries c
  ON s.country_id = c.id
WHERE s.name = 'Colorado'
  AND c.name = 'United States';

-- 6

SELECT o.name, COUNT(e.id)
FROM offices o
INNER JOIN employees e
ON e.office_id = o.id
GROUP BY o.name
ORDER BY COUNT(e.id) DESC;

-- 7
(
  SELECT o.address, COUNT(e.id)
    FROM offices o
  INNER JOIN employees e
    ON e.office_id = o.id
  GROUP BY o.address
  ORDER BY COUNT(e.id) ASC 
  LIMIT 1
) 
UNION
(
  SELECT o.address, COUNT(e.id)
    FROM offices o
  INNER JOIN employees e
    ON e.office_id = o.id
  GROUP BY o.address
  ORDER BY COUNT(e.id) DESC 
  LIMIT 1
)
ORDER BY count;

-- 8
SELECT  employee.uuid,
        CONCAT(employee.first_name,' ',employee.last_name) as full_name,
        employee.email,
        employee.job_title,
        o.name as company,
        c.name as country,
        s.name as state,
        boss.first_name as boss_name
FROM employees employee
  INNER JOIN employees boss
    ON employee.supervisor_id = boss.id
  INNER JOIN offices o
    ON employee.office_id = o.id
  INNER JOIN countries c
    ON o.country_id = c.id
  INNER JOIN states s
    ON o.state_id = s.id;