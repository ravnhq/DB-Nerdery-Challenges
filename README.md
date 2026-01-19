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
SELECT 
    type AS Account_type, 
    CAST(SUM(mount) AS numeric(10,2)) AS total_amount 
FROM accounts 
GROUP BY type;
```


2. How many users with at least 2 `CURRENT_ACCOUNT`.

```
SELECT 
    COUNT(a.id) AS users_count 
FROM users u
JOIN accounts a ON u.id = a.user_id
WHERE a.type = 'CURRENT_ACCOUNT'
GROUP BY a.type
HAVING COUNT(a.id) >= 2;
```


3. List the top five accounts with more money.

```
SELECT 
    u.name, 
    a.type, 
    a.mount AS amount 
FROM accounts a
JOIN users u ON u.id = a.user_id
ORDER BY a.mount DESC 
LIMIT 5;
```


4. Get the three users with the most money after making movements.

```
SELECT 
    u.name, 
    CAST((SUM(a.mount) + (
        SELECT SUM(
        CASE
            WHEN m.type = 'IN' THEN m.mount
            WHEN m.type = 'OUT' THEN -m.mount
            WHEN m.type = 'TRANSFER' AND m.account_from = sub_a.id THEN -m.mount
            WHEN m.type = 'TRANSFER' AND m.account_to = sub_a.id THEN m.mount
            WHEN m.type = 'OTHER' THEN -m.mount
        ELSE 
            0
        END
    ) 
    FROM movements m
    JOIN accounts sub_a ON m.account_from = sub_a.id OR m.account_to = sub_a.id
    WHERE sub_a.user_id = a.user_id
    ) ) AS numeric(10,2)) AS final_amount
FROM accounts a
JOIN users u ON u.id = a.user_id
GROUP BY a.user_id, u.name
ORDER BY final_amount DESC 
LIMIT 3;
```


5. In this part you need to create a transaction with the following steps:

    a. First, get the ammount for the account `3b79e403-c788-495a-a8ca-86ad7643afaf` and `fd244313-36e5-4a17-a27c-f8265bc46590` after all their movements.
    ```

    -- Running this query will give the same result but without knowing to which user is linked:
    -- SELECT get_account_final_amount('3b79e403-c788-495a-a8ca-86ad7643afaf')
    -- UNION
    -- SELECT get_account_final_amount('fd244313-36e5-4a17-a27c-f8265bc46590');

    WITH account_after_movs AS (
        SELECT 
            a.id, 
            u.name, 
            a.account_id,
            a.type, 
            CAST ((a.mount + SUM(
                CASE
                    WHEN m.type = 'IN' THEN m.mount
                    WHEN m.type = 'OUT' THEN -m.mount
                    WHEN m.type = 'TRANSFER' AND m.account_from = a.id THEN -m.mount
                    WHEN m.type = 'TRANSFER' AND m.account_to = a.id THEN m.mount
                    WHEN m.type = 'OTHER' THEN -m.mount
                ELSE 
                    0
                END
            )) AS numeric(10,2) ) AS final_amount
        FROM accounts a
        JOIN movements m ON m.account_from = a.id OR m.account_to = a.id
        JOIN users u ON u.id = a.user_id
        GROUP BY a.id, u.name
    )
    SELECT 
        name, 
        account_id, 
        type, 
        final_amount
    FROM account_after_movs 
    WHERE id IN ('3b79e403-c788-495a-a8ca-86ad7643afaf','fd244313-36e5-4a17-a27c-f8265bc46590')
    ORDER BY final_amount DESC;
    ```
    
    b. Add a new movement with the information:
        from: `3b79e403-c788-495a-a8ca-86ad7643afaf` make a transfer to `fd244313-36e5-4a17-a27c-f8265bc46590`
        mount: 50.75
    ```
    INSERT INTO movements (id, type, account_from, account_to, mount)
    VALUES (gen_random_uuid(), 'TRANSFER', '3b79e403-c788-495a-a8ca-86ad7643afaf', 'fd244313-36e5-4a17-a27c-f8265bc46590', 50.75);
    ```

    c. Add a new movement with the information:
        from: `3b79e403-c788-495a-a8ca-86ad7643afaf` 
        type: OUT
        mount: 731823.56

        * Note: if the account does not have enough money you need to reject this insert and make a rollback for the entire transaction
    ```
    DROP FUNCTION IF EXISTS get_account_final_amount(TEXT);
    CREATE OR REPLACE FUNCTION get_account_final_amount(s_account_id TEXT) 
    returns numeric(10,2) 
    language plpgsql
    AS
    $$
    declare
        final_amount numeric(10,2);
    BEGIN
        SELECT CAST ((a.mount + SUM(
            CASE
                WHEN m.type = 'IN' THEN m.mount
                WHEN m.type = 'OUT' THEN -m.mount
                WHEN m.type = 'TRANSFER' AND m.account_from = a.id THEN -m.mount
                WHEN m.type = 'TRANSFER' AND m.account_to = a.id THEN m.mount
                WHEN m.type = 'OTHER' THEN -m.mount
            ELSE 
                0
            END
        )) AS numeric(10,2) ) AS final_amount
        INTO final_amount
        FROM accounts a
        JOIN movements m ON m.account_from = a.id OR m.account_to = a.id
        JOIN users u ON u.id = a.user_id
        WHERE a.id = CAST(s_account_id AS UUID)
        GROUP BY a.id, u.name;

        return final_amount;
    END;
    $$;

    -- Create a function that inserts the movements and 
    -- checks for sufficient funds and raise exception, if neccesary, triggering a rollback
    do $$
    DECLARE 
    final_amount numeric(10,2);
    BEGIN

    INSERT INTO movements (id, type, account_from, mount)
    VALUES (gen_random_uuid() ,'OUT', '3b79e403-c788-495a-a8ca-86ad7643afaf', 731823.56);

    SELECT get_account_final_amount('3b79e403-c788-495a-a8ca-86ad7643afaf') 
    INTO final_amount;  

    IF final_amount < 0 THEN
        RAISE EXCEPTION 'INSUFFICIENT FUNDS'; -- This will trigger a rollback
    END IF;
    END
    $$;
    ```
    
    d. Put your answer here if the transaction fails(YES/NO):
    ```
    YES
    ```

    e. If the transaction fails, make the correction on step _c_ to avoid the failure:
    ```
    do $$
        DECLARE 
        final_amount numeric(10,2);
        initial_amount numeric(10,2);
        BEGIN
        SELECT get_account_final_amount('3b79e403-c788-495a-a8ca-86ad7643afaf') 
        INTO initial_amount;  

        -- Pre check if there is sufficient funds
        IF initial_amount - 731823.56 < 0 THEN
            -- Leave the account at 0 balance
            INSERT INTO movements (id, type, account_from, mount)
            VALUES (gen_random_uuid() ,'OUT', '3b79e403-c788-495a-a8ca-86ad7643afaf', initial_amount);
        ELSE
            INSERT INTO movements (id, type, account_from, mount)
            VALUES (gen_random_uuid() ,'OUT', '3b79e403-c788-495a-a8ca-86ad7643afaf', 731823.56);
        END IF;


        SELECT get_account_final_amount('3b79e403-c788-495a-a8ca-86ad7643afaf') 
        INTO final_amount;  

        END
    $$;
    ```

    f. Once the transaction is correct, make a commit
    ```
    COMMIT;
    ```

    g. How much money the account `fd244313-36e5-4a17-a27c-f8265bc46590` have:
    ```
    SELECT get_account_final_amount('fd244313-36e5-4a17-a27c-f8265bc46590') as final_amount; 
    ```


6. All the movements and the user information with the account `3b79e403-c788-495a-a8ca-86ad7643afaf`

```
SELECT 
    u.name || ' ' || u.last_name AS name, 
    u.email, 
    a.account_id, 
    m.type AS transfer_type, 
    m.mount as movement
FROM accounts a
JOIN movements m ON m.account_from = a.id OR m.account_to = a.id
JOIN users u ON u.id = a.user_id
WHERE a.id = '3b79e403-c788-495a-a8ca-86ad7643afaf';
```


7. The name and email of the user with the highest money in all his/her accounts

```
SELECT 
    u.name, 
    u.email, 
    CAST((SUM(a.mount) + (
        SELECT SUM(
        CASE
            WHEN m.type = 'IN' THEN m.mount
            WHEN m.type = 'OUT' THEN -m.mount
            WHEN m.type = 'TRANSFER' AND m.account_from = sub_a.id THEN -m.mount
            WHEN m.type = 'TRANSFER' AND m.account_to = sub_a.id THEN m.mount
            WHEN m.type = 'OTHER' THEN -m.mount
        ELSE 
            0
        END
    ) 
    FROM movements m
    JOIN accounts sub_a ON m.account_from = sub_a.id OR m.account_to = sub_a.id
    WHERE sub_a.user_id = a.user_id
    ) ) AS numeric(10,2)) AS final_amount
FROM accounts a
JOIN users u ON u.id = a.user_id
GROUP BY a.user_id, u.name, u.email
ORDER BY final_amount DESC 
LIMIT 1;
```


8. Show all the movements for the user `Kaden.Gusikowski@gmail.com` order by account type and created_at on the movements table

```
SELECT 
    m.type AS movement_type, 
    m.account_from, 
    m.account_to, 
    m.mount AS movement_amount
FROM users u
JOIN accounts a ON a.user_id = u.id
JOIN movements m ON m.account_from = a.id OR m.account_to = a.id
WHERE u.email ILIKE 'Kaden.Gusikowski@gmail.com';
```

