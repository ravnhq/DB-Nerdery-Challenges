-- Your answers here:
-- 1

SELECT 
  C.name, 
  COUNT(*) 
FROM 
  countries C 
INNER JOIN 
  states S 
ON 
  C.id = S.country_id 
GROUP BY 
  C.name;

-- 2

SELECT 
  COUNT(*) AS employees_without_bosses 
FROM 
  employees 
WHERE 
  supervisor_id IS NULL;

-- 3

SELECT 
  C.name,
  O.address, 
  COUNT(*)
FROM 
	offices O 
INNER JOIN 
	employees E 
ON 
	O.id = E.office_id 
INNER JOIN 
	countries C 
ON 
	O.country_id = C.id 
GROUP BY 
	O.address,
	C.name
ORDER BY
	COUNT(*) DESC
LIMIT 5;

-- 4

SELECT
	supervisor_id,
	COUNT(*)
FROM
	employees
WHERE
	supervisor_id IS NOT NULL
GROUP BY 
  supervisor_id
ORDER BY 
  COUNT(*) DESC
LIMIT 3;

-- 5

SELECT
	COUNT(*) as list_of_office
FROM
	offices
WHERE
	state_id IN (SELECT id FROM states WHERE name = 'Colorado');

-- 6

SELECT
	O.name,
	COUNT(*)
FROM
	officeS O
INNER JOIN
	employees E
ON
	O.id = E.office_id
GROUP BY
	O.name
ORDER BY
	COUNT(*) DESC

-- 7

(SELECT
	O.address,
	COUNT(*)
FROM
	offices O
INNER JOIN
	employees E
ON
	O.id = E.office_id
GROUP BY
	O.address
ORDER BY
	COUNT(*) DESC
LIMIT 1)

UNION

(SELECT
	O.address,
	COUNT(*)
FROM
	offices O
INNER JOIN
	employees E
ON
	O.id = E.office_id
GROUP BY
	O.address
ORDER BY
	COUNT(*) ASC
LIMIT 1)

-- 8

SELECT
	E.uuid,
	CONCAT(E.first_name, ' ', E.last_name) AS full_name,
	E.email,
	E.job_title,
	O.name AS company,
	C.name AS country,
	S.name AS state,
	B.first_name AS boss_name
FROM
	employees E
INNER JOIN
	offices O
ON
	E.office_id = O.id
INNER JOIN
	countries C
ON
	O.country_id = C.id
INNER JOIN
	states S
ON
	O.state_id = S.id
INNER JOIN
	employees B
ON
	E.supervisor_id = B.id
