-- Your answers here:
-- 1

SELECT c.name, count(s.*)
    FROM countries c 
INNER JOIN states s 
    ON c.id=s.country_id GROUP BY c.name;

-- 2

SELECT COUNT(*) AS employees_without_bosses 
    FROM employees 
WHERE supervisor_id IS NULL;

-- 3

SELECT c.name, o.address, count(e.*) 
    FROM offices o 
INNER JOIN countries c 
    ON o.country_id=c.id 
INNER JOIN employees e 
    ON o.id=e.office_id 
GROUP BY o.address,c.name
ORDER BY count DESC LIMIT 5;

-- 4

SELECT supervisor_id, count(*) 
    FROM employees 
WHERE supervisor_id IS NOT NULL 
GROUP BY supervisor_id 
ORDER BY count DESC LIMIT 3;

-- 5

SELECT count(*) as list_of_office 
    FROM offices o 
INNER JOIN states s 
    ON o.state_id=s.id WHERE s.name='Colorado' 
GROUP BY s.id;

-- 6

SELECT o.name, count(*) 
    FROM offices o 
INNER JOIN employees e 
    ON o.id=e.office_id 
GROUP BY o.name
ORDER BY count DESC;

-- 7
(SELECT o.address, count(*) 
    FROM offices o 
INNER JOIN employees e 
    ON o.id=e.office_id 
GROUP BY o.address
ORDER BY count DESC LIMIT 1)
    UNION
(SELECT o.address, count(*) 
    FROM offices o 
INNER JOIN employees e 
    ON o.id=e.office_id 
GROUP BY o.address
ORDER BY count ASC LIMIT 1)

-- 8
SELECT e.uuid, CONCAT(e.first_name,' ', e.last_name) as full_name, e.email, 
e.job_title, o.name AS office, c.name AS country, s.name AS state, su.first_name as boss_name
FROM employees e
INNER JOIN employees su ON (e.supervisor_id=su.id)
INNER JOIN offices o ON (e.office_id=o.id) 
INNER JOIN countries c ON (o.country_id=c.id) 
INNER JOIN states s ON (o.state_id=s.id);
