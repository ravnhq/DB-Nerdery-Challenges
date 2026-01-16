-- Your answers here:
-- 1
SELECT countries.name, COUNT(country_id) 
FROM countries 
LEFT JOIN states 
on countries.id = states.country_id 
GROUP BY countries.name;

-- 2
SELECT COUNT(id) AS employees_without_bosses 
FROM employees 
WHERE supervisor_id IS NULL;

-- 3
SELECT countries.name, offices.address, COUNT(office_id)  AS count FROM offices 
LEFT JOIN employees ON offices.id = employees.office_id 
LEFT JOIN countries ON offices.country_id = countries.id 
GROUP BY countries.name,offices.address 
ORDER BY count DESC LIMIT 5;

-- 4
SELECT DISTINCT supervisor_id, COUNT(supervisor_id) AS count 
FROM employees 
WHERE supervisor_id IS NOT NULL 
GROUP BY supervisor_id
ORDER BY count DESC LIMIT 3; 

-- 5
SELECT COUNT(offices.id) AS list_of_office FROM offices 
LEFT JOIN states ON offices.state_id = states.id 
WHERE states.name = 'Colorado';

-- 6
SELECT offices.name, COUNT(office_id)  AS count FROM offices 
LEFT JOIN employees ON offices.id = employees.office_id 
GROUP BY offices.name 
ORDER BY count DESC;

-- 7
WITH GroupedCount AS (
    SELECT 
        o.address as Address,
        COUNT(e.id) AS employee_count
    FROM offices o
    LEFT JOIN employees e ON o.id = e.office_id
    GROUP BY o.address
    HAVING COUNT(e.id) > 0
)
(SELECT Address, employee_count FROM GroupedCount ORDER BY employee_count DESC LIMIT 1)
UNION ALL
(SELECT Address, employee_count FROM GroupedCount ORDER BY employee_count ASC LIMIT 1)
ORDER BY employee_count DESC;

-- 8
SELECT e.uuid, CONCAT(e.first_name,' ',e.last_name) as full_name,
e.email,
e.job_title, 
offices.name AS office_name,
countries.name as country_name, 
states.name as state_name, 
es.first_name as supervisor_name FROM employees e 
LEFT JOIN offices ON e.office_id = offices.id 
LEFT JOIN employees es ON e.supervisor_id = es.id 
LEFT JOIN countries ON offices.country_id = countries.id 
RIGHT JOIN states ON states.country_id = countries.id;   