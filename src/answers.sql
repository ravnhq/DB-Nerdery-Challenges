-- Your answers here:
-- 1
SELECT countries.name AS countries_name,
       COUNT(states.name) AS states_name
FROM countries
    INNER JOIN states ON countries.id = states.country_id
    GROUP BY countries_name;


-- 2
SELECT COUNT(A.first_name) AS employees_without_bosses
FROM employees A
    WHERE A.supervisor_id IS NULL;


-- 3
SELECT C.name,
       A.address,
       COUNT(B.office_id) AS count
FROM offices A
    INNER JOIN employees B ON A.id = b.office_id
    INNER JOIN countries C ON A.country_id = C.id
    GROUP BY A.address,
             C.name
    ORDER BY count DESC LIMIT 5;


-- 4
SELECT A.supervisor_id,
       COUNT(A.id)
FROM employees A
    WHERE supervisor_id IS NOT NULL
    GROUP BY A.supervisor_id
    ORDER BY COUNT(A.id) DESC LIMIT 3;


-- 5
SELECT COUNT(A.name) AS list_of_office
FROM offices A
    INNER JOIN states B ON A.state_id = B.id
    WHERE B.name = 'Colorado';


-- 6
SELECT A.name,
       COUNT(B.first_name)
FROM offices A
    INNER JOIN employees B ON B.office_id = A.id
    GROUP BY A.name ORDER BY COUNT(B.first_name) DESC;


-- 7
WITH employees_count AS (
    SELECT B.address,
           COUNT(*) AS count
    FROM employees A
    INNER JOIN offices B ON A.office_id = B.id
    GROUP BY B.address
),
employees_max AS (
    SELECT A.address,
           A.count
    FROM employees_count A
    ORDER BY A.count DESC LIMIT 1
),
employees_min AS (
    SELECT A.address,
           A.count
    FROM employees_count A
    ORDER BY A.count LIMIT 1
)
SELECT * FROM employees_max
         UNION
SELECT * FROM employees_min;


-- 8
SELECT  A.uuid,
        CONCAT(A.first_name, ' ', A.last_name) AS full_name,
        A.email,
        A.job_title,
        B.name AS company,
        C.name AS country,
        D.name AS state,
        E.first_name AS boss_name
FROM employees A
    INNER JOIN offices B ON B.id = A.office_id
    INNER JOIN countries C ON C.id = B.country_id
    INNER JOIN states D ON D.id = B.state_id
    INNER JOIN employees E ON E.id = A.supervisor_id;


