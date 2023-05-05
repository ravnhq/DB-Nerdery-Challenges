SELECT *
FROM accounts;

SELECT *
FROM movements;

SELECT *
FROM users;

-- 1. Total money of all the accounts group by types
SELECT ac.type, SUM(mount)
FROM accounts ac
GROUP BY ac.type;

-- 2. How many users with at least 2 'CURRENT_ACCOUNT'

/*
-- Counts peer user
SELECT u.id, COUNT(*) AS user_account
FROM users u
         INNER JOIN accounts a on u.id = a.user_id
GROUP BY u.id;

-- Counts peer users where X acc acount
SELECT u.id, COUNT(*) AS user_account
FROM users u
         INNER JOIN accounts a on u.id = a.user_id
WHERE a.type = 'CURRENT_ACCOUNT'
GROUP BY u.id;
 */

-- Result
SELECT COUNT(*)
FROM (SELECT COUNT(*) AS user_account
      FROM users u
               INNER JOIN accounts a on u.id = a.user_id
      WHERE a.type = 'CURRENT_ACCOUNT'
      GROUP BY u.id
      HAVING COUNT(*) > 2) AS sq;

-- 3. List the top five accounts with more money
SELECT ac.mount
FROM accounts ac
ORDER BY ac.mount DESC
LIMIT 5;

--4. Get the three users with the most money after making movements.

/*
SELECT m.account_from, SUM(m.mount)
FROM movements m
GROUP BY m.account_from;

SELECT a.id, a.mount, m.account_from, SUM(m.mount)
FROM movements m,
     accounts a
WHERE a.id = m.account_from
GROUP BY m.account_from, a.id, a.mount
ORDER BY a.id;
*/

SELECT us.name,
       us.id,
       a.mount      AS account_amount,
       SUM(m.mount) AS mov_amount,
       CASE
           WHEN m.type = 'TRANSFER' THEN
               SUM(a.mount) + SUM(m.mount)
           WHEN m.type = 'IN' THEN
               SUM(a.mount) + SUM(m.mount)
           ELSE
               SUM(a.mount) - SUM(m.mount)
           END
                    AS total_amount
FROM users us
         INNER JOIN accounts a ON us.id = a.user_id
         INNER JOIN movements m ON a.id = m.account_from
GROUP BY us.name, us.id, a.mount, m.type
ORDER BY total_amount DESC
LIMIT 3;

-- 5. In this part you need to create a transaction with the following steps:

--  First, get the amount for the account 3b79e403-c788-495a-a8ca-86ad7643afaf and
--  fd244313-36e5-4a17-a27c-f8265bc46590 after all their movements.

CREATE OR REPLACE FUNCTION get_account_amount_after_movements(
    acc_id uuid
)
    RETURNS double precision
    LANGUAGE plpgsql
AS
$$
DECLARE
    remaining_amount double precision;
BEGIN
    SELECT mount FROM accounts WHERE id = acc_id INTO remaining_amount;

    RETURN remaining_amount;
END
$$;

drop function get_account_amount_after_movements;

SELECT get_account_amount_after_movements('3b79e403-c788-495a-a8ca-86ad7643afaf');
SELECT get_account_amount_after_movements('fd244313-36e5-4a17-a27c-f8265bc46590');

--  b. Add a new movement with the information:
--  from: 3b79e403-c788-495a-a8ca-86ad7643afaf make a
--  transfer to fd244313-36e5-4a17-a27c-f8265bc46590 mount: 50.75

BEGIN;
DO $$
DECLARE
    temp_amount double precision;
BEGIN
    SELECT get_account_amount_after_movements('3b79e403-c788-495a-a8ca-86ad7643afaf') INTO temp_amount;

    -- Check if amount is sufficient
    IF temp_amount < 50.75 THEN
        BEGIN
            RAISE EXCEPTION 'Insufficient amount';
        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK;
                RAISE;
        END;
    END IF;

    -- Make transfer (create movement, update account mount)
    INSERT INTO movements (id, type, account_from, account_to, mount)
    VALUES (gen_random_uuid(), 'TRANSFER', '3b79e403-c788-495a-a8ca-86ad7643afaf',
            'fd244313-36e5-4a17-a27c-f8265bc46590',
            50.75);

    UPDATE accounts SET mount = mount + 50.75 WHERE id = 'fd244313-36e5-4a17-a27c-f8265bc46590';
    UPDATE accounts SET mount = mount - 50.75 WHERE id = '3b79e403-c788-495a-a8ca-86ad7643afaf';

    -- Update account A amount
    SELECT get_account_amount_after_movements('3b79e403-c788-495a-a8ca-86ad7643afaf') INTO temp_amount;

    IF temp_amount < 731823.56 THEN
        BEGIN
            RAISE EXCEPTION 'Insufficient amount';
        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK;
                RAISE;
        END;
    END IF;

    -- Make out movement (c)
    INSERT INTO movements (id, type, account_from, account_to, mount)
    VALUES (gen_random_uuid(), 'OUT', '3b79e403-c788-495a-a8ca-86ad7643afaf', null, 1.01);

    UPDATE accounts SET mount = mount - 731823.56 WHERE id = '3b79e403-c788-495a-a8ca-86ad7643afaf';
END;
$$;
COMMIT;
SELECT * FROM get_account_amount_after_movements('3b79e403-c788-495a-a8ca-86ad7643afaf');

    -- c. Add a new movement with the information: from: 3b79e403-c788-495a-a8ca-86ad7643afaf type:
    -- OUT mount: 731823.56
    -- ( * Note: if the account does not have enough money you need to reject this insert
    -- and make a rollback for the entire transaction)


-- d. Put your answer here if the transaction fails(YES/NO):
-- YES

-- e. If the transaction fails, make the correction on step c to avoid the failure:
SELECT get_account_amount_after_movements('3b79e403-c788-495a-a8ca-86ad7643afaf') AS total_amoun;

-- f. Once the transaction is correct, make a commit
SELECT get_account_amount_after_movements('3b79e403-c788-495a-a8ca-86ad7643afaf');

-- g. How much money the account fd244313-36e5-4a17-a27c-f8265bc46590 have:
SELECT get_account_amount_after_movements('fd244313-36e5-4a17-a27c-f8265bc46590');

-- 6. All the movements and the user information with the account 3b79e403-c788-495a-a8ca-86ad7643afaf
SELECT us.id,
       CONCAT(us.name, ' ', us.last_name) AS fullname,
       us.email,
       mov.account_from,
       mov.account_to,
       mov.mount
FROM movements mov
         INNER JOIN accounts a on mov.account_from = a.id
         INNER JOIN users us on a.user_id = us.id
WHERE a.id = '3b79e403-c788-495a-a8ca-86ad7643afaf';

-- 7. The name and email of the user with the highest money in all his/her accounts
SELECT us.name,
       us.email,
       CASE
           WHEN m.type = 'TRANSFER' THEN
               SUM(a.mount) + SUM(m.mount)
           WHEN m.type = 'IN' THEN
               SUM(a.mount) + SUM(m.mount)
           ELSE
               SUM(a.mount) - SUM(m.mount)
           END
           AS total_amount
FROM users us
         INNER JOIN accounts a ON us.id = a.user_id
         INNER JOIN movements m ON a.id = m.account_from
GROUP BY us.name, us.id, a.mount, m.type
ORDER BY total_amount DESC
LIMIT 1;

-- 8. Show all the movements for the user Kaden.Gusikowski@gmail.com order
-- by account type and created_at on the movements table

SELECT mov.id, mov.type, mov.account_from, mov.account_to, mov.mount, mov.created_at, mov.updated_at
FROM movements mov
         INNER JOIN accounts a on mov.account_from = a.id
         INNER JOIN users us on a.user_id = us.id
WHERE us.email = 'Kaden.Gusikowski@gmail.com'
ORDER BY a.type, a.created_at;