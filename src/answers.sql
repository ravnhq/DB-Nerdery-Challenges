-- Your answers here:
-- 1
SELECT 
    c.name, 
    COUNT(*) 
FROM states s 
JOIN countries c ON c.id = s.country_id  
GROUP BY s.country_id, c.name;
-- 2
SELECT 
    COUNT(*) AS employees_without_bosses 
FROM employees 
WHERE supervisor_id IS NULL;
-- 3
SELECT 
    c.name, 
    o.address, 
    COUNT(*) from offices o 
JOIN employees e ON o.id = e.office_id 
JOIN countries c ON o.country_id = c.id 
GROUP BY o.id, c.name
ORDER BY COUNT(*) DESC 
LIMIT 5;
-- 4
SELECT 
    supervisor_id, 
    COUNT(*) 
FROM employees 
WHERE supervisor_id IS NOT NULL 
GROUP BY supervisor_id 
ORDER BY COUNT(*) DESC 
LIMIT 3;
-- 5
SELECT 
    COUNT(*) AS list_of_office 
FROM offices 
WHERE state_id = (
    SELECT id 
    FROM states 
    WHERE name ILIKE 'colorado'
);
-- 6
SELECT 
    o.name, 
    COUNT(*) AS count 
FROM offices o 
JOIN employees e ON o.id = e.office_id 
GROUP BY o.name 
ORDER BY COUNT(*) DESC;
-- 7
WITH EmployeeCount AS (
    SELECT address, COUNT(*) AS count
    FROM offices o 
    JOIN employees e ON o.id = e.office_id 
    GROUP BY address
)
(SELECT * FROM EmployeeCount ORDER BY count DESC LIMIT 1)
UNION
(SELECT * FROM EmployeeCount ORDER BY count ASC LIMIT 1);
-- 8
SELECT 
    e.uuid, e.first_name || ' ' || e.last_name AS full_name, 
    e.email, 
    e.job_title, 
    o.name AS company, 
    c.name AS country, 
    s.name AS state, 
    sup.first_name AS boss_name
FROM employees e
JOIN offices o ON o.id = e.office_id
JOIN countries c ON c.id = o.country_id
JOIN states s ON s.id = o.state_id
RIGHT JOIN employees sup ON e.supervisor_id = sup.id;

