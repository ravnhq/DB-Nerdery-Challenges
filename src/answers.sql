-- Your answers here:
-- 1
SELECT c.name, COUNT(s.*) 
FROM countries c LEFT JOIN states s ON c.id = s.country_id 
GROUP BY c.name;
-- 2
SELECT COUNT(*) as employees_without_bosses 
FROM employees 
WHERE supervisor_id IS NULL;
-- 3
SELECT c.name, d.address, d.total_employees 
FROM countries c INNER JOIN (
    SELECT o.id , o.country_id , o.address, count(e.id) AS total_employees 
    FROM offices o LEFT JOIN employees e ON e.office_id = o.id 
    GROUP BY o.id, o.address, o.country_id
) AS d ON c.id = d.country_id 
ORDER BY d.total_employees DESC, d.id DESC 
LIMIT 5;
-- 4
SELECT supervisor_id, count(*) AS total_subordinates 
FROM employees 
WHERE supervisor_id IS NOT NULL 
GROUP BY supervisor_id 
ORDER BY count(*) DESC
LIMIT 3;
-- 5
SELECT COUNT(*) AS list_of_office
FROM offices INNER JOIN states 
ON states.id = offices.state_id
WHERE states.name = 'Colorado';
-- 6
SELECT name, count(e.*) AS total_employees
FROM offices INNER JOIN employees e 
ON offices.id = e.office_id 
GROUP BY name 
ORDER BY total_employees DESC;
-- 7
(SELECT address , count(*) AS total_employees 
 FROM offices INNER JOIN employees
 ON employees.office_id = offices.id 
 GROUP BY address 
 ORDER BY total_employees DESC 
 LIMIT 1)
 UNION
(SELECT address , count(*) AS total_employees 
 FROM offices INNER JOIN employees
 ON employees.office_id = offices.id 
 GROUP BY address
 ORDER BY total_employees ASC 
 LIMIT 1);
-- 8
SELECT 
    e.uuid, CONCAT(e.first_name , ' ' , e.last_name) as full_name, e.email, e.job_title,
    o.name AS company, 
    c.name AS country_name, 
    s.name AS state_name,
    ss.first_name AS supervisor
FROM employees e
INNER JOIN employees ss ON e.supervisor_id = ss.id
LEFT JOIN offices o ON e.office_id = o.id
LEFT JOIN states s ON o.state_id = s.id
LEFT JOIN countries c ON s.country_id = c.id;