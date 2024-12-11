-- Your answers here:
-- 1
SELECT C.name,
       COUNT(*)
FROM states AS S
INNER JOIN countries AS C ON S.country_id = C.id
GROUP BY C.id,
         C.name;
         
-- 2
SELECT COUNT(*)
FROM employees
WHERE supervisor_id IS NULL; 

-- 3
SELECT C.name,
       O.address,
       count(*) AS count
  FROM offices AS O
  INNER JOIN countries AS C ON O.country_id = C.id
  LEFT JOIN employees AS E ON O.id = E.office_id
GROUP BY C.name,
         O.address
ORDER BY count DESC,
         C.name
LIMIT 5;

-- 4
SELECT S.ID, CONCAT(S.first_name, ' ', S.last_name) AS full_name,
       COUNT(*) AS count
FROM employees AS E
INNER JOIN employees AS S ON E.supervisor_id = S.id
GROUP BY S.id, S.first_name, S.last_name
ORDER BY count DESC
LIMIT 3;

-- 5
SELECT count(*) AS count
FROM offices AS O
INNER JOIN states AS S ON O.state_id = S.id
INNER JOIN countries AS C ON O.country_id = C.id
WHERE S.name = 'Colorado'
  AND C.name = 'United States';

-- 6
SELECT O.name,
       COUNT(e.id) AS count
FROM offices AS O
LEFT JOIN employees AS E ON O.id = E.office_id
GROUP BY O.ID,
         O.name
ORDER BY count DESC;

-- 7
SELECT *
FROM
  (SELECT O.name,
          COUNT(E.id) AS count
   FROM offices AS O
   LEFT JOIN employees AS E ON O.id = E.office_id
   GROUP BY O.id,
            O.name
   ORDER BY count
   LIMIT 1) AS employe_lowest_salary
UNION
SELECT *
FROM
  (SELECT O.name,
          COUNT(E.id) AS count
   FROM offices AS O
   LEFT JOIN employees AS E ON O.id = E.office_id
   GROUP BY O.id,
            O.name
   ORDER BY count DESC
   LIMIT 1) AS employe_highest_salary;

-- 8
SELECT E.uuid,
       CONCAT(E.first_name, ' ', E.last_name) AS full_name,
       E.email,
       E.job_title,
       O.name AS company,
       C.name AS country,
       S.name AS state,
       SU.first_name AS boss_name
FROM employees AS E
INNER JOIN offices AS O ON E.office_id = O.id
INNER JOIN states AS S ON O.state_id = S.id
INNER JOIN countries AS C ON O.country_id = C.id
LEFT JOIN employees AS SU ON E.supervisor_id = SU.id;