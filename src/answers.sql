-- Your answers here:
-- 1
SELECT 
  c.name, COUNT(*)
FROM 
  states s
INNER JOIN
  countries c
ON
  s.country_id = c.id
GROUP BY
  c.name;
-- 2
SELECT 
  COUNT(*) AS employees_without_bosses
FROM 
  employees
WHERE 
  supervisor_id IS NULL; 
-- 3
SELECT 
  c.name, o.address, COUNT(*) AS count
FROM 
  employees e
INNER JOIN 
  offices o
ON 
  e.office_id = o.id
INNER JOIN 
  countries c
ON 
  o.country_id = c.id
GROUP BY
  c.name, o.address
ORDER BY
  count DESC
LIMIT 5;
-- 4
SELECT
  supervisor_id, COUNT(*) AS count
FROM
  employees
WHERE
  supervisor_id IS NOT NULL
GROUP BY
  supervisor_id
ORDER BY
  count DESC
LIMIT 3;
-- 5
SELECT 
  COUNT(*) as list_of_office
FROM
  offices o
INNER JOIN
  states s
ON
  o.state_id = s.id
INNER JOIN
  countries c
ON 
  s.country_id = c.id
WHERE
  s.name = 'Colorado' AND c.name = 'United States';
-- 6
SELECT
  o.name, COUNT(*) AS count
FROM
  employees e
INNER JOIN
  offices o
ON
  e.office_id = o.id
GROUP BY
  o.name
ORDER BY
  count DESC;
-- 7
(
  SELECT 
    o.address, COUNT(e.id) AS count
  FROM 
    offices o
  INNER JOIN 
    employees e
  ON 
    e.office_id = o.id
  GROUP BY 
    o.address
  ORDER BY 
    count
  LIMIT 1
)
UNION
(
  SELECT 
    o.address, COUNT(e.id) AS count
  FROM 
    offices o
  INNER JOIN 
    employees e
  ON 
    e.office_id = o.id
  GROUP BY 
    o.address
  ORDER BY 
    count DESC
  LIMIT 1
) ORDER BY 2;
-- 8
SELECT
  e.uuid, CONCAT(e.first_name, ' ', e.last_name) AS full_name, e.email, e.job_title, o.name AS company, c.name AS country, s.name AS state, m.first_name AS boss_name
FROM
  employees e
INNER JOIN
  offices o
ON
  e.office_id = o.id
INNER JOIN
  countries c
ON
  o.country_id = c.id
INNER JOIN
  states s
ON 
  o.state_id = s.id
INNER JOIN
  employees m
ON
  e.supervisor_id = m.id;
