-- Your answers here:
-- 1
SELECT C.name, COUNT(S.id)
FROM states AS S
INNER JOIN countries AS C
  ON S.country_id = C.id
GROUP BY C.name;

-- 2
SELECT COUNT(id) AS employees_without_bosses
FROM employees
WHERE supervisor_id IS NULL;

-- 3
SELECT C.name, O.address, COUNT(E.id) AS count
FROM offices AS O
INNER JOIN employees AS E
  ON O.id = E.office_id
INNER JOIN countries AS C
  ON c.ID = O.country_id
GROUP BY O.address, C.name ORDER BY count DESC
LIMIT 5;

-- 4
SELECT super.id, COUNT(emp.id) AS count
FROM employees AS emp
INNER JOIN employees AS super
  ON emp.supervisor_id = super.id
GROUP BY super.id ORDER BY count DESC
LIMIT 3;

-- 5
SELECT COUNT(id)
FROM offices
WHERE offices.state_id
IN
(SELECT id FROM states
WHERE name LIKE 'Colorado');

-- 6
  SELECT O.name, COUNT(E.id) AS count
  FROM offices AS O
  INNER JOIN employees AS E
    ON O.id = e.office_id
  GROUP BY O.name ORDER BY count DESC;

-- 7
(SELECT O.address, COUNT(E.id) AS count
FROM offices AS O
INNER JOIN employees AS E
  ON E.office_id = O.id
GROUP BY O.address
ORDER BY count LIMIT 1)
UNION
(SELECT O.address, COUNT(E.id) AS count
 FROM offices AS O
INNER JOIN employees AS E
  ON E.office_id = O.id
 GROUP BY O.address
 ORDER BY count DESC
 LIMIT 1); 

-- 8
SELECT E.uuid, CONCAT(E.first_name, ' ', E.last_name) AS full_name, E.email, E.job_title, O.name AS company, C.name AS country, S.name AS state, super.first_name
FROM employees AS E
INNER JOIN offices AS O
  ON O.id = E.office_id
INNER JOIN countries AS C
  ON C.id = O.country_id
INNER JOIN states AS S
  ON S.id = o.state_id
INNER JOIN employees AS super
  ON super.id = E.supervisor_id
WHERE E.supervisor_id = super.id;