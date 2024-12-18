-- Your answers here:

----- UTIL FUNCTIONS
CREATE OR REPLACE FUNCTION get_state_id_by_name(_state_name TEXT)
    RETURNS INT
    LANGUAGE plpgsql
AS $$
DECLARE
    _state_id INT;
BEGIN
    SELECT
        s.id
    INTO _state_id
    FROM states AS s
    WHERE s.name = _state_name;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'State not found [name=%]', _state_name;
    END IF;

    RETURN _state_id;
END;
$$;
----- UTIL FUNCTIONS

-- 1
SELECT
    c.name AS name,
    COUNT(s.id) AS count
FROM countries AS c
    INNER JOIN states AS s
        ON c.id = s.country_id
GROUP BY c.id;

-- 2
SELECT COUNT(*)
FROM employees AS e
WHERE e.supervisor_id IS NULL;

-- 3
SELECT
    c.name AS name,
    o.address AS address,
    COUNT(*) AS empleyees_count
FROM employees AS e
    INNER JOIN offices AS o
        ON o.id = e.office_id
    INNER JOIN countries AS c
        ON c.id = o.country_id
GROUP BY c.name, o.address
ORDER BY empleyees_count DESC, c.name DESC
LIMIT 5;

-- 4
SELECT
    e.supervisor_id AS supervisor_id,
    count(e.id) AS count
FROM employees AS e
WHERE e.supervisor_id IS NOT NULL
GROUP BY e.supervisor_id
ORDER BY count DESC
LIMIT 3;

-- 5
CREATE OR REPLACE FUNCTION get_offices_count_by_state_name(_state_name TEXT)
    RETURNS INT
    LANGUAGE plpgsql
AS $$
DECLARE
    _state_id INT;
BEGIN
    _state_id := get_state_id_by_name(_state_name);

    RETURN (
        SELECT COUNT(*)
        FROM offices AS o
        WHERE o.state_id = _state_id
    );
END;
$$;

SELECT get_offices_count_by_state_name('Colorado') AS list_of_office;

-- 6
SELECT
    o.name AS name,
    COUNT(e.id) AS employees_count
FROM offices AS o
    INNER JOIN employees AS e
        ON o.id = e.office_id
GROUP BY o.name
ORDER BY employees_count DESC;

-- 7
WITH office_employee_count AS (
    SELECT
        o.address,
        COUNT(e.id) AS employees_count
    FROM offices AS o
        INNER JOIN employees AS e
            ON o.id = e.office_id
    GROUP BY o.address
)

(
    SELECT *
    FROM office_employee_count
    WHERE employees_count = (SELECT MAX(employees_count) FROM office_employee_count)
    LIMIT 1
)
UNION
(
    SELECT *
    FROM office_employee_count
    WHERE employees_count = (SELECT MIN(employees_count) FROM office_employee_count)
    LIMIT 1
);

-- 8
SELECT
    e.uuid as uuid,
    CONCAT(e.first_name, ' ', e.last_name) AS full_name,
    e.email AS email,
    e.job_title AS job_title,
    o.name AS company,
    c.name AS country,
    s.name AS state,
    sup.first_name AS boss_name
FROM employees AS e
    INNER JOIN employees AS sup
        ON e.supervisor_id = sup.id
    INNER JOIN offices AS o
        ON e.office_id = o.id
    INNER JOIN states AS s
        ON s.id = o.state_id
    INNER JOIN countries AS c
        ON c.id = o.country_id;
