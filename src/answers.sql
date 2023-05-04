-- Your answers here:
-- 1
		SELECT 	c.name,
			COUNT(s.name)
			FROM countries c
		INNER JOIN states s
			ON c.id = s.country_id
			GROUP BY c.name
-- 2
		SELECT COUNT(first_name) AS employees_without_boss
				FROM employees
			WHERE supervisor_id IS NULL
-- 3
		SELECT 	c.name, 
				o.address, 
				COUNT(e.id)
			FROM countries c
		INNER JOIN offices o
			ON o.country_id = c.id
		INNER JOIN employees e
			ON e.office_id = o.id
		GROUP BY c.name, o.address 
		ORDER BY COUNT(e.id) DESC, o.address, c.name 
		LIMIT 5
-- 4
    	SELECT 	supervisor_id, 
				COUNT(supervisor_id)
			    FROM employees
            GROUP BY supervisor_id
            ORDER BY COUNT(supervisor_id) DESC
            LIMIT 3

-- 5						
		SELECT COUNT(ofi.state_id) AS list_of_office
			FROM offices ofi
		INNER JOIN states sta
			ON ofi.state_id = sta.id
			WHERE sta.name = 'Colorado'
-- 6
		SELECT 	ofi.name,
				COUNT(emp.id)
			FROM offices ofi
		INNER JOIN	employees emp
				ON 	emp.office_id = ofi.id
			GROUP BY ofi.name
			ORDER BY COUNT(emp.id) DESC;
-- 7
		(SELECT ofi.address,
				COUNT(emp.id)
			FROM offices ofi
		INNER JOIN employees emp
			ON emp.office_id = ofi.id
			GROUP BY ofi.address
			ORDER BY COUNT(emp.id) DESC
			LIMIT 1)
		UNION
		(SELECT ofi.address,
				COUNT(emp.id)
			FROM offices ofi
		INNER JOIN employees emp
			ON emp.office_id = ofi.id
			GROUP BY ofi.address
			ORDER BY COUNT(emp.id)
			LIMIT 1)

-- 8
		SELECT emp.uuid, 
				CONCAT(emp.first_name,' ',emp.last_name) AS full_name,
				emp.email,
				emp.job_title,
				ofi.name AS company,
				con.name AS country,
				sta.name AS state,
				boss.first_name AS boss_name
			FROM employees emp
		INNER JOIN offices ofi
			ON emp.office_id = ofi.id
		INNER JOIN countries con
			ON ofi.country_id = con.id
		INNER JOIN states sta
			ON ofi.state_id = sta.id
		INNER JOIN employees boss
			ON boss.id = emp.supervisor_id;