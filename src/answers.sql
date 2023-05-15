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
WITH accounts_funds AS (
    SELECT A.id,
           sum(B.mount) AS accounts_total
    FROM users A
    INNER JOIN accounts B ON A.id = B.user_id
    GROUP BY A.id
),
movements_funds AS (
    SELECT  A.id,
            CONCAT(A.name, ' ', A.last_name) AS full_name,
            SUM(
               CASE
                   WHEN C.account_to = B.id THEN C.mount
                   WHEN C.type = 'OTHER' OR
                        C.type = 'TRANSFER' OR
                        C.type = 'OUT' THEN -1 * C.mount
                   ELSE C.mount
               END) AS movements_total
    FROM users A
    INNER JOIN accounts B ON A.id = B.user_id
    INNER JOIN movements C ON B.id = C.account_from OR B.id = C.account_to
    GROUP BY A.name, A.last_name, A.id
)
SELECT A.id,
       A.full_name,
       A.movements_total,
       B.accounts_total,
       (B.accounts_total + A.movements_total) AS total_after_mov
FROM movements_funds A
INNER JOIN accounts_funds B ON B.id = A.id
GROUP BY A.id, A.full_name, A.movements_total, B.accounts_total
ORDER BY total_after_mov DESC LIMIT 3;

-- 5


-- 6
SELECT * FROM movements A
    INNER JOIN accounts B ON B.id = A.account_from
    INNER JOIN users C ON B.user_id = C.id
    WHERE B.id = '3b79e403-c788-495a-a8ca-86ad7643afaf';

-- 7
SELECT A.name,
       A.email,
       sum(B.mount) AS total_funds
FROM users A
INNER JOIN accounts B ON A.id = B.user_id
GROUP BY A.id, A.name, A.email
ORDER BY total_funds DESC LIMIT 1;

-- 8
SELECT * FROM movements A
    INNER JOIN accounts B ON A.account_from = B.id
    INNER JOIN users C ON B.user_id = C.id
    WHERE C.email = 'Kaden.Gusikowski@gmail.com'
    ORDER BY B.type, B.created_at;
