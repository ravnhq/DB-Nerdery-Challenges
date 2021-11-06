-- Your answers here:
-- 1
SELECT c.name, COUNT(s.id) FROM public.countries c
INNER JOIN public.states s ON c.id = s.country_id
GROUP BY c.name;
-- 2
SELECT COUNT(e.id) AS employees_without_bosses from public.employees e
WHERE e.supervisor_id IS NULL;
-- 3
SELECT c.name, o.address, COUNT(e.id) FROM public.offices o
INNER JOIN public.employees e ON o.id = e.office_id
INNER JOIN public.countries c ON c.id = o.country_id
GROUP BY o.address, c.name
ORDER BY count DESC
LIMIT 5;
-- 4
SELECT supervisor_id, COUNT(supervisor_id) FROM public.employees
GROUP BY supervisor_id
ORDER BY count DESC
LIMIT 3;
-- 5
SELECT COUNT(o.id) AS list_of_office FROM public.offices o
WHERE o.state_id = (
    SELECT id FROM public.states s
    WHERE s.name = 'Colorado'
)
AND o.country_id = (
    SELECT id FROM public.countries c
    WHERE c.name = 'United States'
);
-- 6
SELECT o.name, COUNT(e.id) FROM public.offices o
INNER JOIN public.employees e ON o.id = e.office_id
GROUP BY o.name
ORDER BY count DESC;
-- 7
(
    SELECT o.address, COUNT(e.id) FROM public.offices o
    INNER JOIN public.employees e ON o.id = e.office_id
    GROUP BY o.address
    ORDER BY count DESC
    LIMIT 1
)
UNION ALL
(
    SELECT o.address, COUNT(e.id) FROM public.offices o
    INNER JOIN public.employees e ON o.id = e.office_id
    GROUP BY o.address
    ORDER BY count
    LIMIT 1
);
-- 8
SELECT 
    e.uuid,
    CONCAT(e.first_name, ' ', e.last_name) AS full_name,
    e.email,
    e.job_title,
    o.name AS company,
    c.name AS country,
    s.name AS state,
    boss.first_name AS boss_name
FROM public.employees e
INNER JOIN public.offices o ON e.office_id = o.id
INNER JOIN public.countries c ON o.country_id = c.id
INNER JOIN public.states s ON o.state_id = s.id
INNER JOIN public.employees boss ON e.supervisor_id = boss.id;