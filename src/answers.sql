-- Your answers here:
-- 1
SELECT
    c.name,
    count(s.name)
FROM
    countries c
    RIGHT JOIN states s ON c.id = s.country_id
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
    t.address,
    t.count
FROM
    (
        SELECT
            o.country_id,
            address,
            count(o.id)
        FROM
            offices o
            INNER JOIN employees e ON o.id = e.office_id
        GROUP BY
            o.id
    ) t
    INNER JOIN countries c ON t.country_id = c.id
ORDER BY
    t.count DESC,
    c.name;

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
WHERE
    s.name = 'Colorado';

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
SELECT
    *
FROM
    (
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
    ) t;

-- 8
SELECT
    e.uuid,
    CONCAT(e.first_name, ' ', e.last_name) AS full_name,
    e.email,
    e.job_title,
    o.name AS company,
    c.name AS country,
    s.name AS state,
    e2.first_name AS boss_name
FROM
    employees e
    INNER JOIN offices o ON e.office_id = o.id
    INNER JOIN countries c ON o.country_id = c.id
    INNER JOIN states s ON o.state_id = s.id
    INNER JOIN employees e2 ON e.supervisor_id = e2.id;