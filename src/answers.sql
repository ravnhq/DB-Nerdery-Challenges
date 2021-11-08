-- Your answers here:
-- 1
SELECT countries.name,
       COUNT(*)
FROM countries
INNER JOIN states ON countries.id = states.country_id
GROUP BY countries.name;
-- 2
SELECT COUNT(*) AS employees_without_bosses
FROM employees
WHERE employees.supervisor_id IS NULL;
-- 3
SELECT countries.name,
       offices.address,
       count(*)
FROM employees
INNER JOIN offices ON employees.office_id = offices.id
INNER JOIN countries ON offices.country_id = countries.id
GROUP BY countries.name,
         offices.address
ORDER BY count(*) DESC
LIMIT 5;
-- 4
SELECT supervisor.id AS supervisor_id,
       count(*)
FROM employees
INNER JOIN employees AS supervisor ON employees.supervisor_id = supervisor.id
GROUP BY supervisor.id
ORDER BY count(*) DESC
LIMIT 3;
-- 5
SELECT count(*) AS list_of_office
FROM offices                                                             
WHERE offices.state_id  IN                                              
    (SELECT states.id
     FROM states INNER JOIN countries ON countries.id = states.country_id
     WHERE states.name LIKE 'Colorado%' AND countries.name='United States');
-- 6
SELECT offices.name,
       count(*)
FROM offices
INNER JOIN employees ON offices.id = employees.office_id
GROUP BY offices.name
ORDER BY count(*) DESC;
-- 7
WITH number_of_employees_per_address AS
  (SELECT offices.address,
          count(*)
   FROM offices
   INNER JOIN employees ON offices.id = employees.office_id
   GROUP BY offices.address)
  (SELECT *
   FROM number_of_employees_per_address
   ORDER BY COUNT DESC
   LIMIT 1)
UNION ALL
  (SELECT address,
          COUNT
   FROM number_of_employees_per_address
   ORDER BY COUNT ASC
   LIMIT 1);
-- 8
SELECT employees.uuid,
       employees.first_name || ' ' || employees.last_name AS full_name,
       employees.email,
       employees.job_title,
       offices.name AS company,
       countries.name AS country,
       states.name AS state,
       boss.first_name AS boss_name
FROM employees
LEFT JOIN offices ON employees.office_id=offices.id
LEFT JOIN countries ON offices.country_id = countries.id
LEFT JOIN states ON offices.state_id = states.id
LEFT JOIN employees AS boss ON employees.id = boss.id;
