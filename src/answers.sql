-- Your answers here:
-- 1
SELECT c.name, count(s.name)
FROM states AS s
         INNER JOIN countries AS c
                    ON s.country_id = c.id
group by c.name
-- 2
SELECT COUNT(*) AS employees_without_supervisors
FROM employees
WHERE supervisor_id IS NULL;
-- 3
SELECT c.name,
       o.address,
       COUNT(e.id) AS count
FROM offices AS o
LEFT JOIN employees AS e ON o.id = e.office_id
INNER JOIN countries AS c ON o.country_id = c.id
group by c.name, o.address
ORDER BY count DESC, c.name
LIMIT 5;
-- 4
SELECT supervisor_id, COUNT(*) AS count
FROM employees
WHERE supervisor_id IS NOT NULL
group by supervisor_id
ORDER BY count DESC
LIMIT 3
-- 5
SELECT count(*) AS list_of_office
FROM offices AS o
         INNER JOIN states AS s
                    ON o.state_id = s.id
WHERE s.name = 'Colorado'
  AND s.country_id = (SELECT id FROM countries AS c WHERE name = 'United States');
-- 6
SELECT o.name, COUNT(*) AS count
FROM offices AS o
         INNER JOIN employees AS e
                    ON o.id = e.office_id
GROUP BY o.name
ORDER BY count DESC;
-- 7
WITH office_count AS (
    SELECT o.address, COUNT(*) AS count
    FROM offices AS o
    INNER JOIN employees AS e ON o.id = e.office_id
    GROUP BY o.address
)

(SELECT *
 FROM office_count
 WHERE count = (SELECT MAX(count) FROM office_count)
 LIMIT 1)

UNION

(SELECT *
 FROM office_count
 WHERE count = (SELECT MIN(count) FROM office_count)
 LIMIT 1);
 -- 8
WITH offices_by_countries_with_states AS (
SELECT o.id AS office_id,
       o.name AS office_name,
       c.name AS country_name,
       s.name AS state_name
FROM offices AS o
    INNER JOIN countries AS c ON o.country_id = c.id
    LEFT JOIN states AS s ON o.state_id = s.id
)

SELECT e.uuid,
       e.first_name || ' ' || e.last_name AS full_name,
       e.email,
       e.job_title,
       o.office_name                             AS company,
       o.country_name                     AS country,
       o.state_name AS state,
       e2.first_name                      AS boss_name
FROM employees AS e
         INNER JOIN offices_by_countries_with_states AS o ON e.office_id = o.office_id
         LEFT JOIN employees AS e2 ON e.supervisor_id = e2.id
WHERE e2.first_name IS NOT NULL;