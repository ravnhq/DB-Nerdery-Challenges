-- Your answers here:
-- 1
SELECT type,
       SUM(mount) AS total_money
FROM accounts
GROUP BY type;

-- 2

--Query to find users with at least 2 accounts
WITH users_2_accounts AS (
  SELECT 
    usr.id, 
    usr.name, 
    COUNT(usr.id) AS number_account 
  FROM 
    users usr 
    INNER JOIN accounts a ON usr.id = a.user_id 
  WHERE 
    a.type = 'CURRENT_ACCOUNT' 
  GROUP BY 
    usr.name, 
    usr.id 
  HAVING 
    COUNT(usr.id) >= 2
) 
--Query that count total  accounts with 2 accounts
SELECT 
  COUNT(*) AS total_users 
FROM 
  users_2_accounts;


-- 3
SELECT 
  acc.user_id, 
  acc.account_id, 
  acc.type, 
  acc.mount 
FROM 
  accounts acc 
ORDER BY 
  acc.mount DESC 
LIMIT 
  5;

-- 4
    --Get total all movements each users
WITH total_money_all_movements AS (
  SELECT
    usr.id                               AS user_id,
    CONCAT(usr.name, ' ', usr.last_name) AS full_name,
    SUM(
      CASE m.type WHEN 'IN' THEN m.mount ELSE - m.mount END
    )                                    AS money_movements
  FROM
    users usr
    INNER JOIN accounts a ON usr.id = a.user_id
    INNER JOIN movements m ON a.id = m.account_from
  GROUP BY
    usr.id
  ORDER BY
    money_movements DESC
),
--Get total all accounts each user before discount movements
total_money_before_movements AS (
  SELECT
    usr.id,
    usr.name || ' ' || usr.last_name AS full_name,
    SUM(a.mount) AS total_money_all_accounts
  FROM
    users usr
    INNER JOIN accounts a ON usr.id = a.user_id
  GROUP BY
    usr.id
) -- Get total of their money after applied movements
SELECT
  acc.full_name,
  acc.id as user_id,
  acc.total_money_all_accounts,
  mov.money_movements,
  (
    acc.total_money_all_accounts + mov.money_movements
  ) AS total_money_after_movements
FROM
  total_money_before_movements acc
  INNER JOIN total_money_all_movements mov ON acc.id = mov.user_id
ORDER BY
  total_money_after_movements DESC
LIMIT
  3;

-- 5
CREATE FUNCTION calculate_amount_after_all_movements(id_account UUID)
    RETURNS DOUBLE PRECISION
    LANGUAGE plpgsql
    AS $$
    DECLARE
        amount_after_movements DOUBLE PRECISION;
    BEGIN
        SELECT (CASE m.type
                    WHEN 'IN'
                        THEN acc.mount + m.mount
                        ELSE acc.mount - m.mount
                    END)
                     AS money_movements
                INTO amount_after_movements
            FROM accounts acc
            INNER JOIN movements m on acc.id = m.account_from
            WHERE acc.id = id_account;

        RETURN amount_after_movements;
    END;
    $$;

BEGIN TRANSACTION;
/*
    In this part you need to create a transaction with the following steps:

    a. First, get the amount for the account 3b79e403-c788-495a-a8ca-86ad7643afaf
    and fd244313-36e5-4a17-a27c-f8265bc46590 after all their movements.
    */
SELECT
  calculate_amount_after_all_movements(
    '3b79e403-c788-495a-a8ca-86ad7643afaf'
  );
SELECT
  calculate_amount_after_all_movements(
    'fd244313-36e5-4a17-a27c-f8265bc46590'
  );

DO $$ DECLARE amount_account_after_movements DOUBLE PRECISION;
movement_amount DECIMAL := 50.75;
today DATE := NOW();
account_from UUID := '3b79e403-c788-495a-a8ca-86ad7643afaf';
account_to UUID := 'fd244313-36e5-4a17-a27c-f8265bc46590';
BEGIN
SELECT
  calculate_amount_after_all_movements(
    account_from
  ) INTO amount_account_after_movements;
IF amount_account_after_movements >= movement_amount THEN INSERT INTO movements (
  id, type, account_from, account_to,
  mount, created_at, updated_at
)
VALUES
  (
    gen_random_uuid(),
    'TRANSFER',
    account_from,
    account_to,
    movement_amount,
    today,
    today
  );
UPDATE
  accounts
SET
  mount = mount + movement_amount
WHERE
  id = account_from;
UPDATE
  accounts
SET
  mount = mount - movement_amount
WHERE
  id = account_to;
RAISE NOTICE 'Successfully transaction';
ELSE RAISE NOTICE 'You dont have sufficient money to do this transaction';
END IF;
END;
$$;
SAVEPOINT made_first_transaction;
/*
        c. Add a new movement with the information: from: 3b79e403-c788-495a-a8ca-86ad7643afaf type: OUT mount: 731823.56
    */
DO $$ DECLARE amount_account_after_movements DOUBLE PRECISION;
movement_amount DECIMAL := 731823.56;
account_from UUID := '3b79e403-c788-495a-a8ca-86ad7643afaf';
BEGIN
SELECT
  calculate_amount_after_all_movements(
    account_from
  ) INTO amount_account_after_movements;
IF amount_account_after_movements >= movement_amount THEN INSERT INTO movements (
  id, type, account_from, mount, created_at,
  updated_at
)
VALUES
  (
    gen_random_uuid(),
    'OUT',
    account_from,
    movement_amount,
    NOW(),
    NOW()
  );
UPDATE
  accounts
SET
  mount = mount + movement_amount
WHERE
  id = account_from;
UPDATE
  accounts
SET
  mount = mount - movement_amount
WHERE
  id = account_from;
RAISE NOTICE 'Successfully transaction';
ELSE RAISE NOTICE 'Fail transaction, you dont have sufficient amount in your account, your amount: %',
amount_account_after_movements;
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
SELECT
  calculate_amount_after_all_movements(
    'fd244313-36e5-4a17-a27c-f8265bc46590'
  ) AS total_money_after_movements;


-- 6
SELECT 
  usr.id AS user_id, 
  CONCAT(usr.name, ' ', usr.last_name) AS user_name, 
  usr.email, 
  mov.id AS id_movement, 
  mov.type AS type_movement, 
  mov.account_from, 
  mov.account_to, 
  mov.mount, 
  mov.created_at 
FROM 
  users usr 
  INNER JOIN accounts acc ON usr.id = acc.user_id 
  INNER JOIN movements mov ON acc.id = mov.account_from 
WHERE 
  acc.id = '3b79e403-c788-495a-a8ca-86ad7643afaf';

-- 7
SELECT 
  urs.name, 
  urs.email, 
  SUM(acc.mount) AS total_money 
FROM 
  users urs 
  INNER JOIN accounts acc ON urs.id = acc.user_id 
GROUP BY 
  urs.id, 
  CONCAT(urs.name, ' ', urs.last_name) 
ORDER BY 
  total_money DESC 
LIMIT 
  1;
--8
SELECT 
  usr.name, 
  usr.email, 
  mov.* 
FROM 
  users usr 
  INNER JOIN accounts acc ON usr.id = acc.user_id 
  INNER JOIN movements mov ON acc.id = mov.account_from 
WHERE 
  usr.email = 'Kaden.Gusikowski@gmail.com' 
ORDER BY 
  acc.type, 
  mov.created_at;
