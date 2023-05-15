-- Your answers here:
-- 1
SELECT A.type, SUM(A.mount)
FROM accounts A
    GROUP BY A.type;

-- 2
WITH current_accounts_count AS (
    SELECT COUNT(*) AS id_count
    FROM users A
    INNER JOIN accounts B ON A.id = B.user_id
    WHERE B.type = 'CURRENT_ACCOUNT'
    GROUP BY A.id
    HAVING COUNT(*) > 1
)
SELECT COUNT(*) AS users_with_at_least_two
FROM current_accounts_count;

-- 3
SELECT A.user_id, A.type, A.mount
FROM accounts A
    ORDER BY A.mount DESC
    LIMIT 5;

-- 4
WITH accounts_funds AS (
    SELECT A.id,
           sum(B.mount) AS accounts_total
    FROM users A
    INNER JOIN accounts B ON A.id = B.user_id
    GROUP BY A.id
),
movements_funds AS (
    SELECT  A.id,
            CONCAT(A.name, ' ', A.last_name) AS full_name,
            SUM(
               CASE
                   WHEN C.account_to = B.id THEN C.mount
                   WHEN C.type = 'OTHER' OR
                        C.type = 'TRANSFER' OR
                        C.type = 'OUT' THEN -1 * C.mount
                   ELSE C.mount
               END) AS movements_total
    FROM users A
    INNER JOIN accounts B ON A.id = B.user_id
    INNER JOIN movements C ON B.id = C.account_from OR B.id = C.account_to
    GROUP BY A.name, A.last_name, A.id
)
SELECT A.id,
       A.full_name,
       A.movements_total,
       B.accounts_total,
       (B.accounts_total + A.movements_total) AS total_after_mov
FROM movements_funds A
INNER JOIN accounts_funds B ON B.id = A.id
GROUP BY A.id, A.full_name, A.movements_total, B.accounts_total
ORDER BY total_after_mov DESC LIMIT 3;

-- 5

BEGIN;

CREATE FUNCTION final_ammount_from(s_account_id UUID) RETURNS DOUBLE PRECISION
LANGUAGE plpgsql AS
$$
    DECLARE result DOUBLE PRECISION;
    BEGIN
        WITH accounts_funds AS (
            SELECT A.id,
                   sum(B.mount) AS accounts_total
            FROM users A
            INNER JOIN accounts B ON A.id = B.user_id
            WHERE A.id = s_account_id
            GROUP BY A.id
        ),
        movements_funds AS (
            SELECT  A.id,
                    CONCAT(A.name, ' ', A.last_name) AS full_name,
                    SUM(
                       CASE
                           WHEN C.account_to = B.id THEN C.mount
                           WHEN C.type = 'OTHER' OR
                                C.type = 'TRANSFER' OR
                                C.type = 'OUT' THEN -1 * C.mount
                           ELSE C.mount
                       END) AS movements_total
            FROM users A
            INNER JOIN accounts B ON A.id = B.user_id
            INNER JOIN movements C ON B.id = C.account_from OR B.id = C.account_to
            WHERE B.id = s_account_id
            GROUP BY A.name, A.last_name, A.id
        )
        SELECT A.id,
               A.full_name,
               A.movements_total,
               B.accounts_total,
               (B.accounts_total + A.movements_total) AS total_after_mov
        INTO result
        FROM movements_funds A
        INNER JOIN accounts_funds B ON B.id = A.id
        GROUP BY A.id, A.full_name, A.movements_total, B.accounts_total
        ORDER BY total_after_mov DESC;

        RETURN result;
    END;
$$;
-- a
SELECT final_ammount_from('3b79e403-c788-495a-a8ca-86ad7643afaf') as first_user,
       final_ammount_from('fd244313-36e5-4a17-a27c-f8265bc46590') as second_user;
-- b
INSERT INTO movements (id, type, account_from, account_to, mount)
VALUES (gen_random_uuid(), 'TRANSFER', '3b79e403-c788-495a-a8ca-86ad7643afaf', 'fd244313-36e5-4a17-a27c-f8265bc46590', 50.75);
-- c
DO $$
    DECLARE
        usr_acc_mount DOUBLE PRECISION;
    BEGIN
        SELECT final_ammount_from('3b79e403-c788-495a-a8ca-86ad7643afaf') INTO usr_acc_mount;
        IF usr_acc_mount >= 731823.56
            THEN
                INSERT INTO movements (id, account_from, account_to, type, mount)
                    VALUES (gen_random_uuid(), '3b79e403-c788-495a-a8ca-86ad7643afaf', null, 'OUT', 731823.56);
            ELSE
-- d
                BEGIN
                    RAISE EXCEPTION 'Not enough money';
-- e
                EXCEPTION
                    WHEN OTHERS THEN RAISE;
                END;
        END IF;
    END
$$;
-- f
COMMIT;
-- e
SELECT final_ammount_from('fd244313-36e5-4a17-a27c-f8265bc46590') as second_user_final;

-- 6
SELECT * FROM movements A
    INNER JOIN accounts B ON B.id = A.account_from
    INNER JOIN users C ON B.user_id = C.id
    WHERE B.id = '3b79e403-c788-495a-a8ca-86ad7643afaf';

-- 7
SELECT A.name,
       A.email,
       sum(B.mount) AS total_funds
FROM users A
INNER JOIN accounts B ON A.id = B.user_id
GROUP BY A.id, A.name, A.email
ORDER BY total_funds DESC LIMIT 1;

-- 8
SELECT * FROM movements A
    INNER JOIN accounts B ON A.account_from = B.id
    INNER JOIN users C ON B.user_id = C.id
    WHERE C.email = 'Kaden.Gusikowski@gmail.com'
    ORDER BY B.type, B.created_at;
