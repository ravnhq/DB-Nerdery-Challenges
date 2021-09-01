-- Your answers here:
-- 1
SELECT
    c.name,
    COUNT(*) AS number_of_states
FROM
    countries c
    INNER JOIN states s ON c.id = s.country_id
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
    c.name,
    o.address,
    COUNT(e.id) AS number_of_employees
FROM
    countries c
    INNER JOIN offices o ON c.id = o.country_id
    INNER JOIN employees e ON o.id = e.office_id
GROUP BY
    c.name,
    o.address
ORDER BY
    COUNT(e.id) DESC
LIMIT
    5;

-- 4
SELECT
    supervisor_id,
    COUNT(supervisor_id) AS employees_in_charge
FROM
    employees
GROUP BY
    supervisor_id
ORDER BY
    COUNT(supervisor_id) DESC
LIMIT
    3;

-- 5
SELECT
    count(o.id) AS offices_in_colorado
FROM
    offices o
    INNER JOIN states e ON o.state_id = e.id
WHERE
    e.name = 'Colorado';

-- 6
SELECT
    o.name,
    count(e.id) AS number_of_employees
FROM
    offices o
    INNER JOIN employees e ON o.id = e.office_id
GROUP BY
    o.name
ORDER BY
    count(e.id) DESC;
    
-- 7

