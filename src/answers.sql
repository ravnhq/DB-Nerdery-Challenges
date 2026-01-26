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
SELECT c.name , o.address, COUNT(e.id) as count_employees 
FROM employees e 
LEFT JOIN offices o ON e.office_id = o.id
LEFT JOIN countries c ON o.country_id = c.id
GROUP BY c.name, o.id
ORDER BY count_employees DESC, c.name 
LIMIT 5;
-- 4
SELECT a.supervisor_id, CONCAT(b.first_name, ' ', b.last_name) as full_name, count(*) AS total_subordinates 
FROM employees a
LEFT JOIN employees b ON a.supervisor_id = b.id
WHERE a.supervisor_id IS NOT NULL 
GROUP BY a.supervisor_id, b.id
ORDER BY count(*) DESC
LIMIT 3;
-- 5
SELECT COUNT(*) AS offices_count
FROM offices o
LEFT JOIN states s ON s.id = o.state_id
LEFT JOIN countries c ON c.id = s.country_id
WHERE s.name = 'Colorado' and c.name = 'United States';
-- 6
SELECT name, count(e.*) AS total_employees
FROM offices 
LEFT JOIN employees e ON offices.id = e.office_id 
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
    e.uuid, CONCAT(e.first_name, ' ', e.last_name) as full_name, e.email, e.job_title,
    o.name AS company, 
    c.name AS country_name, 
    s.name AS state_name,
    ss.first_name AS supervisor
FROM employees e
LEFT JOIN employees ss ON e.supervisor_id = ss.id
LEFT JOIN offices o ON e.office_id = o.id
LEFT JOIN states s ON o.state_id = s.id
LEFT JOIN countries c ON s.country_id = c.id;