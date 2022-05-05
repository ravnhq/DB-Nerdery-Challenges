-- Your answers here:
-- 1
SELECT c.name, COUNT(*) as count FROM countries c
    INNER JOIN  states s
    ON c.id = s.country_id 
    GROUP BY c.name;

-- 2
SELECT COUNT(*) as employees_without_bosses FROM  employees 
    WHERE supervisor_id IS NULL;

-- 3
SELECT c.name, o.address, COUNT(*) as count FROM offices o 
    INNER JOIN employees e ON o.id = e.office_id 
    INNER JOIN countries c ON o.country_id = c.id 
    GROUP BY c.name, o.address 
    ORDER BY count desc 
    LIMIT 5;
-- 4
SELECT e.supervisor_id,count(*) as count FROM employees e 
    WHERE supervisor_id IS NOT NULL 
    GROUP BY e.supervisor_id 
    ORDER BY count desc 
    LIMIT 3;

-- 5
SELECT COUNT(*) as list_of_office FROM offices o 
    INNER JOIN states s 
    ON s.id= o.state_id 
    WHERE s.name LIKE 'Colorado';

-- 6
SELECT o.name,COUNT(*) as count FROM offices o
    LEFT JOIN employees e
    ON o.id=e.office_id 
    GROUP BY o.name 
    ORDER BY count desc;

-- 7
(SELECT o.address, count (*) as count FROM offices o 
    INNER JOIN employees e 
    ON o.id = e.office_id 
    GROUP BY o.address 
    ORDER BY count desc 
    LIMIT 1)
UNION
(SELECT o.address, count (*) as count FROM offices o 
    INNER JOIN employees e 
    ON o.id = e.office_id 
    GROUP BY o.address 
    ORDER BY count asc 
    LIMIT 1);

WITH quantify_employees_per_office AS (
    SELECT o.address, count (*) as count FROM offices o 
    INNER JOIN employees e 
    ON o.id = e.office_id 
    GROUP BY o.address )
(SELECT * FROM quantify_employees_per_office
    ORDER BY count asc
    LIMIT 1)
    UNION 
(SELECT * FROM quantify_employees_per_office
    ORDER BY count desc
    LIMIT 1);

-- 8
SELECT  e.uuid,
        CONCAT(e.first_name, ' ', e.last_name),
        e.email as full_name, 
        e.job_title, 
        o.name as company, 
        c.name as country , 
        s.name as state , 
        boss.first_name AS boss_name  
    FROM employees e 
    INNER JOIN offices o 
        ON e.office_id = o.id 
    INNER JOIN countries c 
        ON o.country_id = c.id 
    INNER JOIN states s 
        ON s.id = o.state_id 
    INNER JOIN employees as boss 
        ON e.id = boss.id;


