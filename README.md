<p align="center" style="background-color:white">
 <a href="https://www.ravn.co/" rel="noopener">
 <img src="src/ravn_logo.png" alt="RAVN logo" width="150px"></a>
</p>
<p align="center">
 <a href="https://www.postgresql.org/" rel="noopener">
 <img src="https://www.postgresql.org/media/img/about/press/elephant.png" alt="Postgres logo" width="150px"></a>
</p>

---

<p align="center">A project to show off your skills on databases & SQL using a real database</p>

## 📝 Table of Contents

- [Case](#case)
- [Installation](#installation)
- [Data Recovery](#data_recovery)
- [Excersises](#excersises)

## 🤓 Case <a name = "case"></a>

As a developer and expert on SQL, you were contacted by a company that needs your help to manage their database which runs on PostgreSQL. The database provided contains four entities: Employee, Office, Countries and States. The company has different headquarters in various places around the world, in turn, each headquarters has a group of employees of which it is hierarchically organized and each employee may have a supervisor. You are also provided with the following Entity Relationship Diagram (ERD)

#### ERD - Diagram <br>

![Comparison](src/ERD.png) <br>

---

## 🛠️ Docker Installation <a name = "installation"></a>

1. Install [docker](https://docs.docker.com/engine/install/)

---

## 📚 Recover the data to your machine <a name = "data_recovery"></a>

Open your terminal and run the follows commands:

1. This will create a container for postgresql:

```
docker run --name nerdery-container -e POSTGRES_PASSWORD=password123 -p 5432:5432 -d --rm postgres:15.2
```

2. Now, we access the container:

```
docker exec -it -u postgres nerdery-container psql
```

3. Create the database:

```
create database nerdery_challenge;
```

5. Close the database connection:
```
\q
```

4. Restore de postgres backup file

```
cat /.../dump.sql | docker exec -i nerdery-container psql -U postgres -d nerdery_challenge
```

- Note: The `...` mean the location where the src folder is located on your computer
- Your data is now on your database to use for the challenge

---

## 📊 Excersises <a name = "excersises"></a>

Now it's your turn to write SQL queries to achieve the following results (You need to write the query in the section `Your query here` on each question):

1. Total money of all the accounts group by types.

```
select a.type, sum(mount) from accounts a group by a.type 
```


2. How many users with at least 2 `CURRENT_ACCOUNT`.

```
select u.name, u.id, count(a.id) count from users u left join accounts a on u.id = a.user_id  group by u.id having count(a.id) > 1
```


3. List the top five accounts with more money.

```
select a.id, a.mount from accounts a order by a.mount desc limit 5;
```


4. Get the three users with the most money after making movements.

```
WITH sum_summary AS (
    WITH movements_summary AS (
        SELECT
            a.id AS account_id,
            a.mount as original_amount,
            
            m.type,
            CASE
                WHEN m.type = 'IN' THEN m.mount
                WHEN m.type NOT IN ('IN', 'TRANSFER') THEN -m.mount
                WHEN m.type = 'TRANSFER' AND m.account_from = a.id THEN -m.mount
                WHEN m.type = 'TRANSFER' AND m.account_to = a.id THEN m.mount
                ELSE a.mount
            END AS after_movements
        FROM
            accounts a
        INNER JOIN movements m
            ON a.id = m.account_to OR a.id = m.account_from
        ORDER BY
            after_movements
    )
    SELECT account_id, original_amount+ SUM(after_movements) AS final_movements
    FROM movements_summary
    GROUP BY account_id, original_amount
    ORDER BY final_movements DESC
)
SELECT u.id, sum(final_movements) as result
FROM sum_summary ss
inner join accounts a 
on ss.account_id = a.id
inner join users u
on a.user_id  = u.id
group by u.id
order by result desc limit 3
```


5. In this part you need to create a transaction with the following steps:

    a. First, get the ammount for the account `3b79e403-c788-495a-a8ca-86ad7643afaf` and `fd244313-36e5-4a17-a27c-f8265bc46590` after all their movements.

CREATE OR REPLACE FUNCTION get_balance_after_moves(p_account_id UUID)
RETURNS DOUBLE PRECISION AS $$
DECLARE
    balance DOUBLE PRECISION;
BEGIN
    WITH sum_summary AS (
        WITH movements_summary AS (
            SELECT
                a.id AS account_id,
                a.mount AS original_amount,
                m.type,
                CASE
                    WHEN m.type = 'IN' THEN m.mount
                    WHEN m.type NOT IN ('IN', 'TRANSFER') THEN -m.mount
                    WHEN m.type = 'TRANSFER' AND m.account_from = a.id THEN -m.mount
                    WHEN m.type = 'TRANSFER' AND m.account_to = a.id THEN m.mount
                    ELSE 0
                END AS after_movements
            FROM
                accounts a
            LEFT JOIN movements m
                ON a.id = m.account_to OR a.id = m.account_from
            WHERE a.id = p_account_id 
        )
        SELECT account_id, original_amount + SUM(after_movements) AS final_movements
        FROM movements_summary
        GROUP BY account_id, original_amount
    )
    SELECT COALESCE(SUM(ss.final_movements), 0)
    INTO balance
    FROM sum_summary ss;

    RETURN balance;
END;
$$ LANGUAGE plpgsql;

DO $$
DECLARE
    account1 DOUBLE PRECISION;
    account2 DOUBLE PRECISION;
    account_id_a UUID := '3b79e403-c788-495a-a8ca-86ad7643afaf';
    account_id_b UUID := 'fd244313-36e5-4a17-a27c-f8265bc46590';
    transfer_amount DOUBLE PRECISION := 50.75;
    withdrawal_amount DOUBLE PRECISION := 731823.56;
    partial_withdrawal DOUBLE PRECISION := 20.00;

BEGIN

    account1 := get_balance_after_moves(account_id_a);
    RAISE NOTICE 'Account A balance before transfer: %', account1;

    IF account1 < transfer_amount THEN
        RAISE EXCEPTION 'Insufficient balance in account %. Current balance: %', account_id_a, account1;
    END IF;
---b

    INSERT INTO movements (id, type, account_from, account_to, mount)
    VALUES (gen_random_uuid(), 'TRANSFER', account_id_a, account_id_b, transfer_amount);

	RAISE NOTICE 'succesfull';
---c

    account1 := get_balance_after_moves(account_id_a);
    RAISE NOTICE 'Account A balance after transfer: %', account1;

    /*  d. Put your answer here if the transaction fails(YES/NO): YES */ 
     IF account1 < withdrawal_amount THEN
        RAISE NOTICE 'Insufficient balance for withdrawal. Adjusting amount to a portion: %', account1;

/*e. If the transaction fails, make the correction on step _c_ to avoid the failure:*/
        IF account1 < partial_withdrawal THEN
            withdrawal_amount := account1;
        ELSE
            withdrawal_amount := partial_withdrawal;
        END IF;

        RAISE NOTICE 'Adjusted withdrawal amount: %', withdrawal_amount;
    END IF;

    INSERT INTO movements (id, type, account_from, account_to, mount)
    VALUES (gen_random_uuid(), 'OUT', account_id_a, NULL, withdrawal_amount);

    account1 := get_balance_after_moves(account_id_a);
    RAISE NOTICE 'Account A balance after withdrawal: %', account1;

    --- f. Once the transaction is correct, make a commit

    RAISE NOTICE 'Transaction successfully';
    ---e. How much money the account `fd244313-36e5-4a17-a27c-f8265bc46590` have:

	
    account2 := get_balance_after_moves(account_id_b);
    RAISE NOTICE 'Final balance of Account B: %', account2;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Transaction failed: %', SQLERRM;
        ROLLBACK;
END;
$$;


6. All the movements and the user information with the account `3b79e403-c788-495a-a8ca-86ad7643afaf`

```
SELECT 
    u.name || ' ' || u.last_name full_name,
    u.id user_id,
    u.email,
    a.id,
    m.mount
FROM 
    movements m
JOIN 
    accounts a ON a.id = m.account_from OR a.id = m.account_to
JOIN 
    users u ON u.id = a.user_id
WHERE 
    a.id = '3b79e403-c788-495a-a8ca-86ad7643afaf'
ORDER BY 
    m.created_at DESC;
```


7. The name and email of the user with the highest money in all his/her accounts

```
WITH sum_summary AS (
    WITH movements_summary AS (
        SELECT
            a.id AS account_id,
            a.mount AS original_amount,
            m.type,
            CASE
                WHEN m.type = 'IN' THEN m.mount
                WHEN m.type NOT IN ('IN', 'TRANSFER') THEN -m.mount
                WHEN m.type = 'TRANSFER' AND m.account_from = a.id THEN -m.mount
                WHEN m.type = 'TRANSFER' AND m.account_to = a.id THEN m.mount
                ELSE 0
            END AS after_movements
        FROM
            accounts a
        INNER JOIN movements m
            ON a.id = m.account_to OR a.id = m.account_from
    )
    SELECT 
        account_id, 
        original_amount + SUM(after_movements) AS final_movements
    FROM 
        movements_summary
    GROUP BY 
        account_id, original_amount
)
SELECT 
    u.name AS user_name, 
    u.email AS user_email, 
    SUM(ss.final_movements) AS highest_balance
FROM 
    sum_summary ss
INNER JOIN 
    accounts a ON ss.account_id = a.id
INNER JOIN 
    users u ON a.user_id = u.id
GROUP BY 
    u.id, u.name, u.email
ORDER BY 
    total_balance DESC
LIMIT 1;
```


8. Show all the movements for the user `Kaden.Gusikowski@gmail.com` order by account type and created_at on the movements table

```
select
	m.id as movement_id,
	m.mount as amount,
	m.created_at,
	a.type as account_type
from
	movements m
inner join 
    accounts a on
	a.id = m.account_from
	or a.id = m.account_to
inner join 
    users u on
	u.id = a.user_id
where
	u.email = 'Kaden.Gusikowski@gmail.com'
order by
	a.type,
	m.created_at;
```

