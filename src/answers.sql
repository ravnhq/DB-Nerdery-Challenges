-- Your answers here:
-- 1
-- Total money of all the accounts group by types.
-- Your query here
SELECT type,
       round(
            CAST(
                SUM(
                    mount
                )
            AS NUMERIC)
       , 2) total_money
FROM accounts
GROUP BY type;

-- 2
-- How many users with at least 2 CURRENT_ACCOUNT.
-- Your query here
WITH users_with_current_account AS (
    SELECT user_id, count(user_id) count
    FROM accounts
    WHERE type = 'CURRENT_ACCOUNT'
    GROUP BY user_id
)
SELECT
    count(uwca.user_id) as users_with_current_account
FROM users_with_current_account uwca
WHERE
    uwca.count >= 2;

-- 3
-- List the top five accounts with more money.
-- Your query here
SELECT *
FROM accounts acc
ORDER BY acc.mount DESC
LIMIT 5;

-- 4
-- Get the three users with the most money after making movements.
-- Your query here
WITH users_total_money AS (
    SELECT a.user_id user_id,
        a.mount + COALESCE(
                   SUM(
                        CASE
                            WHEN m.type = 'IN' THEN m.mount
                            WHEN m.type IN ('OUT', 'OTHER') THEN -m.mount
                            WHEN m.type = 'TRANSFER' AND m.account_from = a.id THEN -m.mount
                            WHEN m.type = 'TRANSFER' AND m.account_to = a.id THEN m.mount
                            ELSE 0
                        END
                    ),
               0) total_mount
    FROM accounts a
    LEFT JOIN movements m ON a.id = m.account_from OR a.id = m.account_to
    GROUP BY a.id
)
SELECT  u.id id,
        u.name || ' ' || u.last_name full_name,
        u.email email
FROM users_total_money utm
INNER JOIN users u ON utm.user_id = u.id
GROUP BY u.id, u.name, utm.total_mount
ORDER BY utm.total_mount DESC
LIMIT 3;

-- 5
-- In this part you need to create a transaction with the following steps:
-- a. First, get the ammount for the account 3b79e403-c788-495a-a8ca-86ad7643afaf and fd244313-36e5-4a17-a27c-f8265bc46590 after all their movements.
SELECT a.id account_id,
       TO_CHAR(
            a.mount + COALESCE(
               SUM(
                    CASE
                        WHEN m.type = 'IN' THEN m.mount
                        WHEN m.type IN ('OUT', 'OTHER') THEN -m.mount
                        WHEN m.type = 'TRANSFER' AND m.account_from = a.id THEN -m.mount
                        WHEN m.type = 'TRANSFER' AND m.account_to = a.id THEN m.mount
                        ELSE 0
                    END
                ),
           0)
       , 'FM999999999.00') final_balance
FROM accounts a
LEFT JOIN movements m ON a.id = m.account_from OR a.id = m.account_to
WHERE a.id = '3b79e403-c788-495a-a8ca-86ad7643afaf' OR a.id = 'fd244313-36e5-4a17-a27c-f8265bc46590'
GROUP BY a.id;

-- b. Add a new movement with the information: from: 3b79e403-c788-495a-a8ca-86ad7643afaf make a transfer to fd244313-36e5-4a17-a27c-f8265bc46590 mount: 50.75
INSERT INTO movements (id, type, account_from, account_to, mount, created_at, updated_at)
VALUES (gen_random_uuid(), 'OTHER', '3b79e403-c788-495a-a8ca-86ad7643afaf', 'fd244313-36e5-4a17-a27c-f8265bc46590', 50.75, now(), now());

-- c. Add a new movement with the information: from: 3b79e403-c788-495a-a8ca-86ad7643afaf type: OUT mount: 731823.56
--  * Note: if the account does not have enough money you need to reject this insert and make a rollback for the entire transaction
BEGIN;

DO $$
    DECLARE
        total_balance NUMERIC;
    BEGIN
        SELECT
           TO_CHAR(
                a.mount + COALESCE(
                   SUM(
                        CASE
                            WHEN m.type = 'IN' THEN m.mount
                            WHEN m.type IN ('OUT', 'OTHER') THEN -m.mount
                            WHEN m.type = 'TRANSFER' AND m.account_from = a.id THEN -m.mount
                            WHEN m.type = 'TRANSFER' AND m.account_to = a.id THEN m.mount
                            ELSE 0
                        END
                    ),
               0)
           , 'FM999999999.00') final_balance INTO total_balance
        FROM accounts a
        LEFT JOIN movements m ON a.id = m.account_from OR a.id = m.account_to
        WHERE a.id = '3b79e403-c788-495a-a8ca-86ad7643afaf'
        GROUP BY a.id;

        IF (total_balance < 731823.56) THEN
            RETURN;
        ELSE
            INSERT INTO movements (id, type, account_from, account_to, mount, created_at, updated_at)
            VALUES (gen_random_uuid(), 'OUT', '3b79e403-c788-495a-a8ca-86ad7643afaf', null, 731823.56, now(), now());
        END IF;
END$$;

COMMIT;

-- d. Put your answer here if the transaction fails(YES/NO):
-- Your answer
SELECT 'YES' AS answer_5_d;

-- e. If the transaction fails, make the correction on step c to avoid the failure:
-- Your query
-- Since the account with id 3b79e403-c788-495a-a8ca-86ad7643afaf has an amount of 5047.66 after all movements,
-- I'd say that we'll need to change only the mount from 731823.56 to 5047.66 so that the account will withdraw
-- the maximum mount possible and leave the account with mount of zero
BEGIN;

DO $$
    DECLARE
        total_balance NUMERIC;
    BEGIN
        SELECT
           TO_CHAR(
                a.mount + COALESCE(
                   SUM(
                        CASE
                            WHEN m.type = 'IN' THEN m.mount
                            WHEN m.type IN ('OUT', 'OTHER') THEN -m.mount
                            WHEN m.type = 'TRANSFER' AND m.account_from = a.id THEN -m.mount
                            WHEN m.type = 'TRANSFER' AND m.account_to = a.id THEN m.mount
                            ELSE 0
                        END
                    ),
               0)
           , 'FM999999999.00') final_balance INTO total_balance
        FROM accounts a
        LEFT JOIN movements m ON a.id = m.account_from OR a.id = m.account_to
        WHERE a.id = '3b79e403-c788-495a-a8ca-86ad7643afaf'
        GROUP BY a.id;

        IF (total_balance < 5047.66) THEN -- Make sure mount to withdraw is available
            RETURN;
        ELSE
            INSERT INTO movements (id, type, account_from, account_to, mount, created_at, updated_at)
            VALUES (gen_random_uuid(), 'OUT', '3b79e403-c788-495a-a8ca-86ad7643afaf', null, 5047.66, now(), now()); -- changed mount here to 5047.66
        END IF;
END$$;

-- f. Once the transaction is correct, make a commit
-- Your query
COMMIT;

-- g. How much money the account fd244313-36e5-4a17-a27c-f8265bc46590 have:
-- Your query
-- 3164.23
SELECT
   TO_CHAR(
        a.mount + COALESCE(
           SUM(
                CASE
                    WHEN m.type = 'IN' THEN m.mount
                    WHEN m.type IN ('OUT', 'OTHER') THEN -m.mount
                    WHEN m.type = 'TRANSFER' AND m.account_from = a.id THEN -m.mount
                    WHEN m.type = 'TRANSFER' AND m.account_to = a.id THEN m.mount
                    ELSE 0
                END
            ),
       0)
   , 'FM999999999.00') final_balance
FROM accounts a
LEFT JOIN movements m ON a.id = m.account_from OR a.id = m.account_to
WHERE a.id = 'fd244313-36e5-4a17-a27c-f8265bc46590'
GROUP BY a.id;

-- 6
-- All the movements and the user information with the account 3b79e403-c788-495a-a8ca-86ad7643afaf
-- Your query here
SELECT
    u_from.name || ' ' || u_from.last_name sender_full_name,
    u_from.email sender_email,
    u_to.name || ' ' || u_to.last_name receiver_full_name,
    u_to.email receiver_email,
    mov.id movement_id,
    mov.type movement_type,
    mov.account_from account_from_id,
    mov.account_to account_to_id,
    mov.mount mount,
    mov.created_at created_at
FROM movements mov
LEFT JOIN accounts a_from ON mov.account_from = a_from.id
LEFT JOIN accounts a_to ON mov.account_to = a_to.id
LEFT JOIN users u_from ON a_from.user_id = u_from.id
LEFT JOIN users u_to ON a_to.user_id = u_to.id
WHERE a_from.id = '3b79e403-c788-495a-a8ca-86ad7643afaf'
    OR a_to.id = '3b79e403-c788-495a-a8ca-86ad7643afaf'
ORDER BY mov.created_at DESC;

-- 7
-- The name and email of the user with the highest money in all his/her accounts
-- Your query here
WITH users_total_money AS (
SELECT a.user_id user_id,
    a.mount + COALESCE(
               SUM(
                    CASE
                        WHEN m.type = 'IN' THEN m.mount
                        WHEN m.type IN ('OUT', 'OTHER') THEN -m.mount
                        WHEN m.type = 'TRANSFER' AND m.account_from = a.id THEN -m.mount
                        WHEN m.type = 'TRANSFER' AND m.account_to = a.id THEN m.mount
                        ELSE 0
                    END
                ),
           0) total_mount
FROM accounts a
LEFT JOIN movements m ON a.id = m.account_from OR a.id = m.account_to
GROUP BY a.id
)
SELECT  u.name,
        u.email
FROM users_total_money utm
INNER JOIN users u ON utm.user_id = u.id
GROUP BY u.id, u.name, utm.total_mount
ORDER BY utm.total_mount DESC
LIMIT 1;

--Show all the movements for the user Kaden.Gusikowski@gmail.com order by account type and created_at on the movements table
-- Your query here
SELECT
    u_from.name || ' ' || u_from.last_name sender_full_name,
    u_from.email sender_email,
    u_to.name || ' ' || u_to.last_name receiver_full_name,
    u_to.email receiver_email,
    mov.id movement_id,
    mov.type movement_type,
    mov.account_from account_from_id,
    mov.account_to account_to_id,
    mov.mount mount,
    mov.created_at created_at
FROM movements mov
LEFT JOIN accounts a_from ON mov.account_from = a_from.id
LEFT JOIN accounts a_to ON mov.account_to = a_to.id
LEFT JOIN users u_from ON a_from.user_id = u_from.id
LEFT JOIN users u_to ON a_to.user_id = u_to.id
WHERE u_from.email = 'Kaden.Gusikowski@gmail.com'
    OR u_to.email = 'Kaden.Gusikowski@gmail.com'
ORDER BY a_from.type, a_to.type, mov.created_at;
