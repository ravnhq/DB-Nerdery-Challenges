-- Your answers here:
-- 1
SELECT type, SUM(mount) 
FROM accounts 
GROUP BY type;

-- 2
SELECT COUNT(*) AS users_with_multiple_accounts
FROM (
    SELECT u.id
    FROM users u
    JOIN accounts a ON u.id = a.user_id
    WHERE a.type = 'CURRENT_ACCOUNT'
    GROUP BY u.id
    HAVING COUNT(*) >= 2
) sub;

-- 3
SELECT account_id, mount
FROM accounts
ORDER BY mount DESC 
LIMIT 5;

-- 4
CREATE TEMP TABLE temp_user_balances AS
WITH Inflow AS (
    SELECT a.user_id, SUM(m.mount) AS total_received
    FROM movements m
    JOIN accounts a ON m.account_to = a.id
    GROUP BY a.user_id
),
Deposits AS (
    SELECT a.user_id, SUM(m.mount) AS total_deposits
    FROM movements m
    JOIN accounts a ON m.account_from = a.id
    WHERE m.type IN ('IN')
    GROUP BY a.user_id
),
InitialBalances AS (
    SELECT user_id, SUM(mount) AS initial_total
    FROM accounts
    GROUP BY user_id
)
SELECT
    u.*,
    (
        COALESCE(ib.initial_total, 0)
      + COALESCE(inf.total_received, 0)
      + COALESCE(dep.total_deposits, 0)
    ) AS total_balance
FROM users u
LEFT JOIN InitialBalances ib ON u.id = ib.user_id
LEFT JOIN Inflow inf ON u.id = inf.user_id
LEFT JOIN Deposits dep ON u.id = dep.user_id;


SELECT 
    name || ' ' || last_name AS user_full_name,
    email, 
    total_balance
FROM temp_user_balances
ORDER BY total_balance DESC
LIMIT 3;


-- 5
    DO $$
    DECLARE
        account_a_id uuid := '3b79e403-c788-495a-a8ca-86ad7643afaf';
        account_b_id uuid := 'fd244313-36e5-4a17-a27c-f8265bc46590';
        current_balance_a FLOAT;
        transfer_amount FLOAT := 50.75;
        out_amount FLOAT := 731823.56;
    BEGIN
        -- a. Get initial amounts
        SELECT
            a.mount +
            COALESCE(SUM(
                CASE
                    WHEN m.type = 'IN' AND m.account_from = a.id THEN m.mount
                    WHEN m.type != 'IN' AND m.account_from = a.id THEN -m.mount
                    WHEN m.account_to = a.id THEN m.mount
                    ELSE 0
                END
            ), 0)  INTO current_balance_a
        FROM accounts a
        LEFT JOIN movements m
            ON a.id = m.account_from OR a.id = m.account_to
        WHERE a.id = account_a_id
        GROUP BY a.mount;
        
        -- b. Add Transfer Movement
        
        -- Insert movement record
        INSERT INTO movements (id, type, account_from, account_to, mount)
        VALUES (gen_random_uuid(), 'TRANSFER', account_a_id, account_b_id, transfer_amount);

        -- c. Add OUT movement with conditional check
        -- Fetch balance again after the transfer
        SELECT
            a.mount +
            COALESCE(SUM(
                CASE
                    WHEN m.type = 'IN' AND m.account_from = a.id THEN m.mount
                    WHEN m.type != 'IN' AND m.account_from = a.id THEN -m.mount
                    WHEN m.account_to = a.id THEN m.mount
                    ELSE 0
                END
            ), 0)  INTO current_balance_a
        FROM accounts a
        LEFT JOIN movements m
            ON a.id = m.account_from OR a.id = m.account_to
        WHERE a.id = account_a_id
        GROUP BY a.mount;

        IF current_balance_a < out_amount THEN
            -- This triggers the failure and rollback
            RAISE EXCEPTION 'Insufficient funds: Account has %, but needs %', current_balance_a, out_amount;
        ELSE
            -- Perform OUT movement
            
            INSERT INTO movements (id, type, account_from, mount)
            VALUES (gen_random_uuid(), 'OUT', account_a_id, out_amount);
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'Transaction Failed: Rolling back changes. Error: %', SQLERRM;
            ROLLBACK;
    END $$;
    COMMIT;

-- 6
SELECT 
    u.name || ' ' || u.last_name as account_user, 
    u.email, 
    a.account_id, 
    m.type, 
    m.mount 
FROM users u 
INNER JOIN accounts a ON a.user_id = u.id 
LEFT JOIN movements m ON a.id = m.account_from or a.id = m.account_to 
WHERE a.id = '3b79e403-c788-495a-a8ca-86ad7643afaf';

-- 7

WITH Inflow AS (
    SELECT a.user_id, SUM(m.mount) as total_received
    FROM movements m
    JOIN accounts a ON m.account_to = a.id
    GROUP BY a.user_id
),
Outflow AS (
    SELECT a.user_id, SUM(m.mount) as total_sent
    FROM movements m
    JOIN accounts a ON m.account_from = a.id
    WHERE m.type NOT IN ('IN')
    GROUP BY a.user_id
),
Deposits AS (
    SELECT a.user_id, SUM(m.mount) as total_deposits
    FROM movements m
    JOIN accounts a ON m.account_from = a.id
    WHERE m.type IN ('IN')
    GROUP BY a.user_id
),
InitialBalances AS (
    SELECT user_id, SUM(mount) as initial_total
    FROM accounts
    GROUP BY user_id
) SELECT u.name || ' ' || u.last_name as user_full_name,
    u.email,
    (COALESCE(ib.initial_total, 0) + 
    COALESCE(inf.total_received, 0) + 
    COALESCE(dep.total_deposits, 0)) AS total_balance
FROM users u
LEFT JOIN InitialBalances ib ON u.id = ib.user_id
LEFT JOIN Inflow inf ON u.id = inf.user_id
LEFT JOIN Deposits dep ON u.id = dep.user_id
ORDER BY total_balance DESC
LIMIT 1;

-- 8
SELECT 
    a.type, 
    m.created_at, 
    m.mount 
FROM accounts a 
JOIN movements m 
ON 
    m.account_from = a.id 
    or 
    m.account_to = a.id 
LEFT JOIN users u ON a.user_id = u.id 
where email ILIKE 'Kaden.Gusikowski@gmail.com';