-- Challenge 2

----- UTIL FUNCTIONS
CREATE OR REPLACE FUNCTION get_account_by_id(_account_id UUID)
    RETURNS RECORD
    LANGUAGE plpgsql
AS $$
DECLARE
    account RECORD;
BEGIN
    SELECT *
    INTO account
    FROM accounts AS a
    WHERE a.id = _account_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Account not found [account_id=%]', _account_id;
    END IF;

    RETURN account;
END;
$$;

CREATE OR REPLACE FUNCTION update_account(_account_id UUID, _mount DOUBLE PRECISION)
    RETURNS VOID
    LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE accounts
    SET
        mount = COALESCE(_mount, mount)
    WHERE id = _account_id;
END;
$$;
----- UTIL FUNCTIONS

-- Exercise 1
SELECT
    a.type AS type,
    SUM(a.mount) AS mount
FROM accounts AS a
GROUP BY a.type;

-- Exercise 2
WITH user_accounts_count AS (
    SELECT
        u.id AS id,
        COUNT(*) AS accounts_count
    FROM users AS u
        LEFT JOIN accounts AS a
            ON u.id = a.user_id
    WHERE a.type = 'CURRENT_ACCOUNT'
    GROUP BY u.id
    HAVING COUNT(*) >= 2
)

SELECT COUNT(*)
FROM user_accounts_count;

-- Exercise 3
SELECT
    a.id AS id,
    a.type AS type,
    SUM(a.mount) as total_amount
FROM accounts AS a
GROUP BY a.id, a.type
ORDER BY total_amount DESC
LIMIT 5;

-- Exercise 4
WITH account_movements AS (
    SELECT
        m.account_from AS account,
        m.type,
        CASE
            WHEN type = 'IN'
                THEN m.mount
            WHEN type IN ('OUT', 'TRANSFER', 'OTHER')
                THEN -1 * m.mount
            ELSE 0
        END AS amount
    FROM movements AS m
    WHERE m.type IN ('IN', 'OUT', 'TRANSFER', 'OTHER')

    UNION ALL

    SELECT
        m.account_to AS account,
        m.type,
        CASE
            WHEN type = 'TRANSFER'
                THEN m.mount
            ELSE 0
        END AS amount
    FROM movements AS m
    WHERE m.type = 'TRANSFER'
),
account_aggregated AS (
    SELECT
        am.account AS account_id,
        SUM(am.amount) AS total_movements
    FROM account_movements AS am
    GROUP BY am.account
)

UPDATE accounts AS a
SET
    mount = a.mount + aa.total_movements
FROM account_aggregated AS aa
WHERE a.id = aa.account_id;

SELECT
    u.id,
    u.name,
    SUM(a.mount) AS amount
FROM users AS u
    INNER JOIN accounts AS a
        ON u.id = a.user_id
GROUP BY u.id, u.name
ORDER BY amount DESC
LIMIT 3;

-- Exercise 5
CREATE OR REPLACE FUNCTION handle_new_movement()
    RETURNS TRIGGER
    LANGUAGE plpgsql
AS $$
DECLARE
    origin_account RECORD;
    target_account RECORD;
    amount DOUBLE PRECISION;
BEGIN
    amount := NEW.mount;
    origin_account := get_account_by_id(NEW.account_from);

    IF NEW.type IN ('TRANSFER') THEN
        IF NEW.account_to IS NULL THEN
            RAISE EXCEPTION 'A target account is required [type_movement=%]', NEW.type;
        END IF;

        target_account := get_account_by_id(NEW.account_to);
    END IF;

    IF NEW.type IN ('OUT', 'TRANSFER', 'OTHER') THEN
        IF origin_account.mount < NEW.mount THEN
            RAISE EXCEPTION 'Insufficient funds [origin_account_founds=%][required_amount=%]', origin_account.mount, amount;
        END IF;

        amount := -1 * amount;
    END IF;

    PERFORM update_account(NEW.account_from,  origin_account.mount + amount);
    IF NEW.account_to IS NOT NULL THEN
        PERFORM update_account(NEW.account_to,  target_account.mount + ABS(amount));
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER after_insert_movement
AFTER INSERT ON movements
FOR EACH ROW
EXECUTE FUNCTION handle_new_movement();

-- Exercise 6
SELECT
    u.*,
    json_agg(mv) AS movements
FROM users AS u
    INNER JOIN accounts AS ac
        ON ac.user_id = u.id
    LEFT JOIN movements AS mv
        ON mv.account_from = ac.id
WHERE ac.id = '3b79e403-c788-495a-a8ca-86ad7643afaf'
GROUP BY u.id;

-- Exercise 7
SELECT
    u.name,
    u.email
FROM users AS u
    JOIN accounts AS a
        ON u.id = a.user_id
WHERE a.mount = (
    SELECT MAX(max_mount)
    FROM (
        SELECT MAX(a.mount) AS max_mount
        FROM accounts AS a
        GROUP BY a.user_id
    ) AS subquery
);

-- Exercise 8
SELECT
    mv.*
FROM users AS u
    INNER JOIN accounts AS a
        ON u.id = a.user_id
    INNER JOIN movements AS mv
        ON mv.account_from = a.id
WHERE u.email = 'Kaden.Gusikowski@gmail.com'
ORDER BY mv.type, mv.created_at;
