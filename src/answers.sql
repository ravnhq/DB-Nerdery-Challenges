-- Your answers here:
-- 1
SELECT
    c.name,
    count(s.name)
FROM
    countries c
    INNER JOIN states s ON c.id = s.country_id
GROUP BY
    c.name;

-- 2
SELECT
    count(*) AS employees_without_bosses
FROM
    employees
WHERE
    supervisor_id IS NULL;

-- 3
SELECT
    c.name,
    o.address,
    count(e.id)
FROM
    offices o
    INNER JOIN employees e ON o.id = e.office_id
    INNER JOIN countries c ON o.country_id = c.id
GROUP BY
    o.address,
    c.name
ORDER BY
    count DESC
LIMIT
    5;

-- 4
SELECT
    supervisor_id,
    count(supervisor_id)
FROM
    employees
GROUP BY
    supervisor_id
ORDER BY
    count DESC
LIMIT
    3;

-- 5
SELECT
    count(*) AS list_of_office
FROM
    states s
    INNER JOIN offices o ON s.id = o.state_id
    INNER JOIN countries c ON o.country_id = c.id
WHERE
    s.name = 'Colorado'
    AND c.name = 'United States';

-- 6
SELECT
    o.name,
    count(o.id)
FROM
    offices o
    INNER JOIN employees e ON o.id = e.office_id
GROUP BY
    o.id
ORDER BY
    count DESC;

-- 7
(
    SELECT
        o.address,
        count(o.id)
    FROM
        offices o
        INNER JOIN employees e ON o.id = e.office_id
    GROUP BY
        o.id
    ORDER BY
        count
    LIMIT
        1
)
UNION
ALL (
    SELECT
        o.address,
        count(o.id)
    FROM
        offices o
        INNER JOIN employees e ON o.id = e.office_id
    GROUP BY
        o.id
    ORDER BY
        count DESC
    LIMIT
        1
)
ORDER BY
    count DESC;

-- 8
SELECT
    employee.uuid,
    CONCAT(employee.first_name, ' ', employee.last_name) AS full_name,
    employee.email,
    employee.job_title,
    o.name AS company,
    c.name AS country,
    s.name AS state,
    boss.first_name AS boss_name
FROM
    employees employee
    INNER JOIN offices o ON employee.office_id = o.id
    INNER JOIN countries c ON o.country_id = c.id
    INNER JOIN states s ON o.state_id = s.id
    INNER JOIN employees boss ON employee.supervisor_id = boss.id;