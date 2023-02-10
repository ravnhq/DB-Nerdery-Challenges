-- Your answers here:

-- ====================================================================================================================

-- 1. Count the total number of states in each country.
SELECT c.name, COUNT(s.*)
FROM states s
         INNER JOIN countries c ON s.country_id = c.id
GROUP BY c.name;

-- ====================================================================================================================

-- 2. How many employees do not have supervisors.

-- NOTE: This reads better, with a minimal difference in performance.
-- EXPLAIN ANALYZE
SELECT COUNT(e.*) FILTER (WHERE e.supervisor_id IS NULL) AS employees_without_bosses
FROM employees e;

-- NOTE: Slightly faster (at times an by a few tens of milliseconds)
-- EXPLAIN ANALYZE
SELECT COUNT(e.*) AS employees_without_bosses
FROM employees e
WHERE e.supervisor_id IS NULL;

-- ====================================================================================================================

-- 3. List the top five offices address with the most amount of employees, order the result by country and display a
-- column with a counter.

-- NOTE: This query doesn't produce the same results as expected, but it respects the requirement of also sorting by
-- country, faster than the other two
-- EXPLAIN ANALYZE
WITH employees_count AS (SELECT e.office_id, COUNT(e.*) AS count
                         FROM employees e
                         GROUP BY e.office_id) -- we could sort and limit here, but we also want to sort by country
SELECT c.name, o.address, ec.count
FROM employees_count ec
         INNER JOIN offices o ON o.id = ec.office_id
         INNER JOIN countries c ON o.country_id = c.id
ORDER BY ec.count DESC, c.name
LIMIT 5;

-- NOTE: Using windows, it's a bit slower than the other two, produces the same results as the query above
-- EXPLAIN ANALYZE
SELECT DISTINCT c.name, o.address, COUNT(e.*) OVER (PARTITION BY o.id) AS count
FROM offices o
         INNER JOIN countries c ON c.id = o.country_id
         INNER JOIN employees e ON o.id = e.office_id
ORDER BY count DESC, c.name
LIMIT 5;

-- NOTE: Produces the exact same result as in the README, but it doesn't respect the requirement of sorting by country.
-- EXPLAIN ANALYZE
SELECT c.name, o.address, COUNT(e.*) AS count
FROM offices o
         INNER JOIN employees e ON o.id = e.office_id
         INNER JOIN countries c ON o.country_id = c.id
GROUP BY o.address, c.name
ORDER BY count DESC
LIMIT 5;

-- ====================================================================================================================

-- 4. The top three supervisors with the most amount of employees they have in charge.
SELECT e.supervisor_id, COUNT(e.*) AS count
FROM employees e
WHERE e.supervisor_id IS NOT NULL
GROUP BY e.supervisor_id
ORDER BY count DESC
LIMIT 3;

-- ====================================================================================================================

-- 5. How many offices are in the state of Colorado (United States)?

-- NOTE: These two queries are executed the same way by the query planner, the query with 'WHERE' seems to be more
-- readable though

-- EXPLAIN ANALYZE
SELECT *
FROM offices o
         INNER JOIN countries c ON o.country_id = c.id
         INNER JOIN states s ON o.state_id = s.id
WHERE c.iso_name = 'USA'
  AND s.abbr = 'CO';

-- EXPLAIN ANALYZE
SELECT *
FROM offices o
         INNER JOIN countries c ON o.country_id = c.id AND c.iso_name = 'USA'
         INNER JOIN states s ON o.state_id = s.id AND s.abbr = 'CO';

-- ====================================================================================================================

-- 6. The name of the office with its number of employees ordered in a desc.
SELECT o.name, COUNT(e.*) AS count
FROM offices o
         INNER JOIN employees e ON o.id = e.office_id
GROUP BY o.name
ORDER BY count DESC;

-- ====================================================================================================================

-- 7. The office with more and less employees.
-- EXPLAIN ANALYZE
WITH employees_count AS (SELECT o.address, COUNT(e.*) AS count
                         FROM employees e
                                  INNER JOIN offices o ON o.id = e.office_id
                         GROUP BY o.address),
     office_max AS (SELECT ec.address, ec.count
                    FROM employees_count ec
                    ORDER BY ec.count DESC
                    LIMIT 1),
     office_min AS (SELECT ec.address, ec.count
                    FROM employees_count ec
                    ORDER BY ec.count
                    LIMIT 1)
SELECT *
FROM office_max
UNION
SELECT *
FROM office_min;

-- ====================================================================================================================

-- 8. Show the uuid of the employee, first_name and lastname combined, email, job_title, the name of the office they
-- belong to, the name of the country, the name of the state and the name of their boss (boss_name).

-- EXPLAIN ANALYZE
SELECT e.uuid,
       CONCAT(e.first_name, ' ', e.last_name) AS full_name,
       e.email,
       e.job_title,
       o.name                                 AS company,
       c.name                                 AS country,
       s.name                                 AS state,
       b.first_name                           AS boss_name
FROM employees e
         INNER JOIN offices o ON o.id = e.office_id
         INNER JOIN countries c ON c.id = o.country_id
         INNER JOIN states s ON s.id = o.state_id
         INNER JOIN employees b ON b.id = e.supervisor_id;