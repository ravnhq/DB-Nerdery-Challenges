-- Your answers here:
-- 1
SELECT c.name, COUNT(c.id)
FROM countries c
         INNER JOIN states s
                    ON s.country_id = c.id
GROUP BY c.name;

-- 2
SELECT COUNT(*) AS "employees_without_boss"
FROM employees em
WHERE supervisor_id IS NULL;

-- 3
SELECT co.name, address, COUNT(em.id) AS count
FROM countries co
         INNER JOIN offices of
                    ON of.country_id = co.id
         INNER JOIN employees em
                    ON em.office_id = of.id
GROUP BY co.name, address
ORDER BY count DESC
LIMIT 5;

-- 4
SELECT em.supervisor_id, COUNT(*) AS count
FROM employees em
WHERE em.supervisor_id IS NOT NULL
GROUP BY em.supervisor_id
ORDER BY count DESC
LIMIT 3;

-- 5
SELECT COUNT(*) AS list_of_office
FROM states st
         INNER JOIN offices of
                    ON of.state_id = st.id
WHERE st.name = 'Colorado';

-- 6
SELECT of.name, COUNT(*) as count
FROM offices of
         INNER JOIN employees em
                    ON em.office_id = of.id
GROUP BY of.name
ORDER BY count DESC;

-- 7
(SELECT of.address, COUNT(*) AS count
 FROM offices of
          INNER JOIN employees em
                     ON em.office_id = of.id
 GROUP BY of.address
 ORDER BY count DESC
 LIMIT 1)
UNION ALL
(SELECT offices.address,
        COUNT(*) AS count
 FROM offices
          INNER JOIN employees em
                     ON em.office_id = offices.id
 GROUP BY offices.address
 ORDER BY count
 LIMIT 1);

 -- 8
 SELECT em.uuid,
       CONCAT(em.first_name, ' ', em.last_name) as full_name,
       em.email,
       em.job_title,
       of.name                                  as company,
       co.name                                  as country,
       st.name                                  as state,
       su.first_name                            as boss_name
FROM employees em
         INNER JOIN offices of
                    ON of.id = em.id
         INNER JOIN countries co
                    ON co.id = of.country_id
         INNER JOIN states st
                    ON st.id = of.state_id
         INNER JOIN employees su ON em.supervisor_id = su.id
WHERE em.supervisor_id IS NOT NULL;
