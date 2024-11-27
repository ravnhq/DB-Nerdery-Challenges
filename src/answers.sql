-- Your answers here:
-- 1
SELECT 
    c.name AS country_name, 
    COUNT(s.id) AS total_states
FROM 
    states s
JOIN 
    countries c
ON 
    s.country_id = c.id
GROUP BY 
    c.name;

-- 2
SELECT COUNT(*) AS employees_wothout_bosses
FROM employees
WHERE supervisor_id IS NULL;

-- 3
    SELECT 
    c.name AS country_name, 
    o.address AS address, 
    COUNT(e.id) AS numer_employees
FROM 
    offices o
JOIN 
    employees e ON o.id = e.office_id
JOIN 
    countries c ON o.country_id = c.id	
GROUP BY 
    c.name, o.address
ORDER BY 
    numer_employees DESC, c.name ASC
LIMIT 5;

-- 4
SELECT 
    s.id AS supervisor_id,
    COUNT(e.id) AS number_of_employe
FROM 
    employees e
JOIN 
    employees s ON e.supervisor_id = s.id
GROUP BY 
    s.id
ORDER BY 
    number_of_employe DESC
LIMIT 3;


-- 5
SELECT 
    s.name AS state_name, 
    COUNT(o.id) AS colorado_offices
FROM 
    offices o
JOIN 
    states s ON o.state_id = s.id
GROUP BY 
    s.name
HAVING 
    s.name = 'Colorado';

-- 6
SELECT 
    o.name AS office_name,
    COUNT(e.id) AS number_of_employees
FROM 
    offices o
JOIN 
    employees e ON o.id = e.office_id
GROUP BY 
    o.name
ORDER BY 
    number_of_employees DESC;

-- 7
(
    SELECT o.address AS office_address, COUNT(*) AS employee_count
    FROM employees e
    JOIN offices o ON e.office_id = o.id
    GROUP BY o.id, o.address
    ORDER BY employee_count DESC
    LIMIT 1
)
UNION ALL
(
    SELECT o.address AS office_address, COUNT(*) AS employee_count
    FROM employees e
    JOIN offices o ON e.office_id = o.id
    GROUP BY o.id, o.address
    ORDER BY employee_count ASC
    LIMIT 1
);

-- 8

SELECT
    e.uuid AS employee_uuid,
    CONCAT(e.first_name, ' ', e.last_name) AS full_name,
    e.email,
    e.job_title,
    o.name AS company,
    s.name AS state_name,
    c.name AS country_name,
    CONCAT(b.first_name, ' ', b.last_name) AS boss_name
FROM
    employees e
INNER JOIN
    offices o ON e.office_id = o.id
INNER JOIN
    states s ON o.state_id = s.id
INNER JOIN
    countries c ON s.country_id = c.id
INNER  JOIN
    employees b ON e.supervisor_id = b.id
ORDER BY
    e.id; 
