-- Your answers here:
-- 1
SELECT 
    c.name, COUNT(s.name) as "count" 
FROM states s
INNER JOIN countries c ON s.country_id = c.id
GROUP BY c.name;
-- 2
SELECT COUNT(*) 
	employees_without_bosses 
FROM employees 
WHERE supervisor_id IS NULL;
-- 3
SELECT 
    c.name, 
    o.address,
	COUNT(e.uuid) AS "count"
FROM employees e
INNER JOIN offices o ON e.office_id = o.id
INNER JOIN countries c ON o.country_id = c.id
GROUP BY c.name, o.address
ORDER BY "count" DESC
LIMIT 5;
-- 4
SELECT e.supervisor_id, COUNT(*) AS total_employees
FROM employees e
WHERE e.supervisor_id IS NOT NULL
GROUP BY e.supervisor_id
ORDER BY total_employees DESC
LIMIT 3;
-- 5
SELECT 
	COUNT(*) AS list_of_office
FROM offices o
WHERE o.country_id = 1 AND o.state_id = 8;
-- 6
SELECT 
	o.name AS "name",
	COUNT(e.office_id) AS "count"
FROM employees e
INNER JOIN offices o ON e.office_id = o.id
GROUP BY o.name
ORDER BY "count" DESC;
-- 7
WITH cte AS (
  SELECT 
    o.name AS "name",
    COUNT(e.office_id) AS "count",
    ROW_NUMBER() OVER (ORDER BY COUNT(e.office_id) DESC) AS rn_desc,
    ROW_NUMBER() OVER (ORDER BY COUNT(e.office_id) ASC) AS rn_asc
  FROM employees e
  INNER JOIN offices o ON e.office_id = o.id
  GROUP BY o.name
);
SELECT "name", "count"
FROM cte
WHERE rn_asc = 1 OR rn_desc = 1;
-- 8
SELECT 
    e.uuid,
    CONCAT(e.first_name, ' ', e.last_name) AS full_name,
    e.email,
    e.job_title,
    o.name AS office_name,
    co.name AS country_name,
    s.name AS state_name,
    supervisors.first_name boss_name 
FROM employees e
INNER JOIN offices o ON e.office_id = o.id
INNER JOIN states s ON o.state_id = s.id
INNER JOIN countries co ON s.country_id = co.id;
INNER JOIN employees supervisors ON e.supervisor_id = supervisors.id
WHERE supervisors.first_name IS NOT NULL;
