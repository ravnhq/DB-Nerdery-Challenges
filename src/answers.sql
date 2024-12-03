-- Your answers here:
-- 1
SELECT accounts.type, SUM(accounts.mount) AS total 
FROM accounts
GROUP BY accounts.type;

--------------------------------------------------------------------------------------------------------------

-- 2
SELECT COUNT(*) AS users_with_at_least_two_accounts
FROM (
    SELECT accounts.user_id
    FROM accounts
    WHERE accounts.type = 'CURRENT_ACCOUNT'
    GROUP BY accounts.user_id
    HAVING COUNT(accounts.type) >= 2
) AS subquery;

--------------------------------------------------------------------------------------------------------------

-- 3
SELECT accounts.id, accounts.user_id, accounts.type, accounts.mount 
FROM accounts
ORDER BY accounts.mount DESC
LIMIT 5;

--------------------------------------------------------------------------------------------------------------

-- 4
WITH user_balances AS (
    SELECT
        a.user_id,
        SUM(CASE 
    			WHEN m.type = 'IN' OR (m.type IN ('TRANSFER', 'OTHER') AND m.account_to = a.id) THEN m.mount    
    			WHEN (m.type IN ('TRANSFER', 'OTHER') AND m.account_from = a.id) OR m.type = 'OUT' THEN -m.mount
                ELSE 0
            END) + a.mount AS total_balance
    FROM
        accounts a
    LEFT JOIN
    	movements m ON a.id IN (m.account_from, m.account_to)
    GROUP BY
        a.user_id, a.mount
)
SELECT 
    ub.user_id, 
    SUM(ub.total_balance) AS total_balance
FROM 
    user_balances ub
GROUP BY
    ub.user_id
ORDER BY
    total_balance DESC
LIMIT 3;

--------------------------------------------------------------------------------------------------------------

-- 5

-- a. First, get the ammount for the account `3b79e403-c788-495a-a8ca-86ad7643afaf` and `fd244313-36e5-4a17-a27c-f8265bc46590` after all their movements.
-- b. Add a new movement with the information:
--     from: `3b79e403-c788-495a-a8ca-86ad7643afaf` make a transfer to `fd244313-36e5-4a17-a27c-f8265bc46590`
--     mount: 50.75

-- c. Add a new movement with the information:
--     from: `3b79e403-c788-495a-a8ca-86ad7643afaf`
--     type: OUT
--     mount: 731823.56

CREATE OR REPLACE FUNCTION get_user_balance(user_id_input UUID)
RETURNS NUMERIC AS $$
DECLARE
    total_balance NUMERIC;
BEGIN
    SELECT 
        SUM(
            CASE
                WHEN m.type = 'IN' OR (m.type IN ('TRANSFER', 'OTHER') AND m.account_to = a.id) THEN m.mount    
    			WHEN (m.type IN ('TRANSFER', 'OTHER') AND m.account_from = a.id) OR m.type = 'OUT' THEN -m.mount
                ELSE 0
            END
        ) + a.mount
    INTO total_balance
    FROM 
        accounts a
    LEFT JOIN 
    	movements m ON a.id IN (m.account_from, m.account_to)
    WHERE 
        a.user_id = user_id_input
    GROUP BY 
        a.user_id, a.mount;
 
    RETURN total_balance;
END;
$$ LANGUAGE plpgsql;

DO $$
DECLARE
    balance_1 NUMERIC;
    balance_2 NUMERIC;
    account_1 UUID := '3b79e403-c788-495a-a8ca-86ad7643afaf';
    account_2 UUID := 'fd244313-36e5-4a17-a27c-f8265bc46590';
    transfer_amount NUMERIC := 50.75;
    out_amount NUMERIC := 731823.56;
BEGIN
    BEGIN        
        balance_1 := calcular_saldo(account_1);
        balance_2 := calcular_saldo(account_2);

        RAISE NOTICE 'Opening balance account 1: %, opening balance account 2: %', balance_1, balance_2;

        INSERT INTO movements (id, account_from, account_to, type, mount)
        VALUES (gen_random_uuid(), account_1, account_2, 'TRANSFER', transfer_amount);

        balance_1 := balance_1 - transfer_amount;
        balance_2 := balance_2 + transfer_amount;

        IF balance_2 < out_amount THEN
            RAISE EXCEPTION 'Insufficient balance to carry out the OUT type transaction. Balance available: %, amount required: %.', balance_2, out_amount;
        END IF;

        INSERT INTO movements (id, account_from, type, mount)
        VALUES (gen_random_uuid(), account_1, 'OUT', out_amount);

        balance_1 := calcular_saldo(account_1);
        balance_2 := calcular_saldo(account_2);

        RAISE NOTICE 'Movements inserted correctly. Closing balance account 1: %, closing balance account 2: %', balance_1, balance_2;

    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'Error: %', SQLERRM;
            RAISE;
    END;
END $$;

-- e. If the transaction fails, make the correction on step _c_ to avoid the failure:
-- If the balance is not sufficient, reduce the amount_out amount so that it does not cause an error.
CREATE OR REPLACE FUNCTION get_user_balance(user_id_input UUID)
RETURNS NUMERIC AS $$
DECLARE
    total_balance NUMERIC;
BEGIN
    SELECT 
        SUM(
            CASE
                WHEN m.type = 'IN' OR (m.type IN ('TRANSFER', 'OTHER') AND m.account_to = a.id) THEN m.mount    
    			WHEN (m.type IN ('TRANSFER', 'OTHER') AND m.account_from = a.id) OR m.type = 'OUT' THEN -m.mount
                ELSE 0
            END
        ) + a.mount
    INTO total_balance
    FROM 
        accounts a
    LEFT JOIN 
    	movements m ON a.id IN (m.account_from, m.account_to)
    WHERE 
        a.user_id = user_id_input
    GROUP BY 
        a.user_id, a.mount;
 
    RETURN total_balance;
END;
$$ LANGUAGE plpgsql;

DO $$
DECLARE
    balance_1 NUMERIC;
    balance_2 NUMERIC;
    account_1 UUID := '3b79e403-c788-495a-a8ca-86ad7643afaf';
    account_2 UUID := 'fd244313-36e5-4a17-a27c-f8265bc46590';
    transfer_amount NUMERIC := 50.75;
    out_amount NUMERIC := 731823.56;
BEGIN
    BEGIN        
        balance_1 := calcular_saldo(account_1);
        balance_2 := calcular_saldo(account_2);

        RAISE NOTICE 'Opening balance account 1: %, opening balance account 2: %', balance_1, balance_2;
        
        INSERT INTO movements (id, account_from, account_to, type, mount)
        VALUES (gen_random_uuid(), account_1, account_2, 'TRANSFER', transfer_amount);
        
        balance_1 := balance_1 - transfer_amount;
        balance_2 := balance_2 + transfer_amount;
        
        IF balance_2 < out_amount THEN
            RAISE EXCEPTION 'Insufficient balance to carry out the OUT type transaction. Balance available: %, amount required: %.', balance_2, out_amount;
        END IF;
        
        INSERT INTO movements (id, account_from, type, mount)
        VALUES (gen_random_uuid(), account_1, 'OUT', out_amount);
        
        balance_1 := calcular_saldo(account_1);
        balance_2 := calcular_saldo(account_2);

        RAISE NOTICE 'Movements inserted correctly. Closing balance account 1: %, closing balance account 2: %', balance_1, balance_2;

    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'Error: %', SQLERRM;
            RAISE;
    END;
END $$;

-- f. Once the transaction is correct, make a commit
-- Within the context of the DO block, PostgreSQL performs an implicit commit if the block completes successfully. If you want to make sure of an explicit commit

-- e. How much money the account `fd244313-36e5-4a17-a27c-f8265bc46590` have:
CREATE OR REPLACE FUNCTION get_user_balance(user_id_input UUID)
RETURNS NUMERIC AS $$
DECLARE
    total_balance NUMERIC;
BEGIN
    SELECT 
        SUM(
            CASE
                WHEN m.type = 'IN' OR (m.type IN ('TRANSFER', 'OTHER') AND m.account_to = a.id) THEN m.mount    
    			WHEN (m.type IN ('TRANSFER', 'OTHER') AND m.account_from = a.id) OR m.type = 'OUT' THEN -m.mount
                ELSE 0
            END
        ) + a.mount
    INTO total_balance
    FROM 
        accounts a
    LEFT JOIN 
    	movements m ON a.id IN (m.account_from, m.account_to)
    WHERE 
        a.user_id = user_id_input
    GROUP BY 
        a.user_id, a.mount;
 
    RETURN total_balance;
END;
$$ LANGUAGE plpgsql;


SELECT calcular_saldo('fd244313-36e5-4a17-a27c-f8265bc46590');

--------------------------------------------------------------------------------------------------------------

-- 6
SELECT 
    us.id AS user_id,
    us.name AS user_name,
	ac.id AS account_id,
    ac.type AS account_type,
    mov.id AS movement_id,
	mov.type AS movement_type,
    mov.mount,
    mov.account_from,
    mov.account_to
FROM 
    movements mov
INNER JOIN 
    accounts ac ON mov.account_from = ac.id OR mov.account_to = ac.id
INNER JOIN 
    users us ON ac.user_id = us.id
WHERE 
    mov.account_from = '3b79e403-c788-495a-a8ca-86ad7643afaf' 
    OR 
    mov.account_to = '3b79e403-c788-495a-a8ca-86ad7643afaf';

--------------------------------------------------------------------------------------------------------------

-- 7
SELECT 
	CONCAT (us.name, ' ', us.last_name),
	us.email
FROM accounts ac
INNER JOIN users us ON ac.user_id = us.id
GROUP BY ac.user_id, us.name, us.email, us.last_name
ORDER BY SUM(ac.mount) DESC
LIMIT 1;

--------------------------------------------------------------------------------------------------------------

-- 8
SELECT 
    mov.id AS movement_id,
    mov.type AS movement_type,
    mov.mount,
    mov.account_from,
    mov.account_to,
    mov.created_at
FROM 
    movements mov
INNER JOIN 
    accounts ac ON mov.account_from = ac.id OR mov.account_to = ac.id
INNER JOIN 
    users us ON ac.user_id = us.id
WHERE 
    us.email = 'Kaden.Gusikowski@gmail.com'
ORDER BY 
    ac.type,
    mov.created_at;
