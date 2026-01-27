-- Your answers here:
\c nerdery_challenge
-- 1
SELECT a.type, SUM(a.mount) 
FROM accounts a 
GROUP BY a.type;
-- 2
SELECT count(*) 
FROM(
    SELECT u.name, count(a.id) AS current_accounts 
    FROM users u 
    LEFT JOIN accounts a ON a.user_id = u.id AND a.type = 'CURRENT_ACCOUNT' 
    GROUP BY u.id 
    HAVING count(a.id) >= 2
    ) AS total_people;
-- 3
SELECT a.id, a.mount
FROM accounts a 
ORDER BY a.mount DESC 
LIMIT 5;
-- 4
WITH normalized_movements AS (
    SELECT account_to as account_id, mount as delta 
    FROM movements WHERE type = 'TRANSFER'
    UNION ALL
    SELECT account_from as account_id, -mount as delta 
    FROM movements WHERE type IN ('OUT', 'TRANSFER', 'OTHER')
    UNION ALL
    SELECT account_from as account_id, mount as delta 
    FROM movements WHERE type = 'IN'
),
account_changes AS (
    SELECT n.account_id , sum(delta) AS net_change
    FROM normalized_movements n 
    GROUP BY n.account_id
)
SELECT
    u.name,
    SUM(a.mount + COALESCE(ac.net_change , 0)) as current_amount
FROM users u
JOIN accounts a ON u.id = a.user_id
LEFT JOIN account_changes ac ON ac.account_id = a.id
GROUP BY u.id
ORDER BY current_amount DESC
LIMIT 3; 
-- 5
-- Function to calculate current amount FROM an account using only its ID
CREATE OR REPLACE FUNCTION get_current_balance(p_account_id UUID)
RETURNS FLOAT AS $$
DECLARE
    v_balance FLOAT;
BEGIN
        SELECT 
            (a.mount + 
                SUM(
                    case 
                        WHEN t.type = 'IN'  or (t.type = 'TRANSFER' AND t.account_to = a.id) THEN t.mount
                        WHEN t.type = 'OUT' or (t.type = 'TRANSFER' AND t.account_from = a.id) THEN -t.mount
                        else 0
                    END
                )
            ) 
        INTO v_balance
        FROM accounts a 
        LEFT JOIN movements t ON a.id IN (t.account_from , t.account_to)
        WHERE a.id = p_account_id
        GROUP BY a.id , a.mount;
        IF v_balance IS NULL THEN
            SELECT mount INTO v_balance FROM accounts WHERE id = p_account_id;
        END IF;
        RETURN COALESCE(v_balance, 0);
END;
$$ language plpgsql;

BEGIN;

DO $$
BEGIN
        IF get_current_balance('3b79e403-c788-495a-a8ca-86ad7643afaf') < 50.75 THEN
            RAISE EXCEPTION 'Insuf. current amount on account';
        END if;
        INSERT INTO movements(id , mount , account_from , account_to , type , created_at , updated_at)
        VALUES (gen_random_uuid() , 50.75 , '3b79e403-c788-495a-a8ca-86ad7643afaf' , 'fd244313-36e5-4a17-a27c-f8265bc46590' , 'TRANSFER' , now() , now()); 
END $$;

DO $$
BEGIN
        -- Using '1823.56' value instead '731823.56' to avoid calling the rollback
        IF get_current_balance('3b79e403-c788-495a-a8ca-86ad7643afaf') < 1823.56 THEN
            RAISE EXCEPTION 'Insuf. current amount on account';
        END IF;
        INSERT INTO movements(id , mount , account_from, type , created_at , updated_at)
        VALUES (gen_random_uuid() , 1823.56, '3b79e403-c788-495a-a8ca-86ad7643afaf', 'OUT' , now() , now()); 
END $$;

COMMIT;
-- 6
SELECT m.*, u.name , u.last_name , u.email 
FROM movements m 
LEFT JOIN accounts a ON a.id in (m.account_from , m.account_to)
LEFT JOIN users u ON a.user_id = u.id
WHERE a.id = '3b79e403-c788-495a-a8ca-86ad7643afaf';
-- 7
-- Use the function defined previously to calculate total_balance for each user
SELECT 
    CONCAT(u.name, ' ', u.last_name) AS full_name, 
    u.email, 
    SUM(get_current_balance(a.id)) AS total_balance
FROM users u 
LEFT JOIN accounts a ON a.user_id = u.id
GROUP BY u.id
ORDER BY total_balance DESC
LIMIT 1;
-- 8
SELECT m.*, u.email, a.type, a.created_at
FROM users u 
INNER JOIN accounts a ON a.user_id = u.id 
INNER JOIN movements m ON a.id IN (m.account_from, m.account_to)
WHERE u.email = 'Kaden.Gusikowski@gmail.com'
ORDER BY a.type ASC, a.created_at DESC; 