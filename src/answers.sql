-- Your answers here:
-- 1
SELECT type,
       SUM(mount) AS total_money
FROM accounts
GROUP BY type;

-- 2
WITH users_with_at_least_2_current_account AS (
SELECT  u.id,
        u.name,
        COUNT(u.id) AS number_account
    FROM users u
  INNER JOIN accounts a
      ON u.id = a.user_id
    WHERE a.type = 'CURRENT_ACCOUNT'
    GROUP BY u.name, u.id
    HAVING COUNT(u.id) >= 2)

SELECT COUNT(*) AS total_account_at_least_2_current_account
    FROM users_with_at_least_2_current_account;

-- 3
SELECT a.user_id,
       a.account_id,
       a.type,
       a.mount
    FROM accounts a
  ORDER BY a.mount DESC
  LIMIT 5;

-- 4
    --Get total all movements each users
    WITH total_money_all_movements AS (SELECT  u.id AS user_id,
            CONCAT(u.name, ' ', U.last_name) AS full_name,
            SUM(CASE m.type
                WHEN 'IN'
                    THEN m.mount
                    ELSE -m.mount
                END
                ) AS money_movements
        FROM users u
    INNER JOIN accounts a
        ON u.id = a.user_id
    INNER JOIN movements m
        ON a.id = m.account_from
        GROUP BY u.id
        ORDER BY money_movements DESC),
    --Get total all accounts each user 
    total_money_all_accounts_user_before_movements AS (SELECT  u.id,
            u.name || ' ' || u.last_name AS full_name,
            SUM(a.mount) AS total_money_all_accounts
        FROM users u
    INNER JOIN accounts a
        ON u.id = a.user_id
        GROUP BY u.id)
    -- Get total of their money after applied movements
    SELECT acc.full_name,
        acc.id as user_id,
        acc.total_money_all_accounts,
        mov.money_movements,
        (acc.total_money_all_accounts + mov.money_movements)
                AS total_money_after_movements
        FROM total_money_all_accounts_user_before_movements acc
    INNER JOIN total_money_all_movements mov
        ON acc.id = mov.user_id
        ORDER BY total_money_after_movements DESC
        LIMIT 3;
-- 5
    CREATE FUNCTION calculate_amount_after_all_movements(id_account uuid)
    RETURNS DOUBLE PRECISION
    LANGUAGE plpgsql
    AS $$
    DECLARE
        amount_after_movements DOUBLE PRECISION;
    BEGIN
        SELECT (CASE m.type
                    WHEN 'IN'
                        THEN a.mount + m.mount
                        ELSE a.mount - m.mount
                    END)
                     AS money_movements
                INTO amount_after_movements
            FROM accounts a
            INNER JOIN movements m on a.id = m.account_from
            WHERE a.id = id_account;

        RETURN amount_after_movements;
    END;
    $$;

BEGIN TRANSACTION;
  /*
    In this part you need to create a transaction with the following steps:

    a. First, get the amount for the account 3b79e403-c788-495a-a8ca-86ad7643afaf
    and fd244313-36e5-4a17-a27c-f8265bc46590 after all their movements.
    */

    SELECT calculate_amount_after_all_movements('3b79e403-c788-495a-a8ca-86ad7643afaf');
    SELECT calculate_amount_after_all_movements('fd244313-36e5-4a17-a27c-f8265bc46590');

    /*
     b. Add a new movement with the information: from: 3b79e403-c788-495a-a8ca-86ad7643afaf
     make a transfer to fd244313-36e5-4a17-a27c-f8265bc46590 mount: 50.75
    */
    DO $$
        DECLARE
            amount_account_after_movements DOUBLE PRECISION;
        BEGIN
            SELECT calculate_amount_after_all_movements('3b79e403-c788-495a-a8ca-86ad7643afaf') INTO amount_account_after_movements;
            IF amount_account_after_movements >= 50.75 THEN
                INSERT INTO movements (id,type,account_from,account_to,mount,created_at,updated_at)
                VALUES (gen_random_uuid(),'TRANSFER','3b79e403-c788-495a-a8ca-86ad7643afaf','fd244313-36e5-4a17-a27c-f8265bc46590',50.75, NOW(),NOW());
                UPDATE accounts SET mount = mount + 50.75 WHERE id = '3b79e403-c788-495a-a8ca-86ad7643afaf';
                UPDATE accounts SET mount = mount - 50.75 WHERE id = 'fd244313-36e5-4a17-a27c-f8265bc46590';
                RAISE NOTICE 'Successfully transaction';
            ELSE
                RAISE NOTICE 'You dont have sufficient money to do this transaction';
            END IF;
        END;
        $$;
    SAVEPOINT made_first_transaction;

    /*
        c. Add a new movement with the information: from: 3b79e403-c788-495a-a8ca-86ad7643afaf type: OUT mount: 731823.56
    */
     DO $$
        DECLARE
            amount_account_after_movements DOUBLE PRECISION;
        BEGIN
            SELECT calculate_amount_after_all_movements('3b79e403-c788-495a-a8ca-86ad7643afaf')INTO amount_account_after_movements;
            IF amount_account_after_movements >= 731823.56 THEN
                INSERT INTO movements (id,type,account_from,mount,created_at,updated_at)
                VALUES (gen_random_uuid(),'OUT','3b79e403-c788-495a-a8ca-86ad7643afaf',731823.56, NOW(),NOW());
                UPDATE accounts SET mount = mount + 731823.56 WHERE id = '3b79e403-c788-495a-a8ca-86ad7643afaf';
                UPDATE accounts SET mount = mount - 731823.56 WHERE id = 'fd244313-36e5-4a17-a27c-f8265bc46590';
                RAISE NOTICE 'Successfully transaction';
            ELSE
                RAISE NOTICE 'Fail transaction, you dont have sufficient amount in your account, your amount: %',amount_account_after_movements;
            END IF;
        END;
        $$;
    /*
        d. Put your answer here if the transaction fails(YES/NO):
    */
        -- YES, it has failed
    /*
        e. If the transaction fails, make the correction on step c to avoid the failure:
    */
    ROLLBACK TO SAVEPOINT made_first_transaction;
    /*
        f. Once the transaction is correct, make a commit
    */
    COMMIT TRANSACTION;

/*
    e. How much money the account fd244313-36e5-4a17-a27c-f8265bc46590 have:
*/
SELECT calculate_amount_after_all_movements('fd244313-36e5-4a17-a27c-f8265bc46590') AS total_money_after_movements;


-- 6
SELECT u.id AS user_id,
       CONCAT(u.name,' ',u.last_name) AS user_name,
       u.email,
       m.id AS id_movement,
       m.type AS type_movement,
       m.account_from,
       m.account_to,
       m.mount,
       m.created_at
    FROM users u
        INNER JOIN accounts a
            ON u.id = a.user_id
        INNER JOIN movements m
            ON a.id = m.account_from
    WHERE a.id = '3b79e403-c788-495a-a8ca-86ad7643afaf';
-- 7
SELECT u.name,
       u.email,
       SUM(a.mount) AS total_money
    FROM users u
        INNER JOIN accounts a
            ON u.id = a.user_id
    GROUP BY u.id, CONCAT(u.name,' ',u.last_name)
    ORDER BY total_money DESC
    LIMIT 1;
--8
SELECT u.name,
       u.email,
       m.*
    FROM users u
        INNER JOIN accounts a
            ON u.id = a.user_id
        INNER JOIN movements m 
            ON a.id = m.account_from
    WHERE u.email = 'Kaden.Gusikowski@gmail.com'
    ORDER BY a.type, m.created_at;