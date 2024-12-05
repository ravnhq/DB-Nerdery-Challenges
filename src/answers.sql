-- Your answers here:
-- 1
SELECT c.name,
    COUNT(c.name)
FROM countries c
    INNER JOIN states s ON c.id = s.country_id
GROUP BY c.name;
--2
SELECT COUNT(*) employees_without_bosses
FROM employees
WHERE supervisor_id IS NULL;
-- 3
SELECT c.name,
    o.address,
    COUNT(e.id) as count
FROM employees e
    INNER JOIN offices o ON e.office_id = o.id
    INNER JOIN countries c ON c.id = o.country_id
GROUP BY c.name,
    o.address
ORDER BY count DESC,
    c.name
LIMIT 5;
-- 4
SELECT e.supervisor_id,
    COUNT(e.id) as count
FROM employees e
WHERE e.supervisor_id IS NOT NULL
GROUP BY e.supervisor_id
ORDER BY count DESC
LIMIT 3;
-- 5
SELECT COUNT(*) offices_in_colorado
FROM offices o
    INNER JOIN states s ON o.state_id = s.id
WHERE s.name = 'Colorado';
-- 6
SELECT o.name,
    COUNT(o.name) as count
FROM offices o
    INNER JOIN employees e ON e.office_id = o.id
GROUP BY o.name
ORDER BY count DESC;
-- 7
WITH counts AS (
    SELECT o.address, COUNT(o.id) AS count
    FROM offices o
        INNER JOIN employees e ON e.office_id = o.id
    GROUP BY o.address
	ORDER BY count
) 
(
    SELECT * FROM counts
	ORDER BY count DESC
	LIMIT 1 
)
UNION ALL
(
	SELECT * FROM counts
	LIMIT 1 
);
--8
SELECT e.uuid,
    e.first_name || ' ' || e.last_name as full_name,
    e.email,
    e.job_title,
    o.name as company,
    c.name country,
    s.name as state,
    es.first_name as boss_name
FROM employees e
    INNER JOIN offices o ON e.office_id = o.id
    INNER JOIN countries c ON c.id = o.country_id
    INNER JOIN employees es ON e.supervisor_id = es.id
    INNER JOIN states s ON s.id = o.state_id