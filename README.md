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
SELECT accounts.type, SUM(accounts.mount) AS total
FROM accounts
GROUP BY accounts.type;

```

2. How many users with at least 2 `CURRENT_ACCOUNT`.

```
SELECT COUNT(*) AS users_with_at_least_two_accounts
FROM (
    SELECT accounts.user_id
    FROM accounts
    WHERE accounts.type = 'CURRENT_ACCOUNT'
    GROUP BY accounts.user_id
    HAVING COUNT(accounts.type) >= 2
) AS subquery;

```

3. List the top five accounts with more money.

```
SELECT accounts.id, accounts.user_id, accounts.type, accounts.mount
FROM accounts
ORDER BY accounts.mount DESC
LIMIT 5;
```

4. Get the three users with the most money after making movements.

```
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
```

5.  In this part you need to create a transaction with the following steps:

            a. First, get the ammount for the account `3b79e403-c788-495a-a8ca-86ad7643afaf` and `fd244313-36e5-4a17-a27c-f8265bc46590` after all their movements.
            b. Add a new movement with the information:
                from: `3b79e403-c788-495a-a8ca-86ad7643afaf` make a transfer to `fd244313-36e5-4a17-a27c-f8265bc46590`
                mount: 50.75

            c. Add a new movement with the information:
                from: `3b79e403-c788-495a-a8ca-86ad7643afaf`
                type: OUT
                mount: 731823.56

                * Note: if the account does not have enough money you need to reject this insert and make a rollback for the entire transaction

```

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
```

        d. Put your answer here if the transaction fails(YES/NO):
        ```
           YES
        ```

        e. If the transaction fails, make the correction on step _c_ to avoid the failure:
        ```
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
        ```

        f. Once the transaction is correct, make a commit
        ```
            -- If the balance is not sufficient, reduce the amount_out amount so that it does not cause an error.
        ```

        e. How much money the account `fd244313-36e5-4a17-a27c-f8265bc46590` have:
        ```
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

    ```

6.  All the movements and the user information with the account `3b79e403-c788-495a-a8ca-86ad7643afaf`

```
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
```

7. The name and email of the user with the highest money in all his/her accounts

```
SELECT
	CONCAT (us.name, ' ', us.last_name),
	us.email
FROM accounts ac
INNER JOIN users us ON ac.user_id = us.id
GROUP BY ac.user_id, us.name, us.email, us.last_name
ORDER BY SUM(ac.mount) DESC
LIMIT 1;
```

8. Show all the movements for the user `Kaden.Gusikowski@gmail.com` order by account type and created_at on the movements table

```
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
```
