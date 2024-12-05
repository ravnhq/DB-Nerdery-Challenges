-- Your answers here:
-- 1
--
SELECT
	TYPE ACCOUNT_TYPE,
	ROUND(SUM(MOUNT)::NUMERIC, 2) MONEY_SUM
FROM
	ACCOUNTS
GROUP BY
	TYPE;

--
--
--
--
-- 2
--
SELECT
	COUNT(*) AS COUNT_USER_AT_LEAST_2_CURRENT_ACCOUNT
FROM
	(
		SELECT
			U.ID
		FROM
			USERS U
			INNER JOIN ACCOUNTS A ON U.ID = A.USER_ID
		WHERE
			A.TYPE = 'CURRENT_ACCOUNT'
		GROUP BY
			U.ID
		HAVING
			COUNT(U.ID) > 1
	);

--
--
--
--
--
-- 3
--
SELECT
	ID,
	ACCOUNT_ID,
	TYPE,
	MOUNT
FROM
	ACCOUNTS
ORDER BY
	MOUNT DESC
LIMIT
	5;

--
--
--
--
-- 4
-- I MAKE SURE I USE EVERY ACCOUNT BY UNION ALL!
-- INNER JOIN MAY LEAVE OUT USERS WITH NO MOVEMENTS
CREATE
OR REPLACE FUNCTION GET_ACCOUNTS_FINAL_BALANCE () RETURNS TABLE (ACCOUNT_ID UUID, MONEY NUMERIC(15, 2)) AS $$ BEGIN RETURN QUERY WITH accounts_money_movements AS (
        (
            -- account_from transactions
            SELECT account_from AS account_id,
                CASE
                    WHEN type = 'IN' THEN mount
                    ELSE mount * -1
                END AS mount
            FROM movements
        )
        UNION ALL
        (
            -- account_to transactions
            SELECT CASE
                    WHEN type = 'TRANSFER' THEN account_to
                    ELSE account_from
                END AS account_id,
                CASE
                    WHEN type = 'TRANSFER' THEN mount
                    ELSE 0
                END AS mount
            FROM movements
        )
        UNION ALL
        (
            -- accounts starting money
            SELECT id AS account_id,
                mount
            FROM accounts
        )
    )
SELECT am.account_id,
    ROUND(SUM(am.mount)::NUMERIC, 2) AS money
FROM accounts_money_movements am
GROUP BY am.account_id;
END;
$$ LANGUAGE PLPGSQL;

--
-- Solution applying function  get_accounts_final_balance
--
SELECT
	U.ID,
	U.NAME,
	SUM(AB.MONEY) ALL_MONEY
FROM
	GET_ACCOUNTS_FINAL_BALANCE () AB
	INNER JOIN ACCOUNTS A ON AB.ACCOUNT_ID = A.ID
	INNER JOIN USERS U ON U.ID = A.USER_ID
GROUP BY
	U.ID,
	U.NAME
ORDER BY ALL_MONEY DESC
LIMIT 3;

--
--
--
-- 5
--
DO $$
DECLARE
    account_balance_a DOUBLE PRECISION;
    account_balance_b DOUBLE PRECISION;
	
    account_id_a UUID := '3b79e403-c788-495a-a8ca-86ad7643afaf';
    account_id_b UUID := 'fd244313-36e5-4a17-a27c-f8265bc46590';

	transfer_mount DOUBLE PRECISION := 50.75;
	out_mount DOUBLE PRECISION := 20;
BEGIN

	--a. First, get the ammount for the account `3b79e403-c788-495a-a8ca-86ad7643afaf` and `fd244313-36e5-4a17-a27c-f8265bc46590` after all their movements.
	
	SELECT money into account_balance_a
	FROM get_accounts_final_balance() 
	WHERE account_id = account_id_a;

	SELECT money into account_balance_b
	FROM get_accounts_final_balance() 
	WHERE account_id = account_id_b;

	RAISE NOTICE 'Account balance from % is %', account_id_a, account_balance_a;
	RAISE NOTICE 'Account balance from % is %', account_id_b, account_balance_b;

	--b. Add a new movement with the information: from: 3b79e403-c788-495a-a8ca-86ad7643afaf make a transfer to fd244313-36e5-4a17-a27c-f8265bc46590 mount: 50.75
	IF account_balance_a < transfer_mount THEN
		RAISE EXCEPTION 'Account balance is insufficient!';
	ELSE 
		INSERT INTO movements  (id, type, account_from, account_to, mount) 
		VALUES (gen_random_uuid(), 'TRANSFER', account_id_a,account_id_b, transfer_mount);
		RAISE NOTICE 'Transfer % USD from % to % MADE SUCCESSFULLY!', transfer_mount, account_id_a, account_id_b;
	END IF;

	--c. Add a new movement with the information: from: 3b79e403-c788-495a-a8ca-86ad7643afaf type: OUT mount: 731823.56

	SELECT money into account_balance_a
	FROM get_accounts_final_balance() 
	WHERE account_id = account_id_a;
	
	IF account_balance_a < out_mount THEN
		RAISE EXCEPTION 'Account balance is insufficient!';
	ELSE 
		INSERT INTO movements  (id, type, account_from, account_to, mount) 
		VALUES (gen_random_uuid(), 'OUT', account_id_a,account_id_b , out_mount);
		RAISE NOTICE 'Movement OUT % USD from % MADE SUCCESSFULLY!', out_mount, account_id_a;
	END IF;

	--f. Once the transaction is correct, make a commit

	SELECT money into account_balance_b
	FROM get_accounts_final_balance() 
	WHERE account_id = account_id_b;

	RAISE NOTICE 'Account balance from % is %', account_id_b, account_balance_b;
	

	RAISE NOTICE 'Transaction finished ok!';

EXCEPTION
--e. If the transaction fails, make the correction on step c to avoid the failure:


    WHEN OTHERS THEN
        RAISE NOTICE 'Transfer failed. Error: %', SQLERRM;
		ROLLBACK;
		RAISE NOTICE 'ROLLBACK!';

END;
$$;

--
--
--
--
--6. All the movements and the user information with the account 3b79e403-c788-495a-a8ca-86ad7643afaf
--
SELECT
	*
FROM
	USERS U
	INNER JOIN ACCOUNTS A ON U.ID = A.USER_ID
	INNER JOIN MOVEMENTS M ON M.ACCOUNT_FROM = A.ID
	OR M.ACCOUNT_TO = A.ID
WHERE
	A.ID = '3b79e403-c788-495a-a8ca-86ad7643afaf';

--
--
--
--
-- 7. The name and email of the user with the highest money in all his/her accounts
--
SELECT
	U.NAME,
	U.EMAIL,
	SUM(AB.MONEY) MONEY_BALANCE
FROM
	GET_ACCOUNTS_FINAL_BALANCE () AB
	INNER JOIN ACCOUNTS A ON A.ID = AB.ACCOUNT_ID
	INNER JOIN USERS U ON U.ID = A.USER_ID
GROUP BY
	U.NAME,
	U.EMAIL
ORDER BY
	MONEY_BALANCE DESC
LIMIT
	1;

--
--
--
--
-- 8. Show all the movements for the user Kaden.Gusikowski@gmail.com order by account type and created_at on the movements table
--
SELECT
	U.EMAIL,
	A.ID AS ACCOUNT_ID,
	A.TYPE ACCOUNT_TYPE,
	M.ID MOVEMENT_ID,
	M.TYPE MOVEMENT_TYPE,
	M.ACCOUNT_FROM,
	M.ACCOUNT_TO,
	M.MOUNT,
	M.CREATED_AT
FROM
	USERS U
	INNER JOIN ACCOUNTS A ON U.ID = A.USER_ID
	INNER JOIN MOVEMENTS M ON M.ACCOUNT_FROM = A.ID
	OR M.ACCOUNT_TO = A.ID
WHERE	U.EMAIL = 'Kaden.Gusikowski@gmail.com'
ORDER BY	A.TYPE,	M.CREATED_AT;