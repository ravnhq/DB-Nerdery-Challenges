-- Your answers here:
-- 1 Count the total number of states in each country.
SELECT
  c.name,
  count(s.*)
FROM
  states s
  INNER JOIN countries c ON c.id = s.country_id
GROUP BY
  c.name;

-- 2 How many employees do not have supervisores.
SELECT
  count(s.*) as employees_without_bosses
FROM
  employees s
WHERE
  supervisor_id is NULL;

-- 3 List the top five offices address with the most amount of employees, order the result by country and display a column with a counter.
SELECT
  c.name,
  o.address,
  count(e.*) as employees
FROM
  offices o
  INNER JOIN employees e ON e.office_id = o.id
  INNER JOIN countries c ON c.id = o.country_id
GROUP BY
  c.name,
  o.address
ORDER BY
  count DESC
LIMIT
  5;

-- 4 Three supervisors with the most amount of employees they are in charge.
SELECT
  e.supervisor_id,
  COUNT(e.*) AS count_number
FROM
  employees e
WHERE
  e.supervisor_id IS NOT NULL
GROUP BY
  e.supervisor_id
ORDER BY
  count_number DESC
LIMIT
  3;

-- 5 How many offices are in the state of Colorado (United States).
SELECT
  COUNT(o.*) AS list_of_office
FROM
  offices o
WHERE
  state_id = (
    SELECT
      s.id
    FROM
      states s
    WHERE
      s.name = 'Colorado'
  );

-- 6 The name of the office with its number of employees ordered in a desc.
SELECT
  o.name,
  COUNT(e.*) AS count
FROM
  employees e
  INNER JOIN public.offices o ON o.id = e.office_id
GROUP BY
  o.name
ORDER BY
  count DESC;

-- 7 The office with the most and the least number of employees
WITH employees_count AS (
  -- this is a subquery that will count the number of employees in each office
  SELECT
    o.address,
    COUNT(e.*) AS count
  FROM
    employees e
    INNER JOIN offices o ON o.id = e.office_id
  GROUP BY
    o.address
),
-- this is a subquery that will get the office with the most employees based on the last subquery
office_max AS (
  SELECT
    ec.address,
    ec.count
  FROM
    employees_count ec
  ORDER BY
    ec.count DESC
  LIMIT
    1
), -- this is a subquery that will get the office with the least employees based on the last subquery
office_min AS (
  SELECT
    ec.address,
    ec.count
  FROM
    employees_count ec
  ORDER BY
    ec.count
  LIMIT
    1
)
SELECT
  *
FROM
  office_max
UNION
SELECT
  *
FROM
  office_min;

-- 8 Show the uuid of the employee, first_name and lastname combined, email, job_title, the name of the office they belong to,
-- the name of the country, the name of the state and the name of the boss (boss_name)
SELECT
  e.uuid,
  e.first_name || ' ' || e.last_name AS full_name,
  e.email,
  e.job_title,
  o.name AS company,
  c.name AS country,
  s.name AS state,
  e2.first_name AS boss_name
FROM
  employees e
  INNER JOIN offices o ON o.id = e.office_id
  INNER JOIN countries c ON c.id = o.country_id
  INNER JOIN states s ON s.id = o.state_id
  INNER JOIN employees e2 ON e2.id = e.supervisor_id;
