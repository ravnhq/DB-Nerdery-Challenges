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

SELECT e1.id as supervisor_id, count(e2.id)
FROM employees e1
INNER JOIN employees e2
ON e1.id = e2.supervisor_id
GROUP BY e1.id
ORDER BY count(e2.id) DESC
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
SELECT  e1.uuid,
        CONCAT(e1.first_name,' ',e1.last_name) as full_name,
        e1.email,
        e1.job_title,
        o.name as company,
        c.name as country,
        s.name as state,
        e2.first_name as boss_name
FROM employees e1
INNER JOIN employees e2
ON e1.supervisor_id = e2.id
INNER JOIN offices o
ON e1.office_id = o.id
INNER JOIN countries c
ON o.country_id = c.id
INNER JOIN states s
ON o.state_id = s.id;