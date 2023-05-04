-- Your answers here:
-- 1
SELECT c.name, COUNT(s.name) FROM countries c
    JOIN states s ON c.id = s.country_id
    GROUP BY c.name;
-- 2
SELECT COUNT(id) employees_without_bosses FROM employees
    WHERE supervisor_id IS NULL;
-- 3
SELECT c.name, o.address, COUNT(e.id) count FROM offices o
    JOIN countries c ON o.country_id = c.id
    JOIN employees e ON o.id = e.office_id
    GROUP BY c.name, o.address
    ORDER BY count DESC, c.name
    LIMIT 5;
-- 4
SELECT supervisor_id, COUNT(supervisor_id) count FROM employees
    GROUP BY supervisor_id
    ORDER BY count DESC
    LIMIT 3;
-- 5
SELECT COUNT(id) list_of_office FROM offices
    WHERE state_id = (
        SELECT id FROM states WHERE name = 'Colorado'
    );
-- 6
SELECT o.name, COUNT(e.id) count FROM employees e
    FULL JOIN offices o ON e.office_id = o.id
    GROUP BY o.name
    ORDER BY count DESC;
-- 7
(SELECT o.address, COUNT(e.id) count FROM employees e
    FULL JOIN offices o ON e.office_id = o.id
    GROUP BY o.address
    ORDER BY count DESC
    LIMIT 1)
UNION
(SELECT o.address, COUNT(e.id) count FROM employees e
    JOIN offices o ON e.office_id = o.id
    GROUP BY o.address
    ORDER BY count ASC
    LIMIT 1)
ORDER BY count DESC;
-- 8
SELECT
    e.uuid,
    (e.first_name || ' ' || e.last_name) fullname,
    e.email,
    e.job_title,
    o.name company,
    c.name country,
    s.name state,
    e2.first_name boss_name
FROM employees e
    JOIN offices o ON o.id = e.office_id
    JOIN countries c ON c.id = o.country_id
    JOIN states s ON s.id = o.state_id
    JOIN employees e2 ON e2.id = e.supervisor_id