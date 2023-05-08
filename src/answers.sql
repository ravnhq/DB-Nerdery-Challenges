-- Your answers here:
-- 1
SELECT A.type, SUM(A.mount)
FROM accounts A
    GROUP BY A.type;

-- 2
WITH current_accounts_count AS (
    SELECT COUNT(*) AS id_count
    FROM users A
    INNER JOIN accounts B ON A.id = B.user_id
    WHERE B.type = 'CURRENT_ACCOUNT'
    GROUP BY A.id
    HAVING COUNT(*) > 1
)
SELECT COUNT(*) AS users_with_at_least_two
FROM current_accounts_count;

-- 3
SELECT A.user_id, A.type, A.mount
FROM accounts A
    ORDER BY A.mount DESC
    LIMIT 5;

-- 4
--select concat(name, ' ', last_name) as full_name, a.mount from users
--    inner join accounts a on users.id = a.user_id
--    order by a.mount desc limit 3;

-- 5

-- 6
SELECT * FROM movements A
    INNER JOIN accounts B ON B.id = A.account_from
    INNER JOIN users C ON B.user_id = C.id
    WHERE B.id = '3b79e403-c788-495a-a8ca-86ad7643afaf';

-- 7

-- 8
SELECT * FROM movements A
    INNER JOIN accounts B ON A.account_from = B.id
    INNER JOIN users C ON B.user_id = C.id
    WHERE C.email = 'Kaden.Gusikowski@gmail.com'
    ORDER BY B.type, B.created_at;
