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
cat src/dump.sql | docker exec -i postgres_container psql -U postgres -d nerdery_challenge2
```

- Note: The `...` mean the location where the src folder is located on your computer
- Your data is now on your database to use for the challenge

---

## 📊 Excersises <a name = "excersises"></a>

Now it's your turn to write SQL queries to achieve the following results (You need to write the query in the section `Your query here` on each question):

1. Total money of all the accounts group by types.

```sql
SELECT type account_type,
    ROUND(SUM(mount)::numeric, 2) money_sum
FROM accounts
GROUP BY type;
```

2. How many users with at least 2 `CURRENT_ACCOUNT`.

```sql
SELECT COUNT(*) AS count_user_at_least_2_current_account
FROM (
        SELECT u.id
        FROM users u
            INNER JOIN accounts a ON u.id = a.user_id
        WHERE a.type = 'CURRENT_ACCOUNT'
        GROUP BY u.id
        HAVING COUNT(u.id) > 1
    );
```

3. List the top five accounts with more money.

```sql
SELECT id,
    account_id,
    type,
    mount
FROM accounts
ORDER BY mount DESC
LIMIT 5;
```

4. Get the three users with the most money after making movements.

```sql
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
```

5. In this part you need to create a transaction with the following steps:

    a. First, get the ammount for the account `3b79e403-c788-495a-a8ca-86ad7643afaf` and `fd244313-36e5-4a17-a27c-f8265bc46590` after all their movements.
    b. Add a new movement with the information:
        from: `3b79e403-c788-495a-a8ca-86ad7643afaf` make a transfer to `fd244313-36e5-4a17-a27c-f8265bc46590`
        mount: 50.75

    c. Add a new movement with the information:
        from: `3b79e403-c788-495a-a8ca-86ad7643afaf`
        type: OUT
        mount: 731823.56

        * Note: if the account does not have enough money you need to reject this insert and make a rollback for the entire transaction

    d. Put your answer here if the transaction fails(YES/NO):

    ```sql
        --Yes, not enough money in the account for literal C transaction
    ```

    e. If the transaction fails, make the correction on step _c_ to avoid the failure:

    ```sql
        -- Errors fails were corrected using a EXCEPTION statement, and reducing the amount of the OUT movement to 500 USD
    ```

    f. Once the transaction is correct, make a commit

    e. How much money the account `fd244313-36e5-4a17-a27c-f8265bc46590` have:

    FINAL SOLUTION_


```sql
DO $$
DECLARE
    account_balance_a DOUBLE PRECISION;
    account_balance_b DOUBLE PRECISION;
	
    account_id_a UUID := '3b79e403-c788-495a-a8ca-86ad7643afaf';
    account_id_b UUID := 'fd244313-36e5-4a17-a27c-f8265bc46590';
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
	IF account_balance_a < 50.75 THEN
		RAISE EXCEPTION 'Account balance is insufficient!';
	ELSE 
		INSERT INTO movements  (id, type, account_from, account_to, mount) 
		VALUES (gen_random_uuid(), 'TRANSFER', account_id_a,account_id_b, 50.75);
		RAISE NOTICE 'Transfer % USD from % to % MADE SUCCESSFULLY!', 50.75, account_id_a, account_id_b;
	END IF;

	--c. Add a new movement with the information: from: 3b79e403-c788-495a-a8ca-86ad7643afaf type: OUT mount: 731823.56

	SELECT money into account_balance_a
	FROM get_accounts_final_balance() 
	WHERE account_id = account_id_a;
	
	IF account_balance_a < 731823.56 THEN
		RAISE EXCEPTION 'Account balance is insufficient!';
	ELSE 
		INSERT INTO movements  (id, type, account_from, account_to, mount) 
		VALUES (gen_random_uuid(), 'OUT', account_id_a,account_id_b );
		RAISE NOTICE 'Movement OUT % USD from % MADE SUCCESSFULLY!', 731823.56, account_id_a;
	END IF;

	--f. Once the transaction is correct, make a commit

	COMMIT;

	SELECT money into account_balance_b
	FROM get_accounts_final_balance() 
	WHERE account_id = account_id_b;

	RAISE NOTICE 'Account balance from % is %', account_id_b, account_balance_b;

EXCEPTION
--e. If the transaction fails, make the correction on step c to avoid the failure:


    WHEN OTHERS THEN
        RAISE NOTICE 'Transfer failed. Error: %', SQLERRM;
		ROLLBACK;
END;
$$;
```


6. All the movements and the user information with the account `3b79e403-c788-495a-a8ca-86ad7643afaf`

```sql
SELECT * 
FROM users u INNER JOIN accounts a ON u.id = a.user_id 
INNER JOIN movements m ON m.account_from = a.id OR m.account_to = a.id
WHERE a.id = '3b79e403-c788-495a-a8ca-86ad7643afaf';
```

7. The name and email of the user with the highest money in all his/her accounts

```sql
SELECT u.name, u.email, SUM(ab.money) money_balance FROM get_accounts_final_balance() ab
INNER JOIN accounts a ON a.id = ab.account_id 
INNER JOIN users u ON u.id = a.user_id
GROUP BY u.name, u.email
ORDER BY money_balance DESC
LIMIT 1;
```

8. Show all the movements for the user `Kaden.Gusikowski@gmail.com` order by account type and created_at on the movements table

```sql
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
```
