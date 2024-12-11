-- Your answers here:
-- 1

SELECT A.type,
       SUM(mount) AS total
FROM accounts A
GROUP BY A.type;

-- 2

SELECT COUNT(*) AS count
FROM
  (SELECT A.user_id
   FROM accounts AS A
   WHERE A.type = 'CURRENT_ACCOUNT'
   GROUP BY A.user_id
   HAVING COUNT(A.account_id) >= 2) user_ids;

-- 3

SELECT *
FROM accounts A
ORDER BY mount DESC
LIMIT 5;

-- 4
-- Using a main query and subqueries
SELECT user_id,
       SUM(mount + COALESCE(f.total, 0) + COALESCE(t.total, 0)) AS total
FROM accounts A
LEFT JOIN
  (SELECT account_from,
          SUM(CASE
                  WHEN type = 'IN' THEN mount
                  WHEN type = 'OUT'
                       OR type = 'TRANSFER' OR type = 'OTHER' THEN mount * -1
              END) AS total
   FROM movements
   GROUP BY account_from
   ) F ON A.id = F.account_from
LEFT JOIN
  (SELECT account_to,
          SUM(MOUNT) AS total
   FROM movements
   WHERE account_to IS NOT NULL
   GROUP BY account_to
   ) T ON A.id = T.account_to
GROUP BY user_id
ORDER BY total DESC
LIMIT 3;


--Using a function that returns the balance of an account
CREATE OR REPLACE FUNCTION getCurrentAmount(accountId UUID) RETURNS NUMERIC LANGUAGE PLPGSQL AS $$
DECLARE
    total NUMERIC;
begin
    SELECT
        mount + COALESCE(balance_accounts_from.total, 0) + COALESCE(balance_accounts_to.total, 0) AS total INTO total
    FROM accounts A
    LEFT JOIN (
        SELECT
            account_from,
            SUM(CASE
                WHEN type = 'IN' THEN mount
                WHEN type = 'OUT' OR type = 'TRANSFER' OR type = 'OTHER' THEN mount * -1
            END) AS total
        FROM movements
        GROUP BY account_from
    ) balance_accounts_from ON A.id = balance_accounts_from.account_from
    LEFT JOIN (
        SELECT
            account_to,
            SUM(mount) AS total
        FROM movements
        WHERE account_to IS NOT NULL
        GROUP BY account_to
    ) balance_accounts_to ON A.id = balance_accounts_to.account_to
    WHERE A.id = accountId;

    return total;
end;
$$;


SELECT u.name,
       SUM(getCurrentAmount(A.id)) AS amount
FROM users U
INNER JOIN accounts A ON U.id = A.user_id
GROUP BY user_id,
         u.name
ORDER BY amount DESC
LIMIT 3;

-- 5
-- Using a store procedure that simulates a movement
CREATE OR REPLACE PROCEDURE generateMovement(typeTransaction type_movement, mountTransaction NUMERIC, fromAccount UUID, toAccount UUID DEFAULT NULL) LANGUAGE PLPGSQL AS $$
DECLARE
    fromTotal NUMERIC;
    toTotal NUMERIC;
BEGIN
    -- Get current balance
    SELECT getCurrentAmount(fromAccount) INTO fromTotal;
    SELECT getCurrentAmount(toAccount) INTO toTotal;

    RAISE NOTICE 'fromTotal: %', fromTotal;
    RAISE NOTICE 'toTotal: %', toTotal;

    -- Verifying
    IF fromTotal < mountTransaction THEN
        ROLLBACK;
        RAISE EXCEPTION 'Insufficient funds in account %', fromAccount;
    ELSE
        INSERT INTO movements (
            id, type, account_from, account_to, mount, created_at, updated_at
        ) VALUES (
            gen_random_uuid(), typeTransaction, fromAccount, toAccount, mountTransaction, current_timestamp, current_timestamp
        );
        COMMIT;
    END IF;

END;
$$;

-- 6

SELECT U.*,
       M.*
FROM accounts A
INNER JOIN users U ON A.user_id = U.id
LEFT JOIN movements M ON A.id = M.account_from
OR A.id = M.account_to
WHERE A.id = '3b79e403-c788-495a-a8ca-86ad7643afaf';

-- 7

SELECT U.name,
       U.email
FROM users U
WHERE U.id =
    (SELECT u.id
     FROM users U
     INNER JOIN accounts A ON U.id = A.user_id
     GROUP BY u.id
     ORDER BY SUM(getCurrentAmount(A.id)) DESC
     LIMIT 1) 
     
-- 8

SELECT M.*
FROM users U
INNER JOIN accounts A ON U.id = A.user_id
INNER JOIN movements M ON A.id = M.account_from
OR A.id = M.account_to
WHERE u.email = 'Kaden.Gusikowski@gmail.com';