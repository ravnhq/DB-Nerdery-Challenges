-- Your answers here:
-- 1
SELECT
    type,
    SUM(mount) AS total_money
FROM
    accounts
GROUP BY
    type
ORDER BY
    type ASC;

-- 2
WITH eligible_users AS (
    SELECT
        user_id
    FROM
        accounts
    WHERE
        type = 'CURRENT_ACCOUNT'
    GROUP BY
        user_id
    HAVING
        COUNT(*) >= 2
)
SELECT
    COUNT(*) AS total_users
FROM
    eligible_users;


-- 3
SELECT
    TYPE,
    account_id,
    mount
FROM
    accounts
ORDER BY
    mount DESC
LIMIT
    5;

-- 4

SELECT 
    usr.id AS user_uuid, 
    SUM(CASE 
            WHEN mov.type = 'IN' THEN mov.mount 
            WHEN mov.type IN ('OUT', 'TRANSFER', 'OTHER') THEN -mov.mount 
            ELSE 0 
        END) + SUM(act.mount) AS final_balance
FROM users usr
INNER JOIN accounts act 
    ON usr.id = act.user_id
INNER JOIN movements mov
    ON mov.account_from = act.id
GROUP BY usr.id
ORDER BY final_balance DESC
LIMIT 3;




-- 5

--(A) First, get the ammount for the account 3b79e403-c788-495a-a8ca-86ad7643afaf and fd244313-36e5-4a17-a27c-f8265bc46590 after all their movements. 
SELECT 
    a.id AS account_id,
    a.mount+
	(SUM(
        CASE 
            WHEN m.account_from = a.id THEN -m.mount 
            WHEN m.account_to = a.id THEN m.mount  
        END
    )) AS final_account_amount,
FROM 
    accounts a
INNER JOIN 
    movements m
ON 
    a.id IN (m.account_from, m.account_to)
WHERE 
    a.id IN ('3b79e403-c788-495a-a8ca-86ad7643afaf', 'fd244313-36e5-4a17-a27c-f8265bc46590')
GROUP BY 
    a.id, a.mount;




--(B) Add a new movement with the information: from: 3b79e403-c788-495a-a8ca-86ad7643afaf make a transfer to fd244313-36e5-4a17-a27c-f8265bc46590 mount: 50.75
DO $$ 
DECLARE
    issuing_account UUID := '3b79e403-c788-495a-a8ca-86ad7643afaf';
    receiving_account UUID := 'fd244313-36e5-4a17-a27c-f8265bc46590';
    transfer_amount NUMERIC := 50.75;
BEGIN

    UPDATE accounts
    SET mount = mount - transfer_amount
    WHERE id = first_account;

    UPDATE accounts
    SET mount = mount + transfer_amount
    WHERE id = second_account;

    INSERT INTO movements (id, type, account_from, account_to, mount, created_at, updated_at)
    VALUES (
        gen_random_uuid(),  
        'TRANSFER',         
        issuing_account,      
        receiving_account,     
        transfer_amount,    
        NOW(),              
        NOW()               
    );

    RAISE NOTICE 'Transaction completed from % to % with the amount of %', 
                issuing_account, receiving_account, transfer_amount;
END $$;




-----------------------------------------
--Shows the result of the tranfer--
-----------------------------------------
SELECT 
    m.type, 
    m.account_from, 
    m.account_to, 
    m.mount AS transferred_amount
FROM movements m
WHERE m.account_from = '3b79e403-c788-495a-a8ca-86ad7643afaf'
    OR m.account_to = '3b79e403-c788-495a-a8ca-86ad7643afaf'
ORDER BY m.created_at ASC;



--(c) Add a new movement with the information: from: 3b79e403-c788-495a-a8ca-86ad7643afaf type: OUT mount: 731823.56
DO $$ 
DECLARE
    current_balance NUMERIC;
	affected_account UUID:= '3b79e403-c788-495a-a8ca-86ad7643afaf';
	out_amount NUMERIC := 731823.56;
BEGIN

    SELECT a.mount INTO current_balance
    FROM accounts a
    WHERE a.id = affected_account;

    IF current_balance < out_amount THEN
        RAISE EXCEPTION 'Insufficient balance to do the movement, Transaction rejected';
    END IF;

    INSERT INTO movements (id, type, account_from, account_to, mount, created_at, updated_at)
    VALUES (
        gen_random_uuid(),
        'OUT', 
        affected_account,
		NULL,
		-- out_amount, --5.e you need to pass less money or
        now(),
        now()
    );
	
EXCEPTION
WHEN OTHERS THEN
    RAISE NOTICE '*** Error processing the transaction %. current balance: % % ** Doing ROLLBACK **', 
                out_amount, current_balance, CHR(10);
    ROLLBACK;
    RETURN;


--( f). f. Once the transaction is correct, make a commit
END $$; --> the same as commit



--(g) How much money the account fd244313-36e5-4a17-a27c-f8265bc46590 have:

CREATE FUNCTION get_user_balance(account_id UUID)
RETURNS DOUBLE PRECISION AS $$
DECLARE
    final_balance DOUBLE PRECISION;
BEGIN
    SELECT 
        SUM(CASE 
                WHEN mov.type = 'IN' THEN mov.mount 
                WHEN mov.type IN ('OUT', 'TRANSFER', 'OTHER') THEN -mov.mount 
                ELSE 0 
            END) + SUM(act.mount)
    INTO final_balance
    FROM users usr
    INNER JOIN accounts act 
        ON usr.id = act.user_id
    INNER JOIN movements mov
        ON mov.account_from = act.id
    WHERE usr.id = user_id
    GROUP BY usr.id;
    RETURN final_balance;
END;
$$ LANGUAGE plpgsql;


SELECT get_user_balance('fd244313-36e5-4a17-a27c-f8265bc46590') AS net_balance; --<==== directly the net balance of the account


-- 6

SELECT 
    u.id AS user_id,
    u.name AS user_name,
    u.email AS user_email,
    a.id AS account_id,
    m.id AS movement_id,
    m.type AS movement_type,
    m.account_from AS account_from,
    m.account_to AS account_to
FROM 
    users u
INNER JOIN 
    accounts a
ON 
    u.id = a.user_id
INNER JOIN 
    movements m
ON 
    a.id IN (m.account_from, m.account_to)
WHERE 
    a.id = '3b79e403-c788-495a-a8ca-86ad7643afaf'
ORDER BY 
    m.created_at ASC;

-- 7

SELECT 
    u.name AS user,
    u.email AS email,
    SUM(a.mount) AS total_money
FROM 
    users u
INNER JOIN 
    accounts a
ON 
    u.id = a.user_id
GROUP BY 
    u.id, u.name, u.email
ORDER BY 
    total_money DESC
LIMIT 1;

--8
SELECT 
    u.name AS user_name,
    a.id AS account_id,
    a.type AS account_type,
    m.id AS UUID_movement,
    m.type AS movement_type,
    m.account_from AS account_from,
    m.account_to AS account_to,
    m.created_at AS movement_date
FROM 
    users u
INNER JOIN 
    accounts a
ON 
    u.id = a.user_id
LEFT JOIN 
    movements m
ON 
    a.id IN (m.account_from, m.account_to)
WHERE 
    u.email = 'Kaden.Gusikowski@gmail.com'
ORDER BY 
    a.type ASC,
    m.created_at ASC;

