-- Your answers here:
-- 1
SELECT type, SUM(mount) AS total
FROM  accounts
group by type
-- 2
SELECT count(u.name) as user_w_least_two_accounts
FROM users AS u
         INNER JOIN accounts AS a ON u.id = a.user_id
WHERE a.type = 'CURRENT_ACCOUNT'
HAVING count(a.id) >= 2;
-- 3
SELECT id, mount
FROM accounts
ORDER BY mount DESC
LIMIT 5;
-- 4
 DO
    $$
        DECLARE
            account_balance RECORD;
        BEGIN
            FOR account_balance IN
                WITH account_balances AS (SELECT u.name,
                                                a.account_id,
                                                a.mount        AS initial_mount,
                                                COALESCE(SUM(
                                                                CASE
                                                                    WHEN m.type = 'TRANSFER' AND m.account_from = a.id
                                                                        THEN -m.mount
                                                                    WHEN m.type = 'TRANSFER' AND m.account_to = a.id
                                                                        THEN m.mount
                                                                    WHEN m.type = 'IN' AND m.account_from = a.id
                                                                        THEN m.mount
                                                                    WHEN m.type = 'OUT' AND m.account_from = a.id
                                                                        THEN -m.mount
                                                                    WHEN m.type = 'OTHER' AND m.account_from = a.id
                                                                        THEN m.mount
                                                                    ELSE 0
                                                                    END
                                                        ), 0) AS movement_total
                                        FROM users AS u
                                                INNER JOIN accounts AS a ON u.id = a.user_id
                                                LEFT JOIN movements AS m ON a.id IN (m.account_from, m.account_to)
                                        GROUP BY u.id, u.name, a.account_id, a.mount)
                SELECT account_id,
                    (initial_mount + movement_total) AS updated_balance
                FROM account_balances

                LOOP
                    UPDATE accounts
                    SET mount = account_balance.updated_balance
                    WHERE account_id = account_balance.account_id;
                END LOOP;
        END
    $$;

    SELECT u.name || ' ' || u.last_name AS full_name, a.mount
    FROM users AS u
    INNER JOIN accounts AS a ON u.id = a.user_id
    ORDER BY a.mount DESC
    LIMIT 3;
-- 5
---A
SELECT id, mount
FROM accounts
WHERE accounts.id = '3b79e403-c788-495a-a8ca-86ad7643afaf' OR accounts.id = 'fd244313-36e5-4a17-a27c-f8265bc46590';
---B
DO
    $$
        DECLARE
            movement               RECORD;
            updated_account_record RECORD;
        BEGIN
            INSERT INTO movements(id, type, account_from, account_to, mount)
            VALUES (gen_random_uuid(),
                    'TRANSFER',
                    '3b79e403-c788-495a-a8ca-86ad7643afaf',
                    'fd244313-36e5-4a17-a27c-f8265bc46590',
                    50.75)
            RETURNING * INTO movement;

            IF (SELECT mount FROM accounts WHERE id = movement.account_from) < movement.mount THEN
                RAISE INFO 'Invalid movement: Insufficient balance in account %. Rolling back.', movement.account_from;
                ROLLBACK;
                RETURN;
            END IF;

            FOR updated_account_record IN
                UPDATE accounts
                    SET mount = CASE
                                    WHEN id = movement.account_from THEN mount - movement.mount
                                    WHEN id = movement.account_to THEN mount + movement.mount
                        END
                    WHERE id = movement.account_from
                        OR id = movement.account_to
                    RETURNING *
                LOOP
                    RAISE INFO 'Updated account %', updated_account_record.id;
                END LOOP;

            RAISE INFO 'Transaction successful';
            COMMIT;
        END
    $$;

---C
DO
    $$
        DECLARE
            record          RECORD;
            accounts_record RECORD;
        BEGIN
            INSERT INTO movements(id, type, account_from, account_to, mount)
            VALUES (gen_random_uuid(), 'OUT', '3b79e403-c788-495a-a8ca-86ad7643afaf', NULL, 731823.56)
            RETURNING * INTO record;

            UPDATE accounts
            SET mount = mount - record.mount
            WHERE id = record.account_from
            RETURNING * INTO accounts_record;

            IF accounts_record.mount < 0 THEN
                RAISE NOTICE 'Invalid movement: Insufficient balance in account %. Rolling back.', record.account_from;
                ROLLBACK;
                RETURN;
            END IF;

            RAISE NOTICE 'Transaction successful: Movement ID %, Account ID %, New Balance %.',
                record.id, accounts_record.id, accounts_record.mount;

            COMMIT;
        END
    $$;
---E
INSERT INTO movements(id, type, account_from, account_to, mount)
    VALUES (gen_random_uuid(), 'OUT', '3b79e403-c788-495a-a8ca-86ad7643afaf', NULL, 1000.05)
    RETURNING * INTO record;
---F
RAISE NOTICE 'Transaction successful: Movement ID %, Account ID %, New Balance %.',
        record.id, accounts_record.id, accounts_record.mount;
--- G
    SELECT id, mount
    FROM accounts
    WHERE id = 'fd244313-36e5-4a17-a27c-f8265bc46590';
    COMMIT;
-- 6
WITH user_info AS (SELECT u.id                         AS user_id,
                          u.name || ' ' || u.last_name AS fullname,
                          u.email,
                          u.date_joined,
                          a.id                         AS account_id
                   FROM users u
                            INNER JOIN accounts a ON u.id = a.user_id
                   WHERE a.id = '3b79e403-c788-495a-a8ca-86ad7643afaf')
SELECT ui.fullname,
       ui.email,
       ui.date_joined,
       m.type,
       m.account_from,
       m.account_to,
       m.mount
FROM user_info ui
         LEFT JOIN movements m
                   ON m.account_from = ui.account_id OR m.account_to = ui.account_id;
-- 7
WITH highest_account_mount AS (SELECT user_id, MAX(mount) AS max_mount
                               FROM accounts
                               GROUP BY user_id
                               ORDER BY max_mount DESC
                               LIMIT 1)

SELECT u.name || ' ' || u.last_name AS full_name,
       u.email,
       ham.max_mount                AS total_money
FROM users AS u
         INNER JOIN highest_account_mount AS ham ON u.id = ham.user_id;

-- 8
WITH user_info AS (SELECT u.id, u.email, a.id AS account_id
                   FROM users AS u
                            INNER JOIN accounts AS a ON u.id = a.user_id
                   WHERE u.email = 'Kaden.Gusikowski@gmail.com')
SELECT DISTINCT ui.email,
                m.id AS id_movement,
                m.type,
                m.account_from,
                m.account_to,
                m.mount,
                m.created_at
FROM movements m
         INNER JOIN user_info ui ON m.account_from = ui.account_id OR m.account_to = ui.account_id
ORDER BY m.type, m.created_at;