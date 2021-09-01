-- Your answers here:
-- 1
SELECT C.name, COUNT(S.id)
FROM states AS S
INNER JOIN countries AS C
  ON S.country_id = C.id
GROUP BY C.name;

-- 2

-- 3

-- 4

-- 5

-- 6

-- 7

