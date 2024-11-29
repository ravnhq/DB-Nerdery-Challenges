-- 1 Total money of all the accounts group by types.
SELECT
  a.type,
  SUM(a.mount)
FROM
  accounts a
GROUP BY
  a.type;

-- 2 How many users with at least 2 CURRENT_ACCOUNT.
SELECT
  COUNT(u.*)
FROM
  accounts ac
  INNER JOIN public.users u ON u.id = ac.user_id
WHERE
  ac.type = 'CURRENT_ACCOUNT'
GROUP BY
  ac.type;

-- 3 List the top five accounts with more money.
SELECT
  a.account_id
FROM
  accounts a
ORDER BY
  a.mount DESC
LIMIT
  5;

-- 4 Get the three users with the most money after making movements.
WITH account_movements AS (
  SELECT
    a.user_id,
    a.id AS account_id,
    a.mount AS initial_balance,
    SUM(
      CASE
        WHEN m.type = 'IN' THEN m.mount
        WHEN m.type = 'OUT' THEN - m.mount
        WHEN m.type = 'TRANSFER' THEN CASE
          WHEN m.account_from = a.id THEN - m.mount
          WHEN m.account_to = a.id THEN m.mount
          ELSE 0
        END
        WHEN m.type = 'OTHER' THEN - m.mount
        ELSE 0
      END
    ) AS total_movements
  FROM
    public.accounts a
    LEFT JOIN public.movements m ON a.id = m.account_from
    OR a.id = m.account_to
  GROUP BY
    a.user_id,
    a.id,
    a.mount
),
user_balances AS (
  SELECT
    u.id AS user_id,
    u.name,
    u.last_name,
    SUM(am.initial_balance + am.total_movements) AS total_balance
  FROM
    public.users u
    JOIN account_movements am ON u.id = am.user_id
  GROUP BY
    u.id,
    u.name,
    u.last_name
)
SELECT
  user_id,
  name,
  last_name,
  ROUND(total_balance :: numeric, 2) AS total_balance
FROM
  user_balances
ORDER BY
  total_balance DESC
LIMIT
  3;

-- 5 In this part you need to create a transaction with the following steps:
-- a First,
-- get the ammount for the account 3b79e403 - c788 - 495a - a8ca - 86ad7643afaf and fd244313 - 36e5 - 4a17 - a27c - f8265bc46590 after all their movements.
CREATE
OR REPLACE FUNCTION calculate_account_balance(p_account_id UUID) RETURNS TABLE (
  account_id UUID,
  initial_balance DOUBLE PRECISION,
  total_movements DOUBLE PRECISION,
  final_balance DOUBLE PRECISION
)
LANGUAGE plpgsql
AS $ $
DECLARE
  v_initial_balance DOUBLE PRECISION;
BEGIN -- Get the initial account balance
SELECT
  mount INTO v_initial_balance
FROM
  public.accounts
WHERE
  id = p_account_id;

-- Return the balance calculation
RETURN QUERY WITH account_movements AS (
  SELECT
    SUM(
      CASE
        WHEN type = 'IN' THEN mount
        WHEN type = 'OUT' THEN - mount
        WHEN type = 'OTHER' THEN - mount
        WHEN type = 'TRANSFER' THEN CASE
          WHEN account_from = p_account_id THEN - mount
          WHEN account_to = p_account_id THEN mount
          ELSE 0
        END
        ELSE 0
      END
    ) AS total_movement
  FROM
    public.movements
  WHERE
    account_from = p_account_id
    OR account_to = p_account_id
)
SELECT
  p_account_id AS account_id,
  v_initial_balance AS initial_balance,
  COALESCE(
    (
      SELECT
        total_movement
      FROM
        account_movements
    ),
    0
  ) AS total_movements,
  v_initial_balance + COALESCE(
    (
      SELECT
        total_movement
      FROM
        account_movements
    ),
    0
  ) AS final_balance;

END;
$$;

SELECT
  *
FROM
  calculate_account_balance('3b79e403-c788-495a-a8ca-86ad7643afaf')
UNION
SELECT
  *
FROM
  calculate_account_balance('fd244313-36e5-4a17-a27c-f8265bc46590');

-- b. Add a new movement with the information:
-- from : 3b79e403-c788-495a-a8ca-86ad7643afaf make a transfer to fd244313-36e5-4a17-a27c-f8265bc46590 mount: 50.75
CREATE
OR REPLACE FUNCTION create_transfer_movement(
  p_account_from UUID,
  p_account_to UUID,
  p_amount DOUBLE PRECISION
) RETURNS UUID LANGUAGE plpgsql AS $ $ DECLARE v_movement_id UUID;

v_from_balance DOUBLE PRECISION;

v_from_account_exists BOOLEAN;

v_to_account_exists BOOLEAN;

BEGIN --  Validate input amount
IF p_amount <= 0 THEN RAISE EXCEPTION 'Transfer amount should be positive';

END IF;

-- Validate if both accounts exist
SELECT
  EXISTS(
    SELECT
      1
    FROM
      public.accounts
    WHERE
      id = p_account_from
  ) INTO v_from_account_exists;

SELECT
  EXISTS(
    SELECT
      1
    FROM
      public.accounts
    WHERE
      id = p_account_to
  ) INTO v_to_account_exists;

IF NOT v_from_account_exists
OR NOT v_to_account_exists THEN RAISE EXCEPTION 'One or both accounts do not exist';

END IF;

-- Check sufficient balance in the source account
SELECT
  mount INTO v_from_balance
FROM
  public.accounts
WHERE
  id = p_account_from;

IF v_from_balance < p_amount THEN RAISE EXCEPTION 'Insufficient balance in the source account';

END IF;

v_movement_id := gen_random_uuid();

-- Insert the transfer movement
INSERT INTO
  public.movements (id, type, account_from, account_to, mount)
VALUES
  (
    v_movement_id,
    'TRANSFER',
    p_account_from,
    p_account_to
  );

-- Update source account balance
UPDATE
  public.accounts
SET
  mount = mount - p_amount
WHERE
  id = p_account_from;

-- Update destination account balance
UPDATE
  public.accounts
SET
  mount = mount + p_amount
WHERE
  id = p_account_to;

return v_movement_id;

END;

$ $;

SELECT
  create_transfer_movement(
    '3b79e403-c788-495a-a8ca-86ad7643afaf',
    'fd244313-36e5-4a17-a27c-f8265bc46590',
    50.75
  );
-- c Add a new movement with the information:
--   from:
--   3b79e403 - c788 - 495a - a8ca - 86ad7643afaf type: OUT mount: 731823.56
CREATE
OR REPLACE FUNCTION create_out_movement(
  p_account_from UUID,
  p_amount DOUBLE PRECISION
) RETURNS UUID LANGUAGE plpgsql AS $ $ DECLARE v_movement_id UUID;

v_from_balance DOUBLE PRECISION;

v_from_account_exists BOOLEAN;

BEGIN -- Validate input amount
IF p_amount <= 0 THEN RAISE EXCEPTION 'Out movement amount must be positive';

END IF;

-- Check if account exists
SELECT
  EXISTS(
    SELECT
      1
    FROM
      public.accounts
    WHERE
      id = p_account_from
  ) INTO v_from_account_exists;

IF NOT v_from_account_exists THEN RAISE EXCEPTION 'Source account does not exist';

END IF;

-- Check sufficient balance in the source account
SELECT
  mount INTO v_from_balance
FROM
  public.accounts
WHERE
  id = p_account_from;

-- POINT 7: I'm rejecting and make the rollback after throw this exception
IF v_from_balance < p_amount THEN RAISE EXCEPTION 'Insufficient balance: requested % but account has %',
p_amount,
v_from_balance;

END IF;

-- Generate new movement ID
v_movement_id := gen_random_uuid();

-- Start a transaction
BEGIN;

-- Insert the OUT movement
INSERT INTO
  public.movements (
    id,
    type,
    account_from,
    mount
  )
VALUES
  (
    v_movement_id,
    'OUT',
    p_account_from,
    p_amount
  );

-- Update source account balance
UPDATE
  public.accounts
SET
  mount = mount - p_amount
WHERE
  id = p_account_from;

-- Commit the transaction
COMMIT;

RETURN v_movement_id;

EXCEPTION
WHEN OTHERS THEN ROLLBACK;

RAISE EXCEPTION 'Transaction failed: %',
SQLERRM;

END;

END;

$ $;
-- d Put your answer here if the transaction fails(YES / NO):

-- NO, Will fail if I haven't the enough money to withdraw('OUT)
SELECT
  create_out_movement(
    '3b79e403-c788-495a-a8ca-86ad7643afaf',
    731823.56
  );

SELECT
  create_out_movement('3b79e403-c788-495a-a8ca-86ad7643afaf', 928.56);
-- e If the transaction fails, make the correction on step c to avoid the failure:
-- I need to create a transfer to have enough money to make a withdrawal operation
-- f Once the transaction is correct, make a commit
-- The commit is already defined in my function
-- g How much money the account fd244313-36e5-4a17-a27c-f8265bc46590 have:
CREATE
OR REPLACE FUNCTION get_account_balance(p_account_id UUID) RETURNS DOUBLE PRECISION LANGUAGE plpgsql AS $ $ DECLARE v_balance DOUBLE PRECISION;

BEGIN
SELECT
  mount INTO v_balance
FROM
  public.accounts
WHERE
  id = p_account_id;

RETURN v_balance;

END;

$ $;

SELECT
  get_account_balance('fd244313-36e5-4a17-a27c-f8265bc46590');

-- 6 All the movements and the user information with the account 3b79e403-c788-495a-a8ca-86ad7643afaf
SELECT
  u.name,
  u.email,
  a.id AS account_id,
  m.type,
  m.mount
FROM
  users u
  LEFT JOIN accounts a ON a.user_id = u.id
  LEFT JOIN movements m ON m.account_from = a.id
  OR m.account_to = a.id
WHERE
  a.id = '3b79e403-c788-495a-a8ca-86ad7643afaf';

-- 7 The name and email of the user with the highest money in all his / her accounts
SELECT
  u.name,
  u.email,
  SUM(a.mount) AS total
FROM
  users u
  INNER JOIN accounts a ON u.id = a.user_id
GROUP BY
  u.name,
  u.email
ORDER BY
  total DESC
LIMIT
  1;

-- 8 Show all the movements for the user Kaden.Gusikowski @gmail.com order by account type and created_at on the movements table
SELECT
  u.email,
  a.account_id,
  m.type,
  m.mount,
  m.created_at
FROM
  users u
  INNER JOIN accounts a ON a.user_id = u.id
  INNER JOIN movements m ON m.account_from = a.id
WHERE
  u.email = 'Kaden.Gusikowski@gmail.com';
