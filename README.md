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
SELECT type, SUM(mount) 
FROM accounts 
GROUP BY type 
```


2. How many users with at least 2 `CURRENT_ACCOUNT`.

```
WITH AccountTotal AS (
    SELECT a.user_id, COUNT(a.account_id)
    FROM accounts AS a
    WHERE a.type = 'CURRENT_ACCOUNT'
    GROUP BY a.user_id
)
SELECT COUNT(user_id) AS total_accounts_multiple_current
FROM AccountTotal
WHERE COUNT > 1;
```


3. List the top five accounts with more money.

```
SELECT concat(u.name, ' ', u.last_name) AS user, a.account_id, a.mount
FROM accounts AS a
JOIN users AS u ON a.user_id = u.id 
ORDER BY mount DESC
LIMIT 5
```


4. Get the three users with the most money after making movements.

```
SELECT u.name,
       SUM(Case
               WHEN m.type = 'IN' THEN m.mount
               WHEN m.type = 'OUT' THEN -m.mount
               WHEN m.type = 'OTHER' THEN -m.mount
               else
                   COALESCE(CASE WHEN m.account_to = a.id THEN m.mount ELSE 0 END, 0) -
                   COALESCE(CASE WHEN m.account_from = a.id THEN m.mount ELSE 0 END, 0)
           END
       ) AS total_balance
FROM users AS u
JOIN accounts AS a ON u.id = a.user_id
JOIN movements AS m ON a.id = m.account_from OR a.id = m.account_to
GROUP BY u.id
ORDER BY total_balance DESC
LIMIT 3
;
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
    ```
        Yes, because the amount exceeds the avialable funds the user has.
    ```

    e. If the transaction fails, make the correction on step _c_ to avoid the failure:
    ```
        DO $$
            DECLARE
                user_balance DOUBLE PRECISION;

            BEGIN
            
            SELECT mount 
            INTO user_balance 
            FROM accounts 
            WHERE id = '3b79e403-c788-495a-a8ca-86ad7643afaf';
            
            IF user_balance > 731823.56 THEN
                INSERT INTO movements (id, type, account_from, account_to, mount, created_at, updated_at)
                VALUES (
                    uuid_generate_v4(),
                    'OUT',
                    '3b79e403-c788-495a-a8ca-86ad7643afaf',
                    NULL,
                    731823.56,
                    NOW(),
                    NOW()
                );
            ELSE
                RAISE EXCEPTION 'Insufficient funds for user';
            END IF;

        COMMIT;

    EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
    END $$;
    ```

    f. Once the transaction is correct, make a commit
    ```
    UPDATE accounts
    SET mount = (
        SELECT SUM(Case
                   WHEN m.type = 'IN' THEN m.mount
                   WHEN m.type = 'OUT' THEN -m.mount
                   WHEN m.type = 'OTHER' THEN -m.mount
                   else
                       COALESCE(CASE WHEN m.account_to = a.id THEN m.mount ELSE 0 END, 0) -
                       COALESCE(CASE WHEN m.account_from = a.id THEN m.mount ELSE 0 END, 0)
               END
           ) AS balance
        FROM accounts AS a
        JOIN movements AS m ON a.id = m.account_from
        WHERE a.id = '3b79e403-c788-495a-a8ca-86ad7643afaf'
    )
    WHERE id = '3b79e403-c788-495a-a8ca-86ad7643afaf';

    UPDATE accounts
    SET mount = (
        SELECT SUM(Case
                   WHEN m.type = 'IN' THEN m.mount
                   WHEN m.type = 'OUT' THEN -m.mount
                   WHEN m.type = 'OTHER' THEN -m.mount
                   else
                       COALESCE(CASE WHEN m.account_to = a.id THEN m.mount ELSE 0 END, 0) -
                       COALESCE(CASE WHEN m.account_from = a.id THEN m.mount ELSE 0 END, 0)
               END
           ) AS balance
        FROM accounts AS a
        JOIN movements AS m ON a.id = m.account_from
        WHERE a.id = 'fd244313-36e5-4a17-a27c-f8265bc46590'
    )
    WHERE id = 'fd244313-36e5-4a17-a27c-f8265bc46590';

    INSERT INTO movements (id, type, account_from, account_to, mount, created_at, updated_at)
    VALUES (
        gen_random_uuid(),
        'TRANSFER',
        '3b79e403-c788-495a-a8ca-86ad7643afaf',
        'fd244313-36e5-4a17-a27c-f8265bc46590',
        50.75,
        NOW(),
        NOW()
    );

    UPDATE accounts
    SET mount = (
        SELECT SUM(a.mount - 50.75) AS balance
        FROM accounts AS a
        JOIN movements AS m ON a.id = m.account_from
        WHERE a.id = '3b79e403-c788-495a-a8ca-86ad7643afaf'
    )
    WHERE id = '3b79e403-c788-495a-a8ca-86ad7643afaf';

    DO $$
        DECLARE
            user_balance DOUBLE PRECISION;

        BEGIN
        
        SELECT mount 
        INTO user_balance 
        FROM accounts 
        WHERE id = '3b79e403-c788-495a-a8ca-86ad7643afaf';
        
        IF user_balance > 731823.56 THEN
            INSERT INTO movements (id, type, account_from, account_to, mount, created_at, updated_at)
            VALUES (
                uuid_generate_v4(),
                'OUT',
                '3b79e403-c788-495a-a8ca-86ad7643afaf',
                NULL,
                731823.56,
                NOW(),
                NOW()
            );
        ELSE
            RAISE EXCEPTION 'Insufficient funds for user';
        END IF;

    COMMIT;

    EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
    END $$;
    ```

    e. How much money the account `fd244313-36e5-4a17-a27c-f8265bc46590` have:
    ```
    SELECT concat(u.name, ' ', u.last_name) AS user, SUM((CASE WHEN m.type = 'IN' THEN m.mount ELSE - m.mount END) + a.mount) AS net_amount
    FROM users AS u
    JOIN accounts AS a ON u.id = a.user_id
    JOIN movements AS m ON m.account_from = a.id
    WHERE a.id = 'fd244313-36e5-4a17-a27c-f8265bc46590'
    GROUP BY u.name, u.last_name, u.email
    ORDER BY net_amount DESC;
    ```


6. All the movements and the user information with the account `3b79e403-c788-495a-a8ca-86ad7643afaf`

```
SELECT concat(u.name, ' ', u.last_name) AS user, u.email, a.account_id, a.mount, m.account_to, m.account_from, m.mount, m.type
FROM users AS u
JOIN accounts AS a ON u.id = a.user_id
JOIN movements AS m ON a.id = m.account_to OR a.id = m.account_from
WHERE a.id = '3b79e403-c788-495a-a8ca-86ad7643afaf';
```


7. The name and email of the user with the highest money in all his/her accounts

```
SELECT concat(u.name, ' ', u.last_name) AS user, u.email, SUM(Case
                   WHEN m.type = 'IN' THEN m.mount
                   WHEN m.type = 'OUT' THEN -m.mount
                   WHEN m.type = 'OTHER' THEN -m.mount
                   else
                       COALESCE(CASE WHEN m.account_to = a.id THEN m.mount ELSE 0 END, 0) -
                       COALESCE(CASE WHEN m.account_from = a.id THEN m.mount ELSE 0 END, 0)
               END
           ) AS net_amount
FROM users AS u
JOIN accounts AS a ON u.id = a.user_id
JOIN movements AS m ON m.account_from = a.id
GROUP BY u.name, u.last_name, u.email
ORDER BY net_amount DESC
LIMIT 1;
```


8. Show all the movements for the user `Kaden.Gusikowski@gmail.com` order by account type and created_at on the movements table

```
SELECT u.email, m.type, a.account_id, m.account_from, m.account_to, m.created_at
FROM movements AS m
JOIN accounts AS a ON m.account_from = a.id OR m.account_to = a.id
JOIN users AS u ON a.user_id = u.id
WHERE u.email = 'Kaden.Gusikowski@gmail.com'
ORDER BY a.type, m.created_at DESC;
```
