-- Your answers here:
-- 1
SELECT c.name,
	COUNT(s.name)
FROM states s
	INNER JOIN countries c ON s.country_id = c.id
GROUP BY c.name 

-- 2
SELECT COUNT(*) FILTER(
		WHERE supervisor_id IS NULL
	) as employess_without_bosses
FROM employees 

-- 3
SELECT c.name,
	o.address,
	COUNT(e.office_id)
FROM employees e
	INNER JOIN offices o ON e.office_id = o.id
	INNER JOIN countries c ON o.country_id = c.id
GROUP BY e.office_id,
	c.name,
	o.address
ORDER BY e.count DESC,
	c.name DESC
LIMIT 5 

-- 4
SELECT supervisor_id,
	COUNT(supervisor_id)
FROM employees
GROUP BY supervisor_id
ORDER BY COUNT(supervisor_id) DESC
LIMIT 3 

-- 5
SELECT COUNT(*) as list_of_office
FROM offices
WHERE state_id = (
	SELECT id
	FROM states
	WHERE name = 'Colorado'
)

-- 6
SELECT o.name,
	COUNT(e.office_id)
FROM employees e
	INNER JOIN offices o ON e.office_id = o.id
GROUP BY o.name
ORDER BY COUNT(e.office_id) DESC 

-- 7
WITH OfficesRankedByEmployees AS (
	SELECT o.address,
		COUNT(e.office_id)
	FROM employees e
		INNER JOIN offices o ON e.office_id = o.id
	GROUP BY o.address
) (
	SELECT *
	FROM OfficesRankedByEmployees
	ORDER BY count DESC
	LIMIT 1
)
UNION
(
	SELECT *
	FROM OfficesRankedByEmployees
	ORDER BY count ASC
	LIMIT 1
) 

-- 8
SELECT e.uuid,
	e.first_name || ' ' || e.last_name as fullname,
	e.email,
	e.job_title,
	o.name as company,
	c.name as country,
	s.name as state,
	ee.first_name as boss_name
FROM employees e
	INNER JOIN offices o ON o.id = e.office_id
	INNER JOIN states s ON s.id = o.state_id
	INNER JOIN countries c ON c.id = s.country_id
	INNER JOIN employees ee ON e.supervisor_id = ee.id
