-- Your answers here:
-- 1
SELECT type, SUM(mount) total_money FROM accounts GROUP BY type;
-- 2
SELECT COUNT(count) users_with_at_least_two_current_acounts FROM (
    SELECT COUNT(user_id) count FROM accounts
        WHERE type = 'CURRENT_ACCOUNT'
        GROUP BY user_id
        HAVING COUNT(user_id) > 1
) AS match_users;
-- 3
SELECT id, type, user_id, mount FROM accounts ORDER BY mount DESC LIMIT 5;
-- 4
SELECT account_user_id, user_name, total_mount, (total_mount + SUM(final_mount)) final_mount
    FROM (
        SELECT u.id account_user_id, u.name user_name,
            CASE
                WHEN m.account_to = a.id THEN m.mount
                WHEN m.type IN ('TRANSFER', 'OUT', 'OTHER') THEN m.mount * -1
                ELSE m.mount
            END final_mount
        FROM users u
            JOIN accounts a on u.id = a.user_id
            JOIN movements m on a.id = m.account_from OR a.id = m.account_to
    ) AS accounts_with_movements
    JOIN (
        SELECT user_id, SUM(mount) total_mount FROM accounts GROUP BY user_id
    ) AS total_accounts_mounts ON total_accounts_mounts.user_id = account_user_id
    GROUP BY account_user_id, user_name, total_mount
    ORDER BY final_mount DESC
    LIMIT 3;
-- 5
BEGIN TRANSACTION;
    --- a.
    CREATE FUNCTION get_account_final_mount(param_account_id uuid)
        RETURNS DOUBLE PRECISION
        LANGUAGE plpgsql
        AS $$
            DECLARE var_final_mount DOUBLE PRECISION;
            BEGIN
                SELECT (total_mount + SUM(final_mount)) final_mount INTO var_final_mount
                    FROM (
                        SELECT a.id account_id, u.name  user_name,
                            CASE
                                WHEN m.account_to = a.id THEN m.mount
                                WHEN m.type IN ('TRANSFER', 'OUT', 'OTHER') THEN m.mount * -1
                                ELSE m.mount
                            END final_mount
                        FROM users u
                            JOIN accounts a on u.id = a.user_id
                            JOIN movements m on a.id = m.account_from OR a.id = m.account_to
                            WHERE a.id = param_account_id
                    ) AS accounts_with_movements
                        JOIN (
                             SELECT id, SUM(mount) total_mount FROM accounts GROUP BY id
                        ) AS total_accounts_mounts ON total_accounts_mounts.id = account_id
                    GROUP BY account_id, user_name, total_mount
                    ORDER BY final_mount DESC;
                RETURN var_final_mount;
            END
        $$;
    SELECT get_account_final_mount('3b79e403-c788-495a-a8ca-86ad7643afaf') user_a_final_mount,
           get_account_final_mount('fd244313-36e5-4a17-a27c-f8265bc46590') user_b_final_mount;
    --- b.
    INSERT INTO movements (id, type, account_from, account_to, mount)
        VALUES (gen_random_uuid(), 'TRANSFER', '3b79e403-c788-495a-a8ca-86ad7643afaf', 'fd244313-36e5-4a17-a27c-f8265bc46590', 50.75);
    --- c.
    DO $$
        DECLARE
            user_a_mount DOUBLE PRECISION;
        BEGIN
            SELECT get_account_final_mount('3b79e403-c788-495a-a8ca-86ad7643afaf') INTO user_a_mount;
            IF user_a_mount >= 731823.56
                THEN
                    INSERT INTO movements (id, type, account_from, account_to, mount)
                        VALUES (gen_random_uuid(), 'OUT', '3b79e403-c788-495a-a8ca-86ad7643afaf', null, 731823.56);
                ELSE
                    --- d.
                    BEGIN
                        RAISE EXCEPTION 'Operation failed - Insufficient amount';
                    --- e.
                    EXCEPTION
                        WHEN OTHERS THEN
                            RAISE;
                    END;
            END IF;
        END
    $$;
--- f.
COMMIT TRANSACTION;
--- e.
SELECT get_account_final_mount('fd244313-36e5-4a17-a27c-f8265bc46590') user_b_current_mount;

-- 6
SELECT
    u.id user_id, u.name || ' ' || u.last_name user_fullname, u.email user_email,
    a.id user_accound_id,
    m.id movement_id, m.type movement_type, m.account_from, m.account_to, m.mount movement_mount
FROM accounts a
    JOIN users u on u.id = a.user_id
    JOIN movements m on a.id = m.account_from OR a.id = m.account_to
    WHERE a.id = '3b79e403-c788-495a-a8ca-86ad7643afaf';
-- 7
SELECT u.name, u.email FROM accounts a
    JOIN users u on u.id = a.user_id
    GROUP BY u.name, u.email
    ORDER BY SUM(a.mount) DESC
    LIMIT 1;
-- 8
SELECT
    u.email user_email,
    a.type account_type,
    m.id movement_id, m.type movement_type, m.created_at movement_created_at
FROM users u
    JOIN accounts a on u.id = a.user_id
    JOIN movements m on a.id = m.account_from OR a.id = m.account_to
    WHERE u.email = 'Kaden.Gusikowski@gmail.com'
    ORDER BY a.type, m.created_at;