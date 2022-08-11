-- Your answers here:
-- 1

SELECT 
    c.name as country, 
    COUNT(*) as number_of_states
FROM states s
INNER JOIN countries c
    ON s.country_id = c.id
GROUP BY s.country_id, c.id
ORDER BY c.name DESC;

-- 2

SELECT COUNT(*) as employees_without_supervisor
FROM employees
WHERE supervisor_id IS NULL;

-- 3

WITH top_offices AS
(
    SELECT 
        c.name as country,
        o.address,
        COUNT(*) as number_of_employees
    FROM employees e
    INNER JOIN offices o
        ON e.office_id = o.id
    INNER JOIN countries c
        ON o.country_id = c.id
    GROUP BY e.office_id, o.id, c.id
    ORDER BY COUNT(*) DESC
    LIMIT 5
)

SELECT *
FROM top_offices
ORDER BY country;

-- 4

SELECT 
    supervisor_id,
    COUNT(*) AS employees_in_charge
FROM employees
WHERE supervisor_id IS NOT NULL
GROUP BY supervisor_id
ORDER BY COUNT(*) DESC
LIMIT 3;

-- 5

WITH colorado AS 
(
    SELECT id
    FROM states
    WHERE 
        name = 'Colorado' 
        and country_id = 
            (
                SELECT id
                FROM countries
                WHERE name = 'United States'
            )
)

SELECT COUNT(*) as offices_in_colorado
FROM offices, colorado
WHERE state_id = colorado.id;

-- 6

SELECT 
    o.name AS office,
    COUNT(*) AS number_of_employees
FROM employees e
INNER JOIN offices o
    ON e.office_id = o.id
GROUP BY e.office_id, o.id
ORDER BY COUNT(*) DESC, o.name;

-- 7

CREATE OR REPLACE FUNCTION FORMAT(string VARCHAR)
RETURNS VARCHAR[]
LANGUAGE sql AS
$func$ 
    SELECT
        STRING_TO_ARRAY(
            TRANSLATE(string, '(")', ''),
            ','
        );
$func$;

WITH 
address_employees AS 
(
    SELECT 
        o.address,
        COUNT(*) AS number_of_employees
    FROM employees e
    INNER JOIN offices o
        ON e.office_id = o.id
    GROUP BY e.office_id, o.id
    ORDER BY COUNT(*) DESC, o.name
),

adresss_count AS (
    SELECT 
        FORMAT( (FIRST_VALUE(a.*) OVER ())::VARCHAR ) as more_employees,
        FORMAT( (LAST_VALUE(a.*) OVER ())::VARCHAR ) as less_employees
    FROM address_employees a
    LIMIT 1
)

(
    SELECT
        a.more_employees[1] AS address,
        a.more_employees[2] AS number_of_employees    
    FROM adresss_count a
)
UNION ALL
(
    SELECT
        a.less_employees[1] AS address,
        a.less_employees[2] AS number_of_employees 
    FROM adresss_count a
);

--8

SELECT 
    e.uuid,
    e.first_name || ' ' || e.last_name AS full_name,
    e.email,
    e.job_title,
    o.name AS company,
    c.name AS country,
    s.name AS state,
    (
        SELECT first_name
        FROM employees
        WHERE id = e.supervisor_id
    ) AS boss_name
FROM employees e
INNER JOIN offices o
    ON e.office_id = o.id
INNER JOIN states s
    ON o.state_id = s.id
INNER JOIN countries c
    ON s.country_id = c.id
ORDER BY boss_name;
