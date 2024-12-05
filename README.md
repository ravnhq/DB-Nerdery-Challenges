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

```sql
SELECT 
  type, 
  SUM(mount) AS total 
FROM 
  accounts 
GROUP BY 
  type;
```
<p align="center">
 <img src="src/my-results/result1.png" alt="result_1"/>
</p>

2. How many users with at least 2 `CURRENT_ACCOUNT`.

```sql
SELECT 
  count(*) as user_w_least_two_accounts 
FROM 
  users AS u 
  INNER JOIN accounts AS a ON u.id = a.user_id 
WHERE 
  a.type = 'CURRENT_ACCOUNT' 
HAVING 
  count(a.id) >= 2;
```
<p align="center">
 <img src="src/my-results/result2.png" alt="result_2"/>
</p>

3. List the top five accounts with more money.

```sql
SELECT id, mount
FROM accounts
ORDER BY mount DESC
LIMIT 5;
```
<p align="center">
 <img src="src/my-results/result3.png" alt="result_3"/>
</p>

4. Get the three users with the most money after making movements. // take a look on this, dont commit the movements

```sql
    WITH account_balances AS (
    SELECT
        u.id AS user_id,
        a.account_id,
        a.id AS account_uuid, 
        a.mount AS initial_mount,
        COALESCE(
        SUM(
            CASE WHEN m.type = 'TRANSFER'
            AND m.account_from = a.id THEN - m.mount WHEN m.type = 'TRANSFER'
            AND m.account_to = a.id THEN m.mount WHEN m.type = 'IN'
            AND m.account_from = a.id THEN m.mount WHEN m.type = 'OUT'
            AND m.account_from = a.id THEN - m.mount WHEN m.type = 'OTHER'
            AND m.account_from = a.id THEN m.mount ELSE 0 END
        ),
        0
        ) AS movement_total
    FROM
        users AS u
        INNER JOIN accounts AS a ON u.id = a.user_id
        LEFT JOIN movements AS m ON a.id IN (m.account_from, m.account_to)
    GROUP BY
        u.id,
        u.name,
        a.account_id,
        a.mount
    )
    SELECT
    CONCAT(u.name, ' ', u.last_name) AS full_name,
    (
        ab.initial_mount + ab.movement_total
    ) AS mount
    FROM
    users AS u
    INNER JOIN account_balances AS ab ON u.id = ab.user_id
    ORDER BY
    mount DESC
    LIMIT
    3;
```

<p align="center">
 <img src="src/my-results/result4.png" alt="result_4"/>
</p>

5. In this part you need to create a transaction with the following steps:

    a. First, get the ammount for the account `3b79e403-c788-495a-a8ca-86ad7643afaf` and `fd244313-36e5-4a17-a27c-f8265bc46590` after all their movements.
    ```sql
    WITH account_balances AS (
    SELECT 
        u.id AS user_id, 
        a.account_id, 
        a.id AS account_uuid, 
        a.mount AS initial_mount, 
        COALESCE(
        SUM(
            CASE WHEN m.type = 'TRANSFER' 
            AND m.account_from = a.id THEN - m.mount WHEN m.type = 'TRANSFER' 
            AND m.account_to = a.id THEN m.mount WHEN m.type = 'IN' 
            AND m.account_from = a.id THEN m.mount WHEN m.type = 'OUT' 
            AND m.account_from = a.id THEN - m.mount WHEN m.type = 'OTHER' 
            AND m.account_from = a.id THEN m.mount ELSE 0 END
        ), 
        0
        ) AS movement_total 
    FROM 
        users AS u 
        INNER JOIN accounts AS a ON u.id = a.user_id 
        LEFT JOIN movements AS m ON a.id IN (m.account_from, m.account_to) 
    GROUP BY 
        u.id, 
        a.account_id, 
        a.id, 
        a.mount
    ) 

    SELECT 
    a.id, 
    (
        ab.initial_mount + ab.movement_total
    ) AS mount 
    FROM 
    accounts AS a 
    INNER JOIN account_balances AS ab ON a.id = ab.account_uuid 
    WHERE 
    a.id IN (
        'fd244313-36e5-4a17-a27c-f8265bc46590', 
        '3b79e403-c788-495a-a8ca-86ad7643afaf'
    );
    ```

    <p align="center">
     <img src="src/my-results/result5A.png" alt="result_5"/>
    </p>

    b. Add a new movement with the information:from: `3b79e403-c788-495a-a8ca-86ad7643afaf` make a transfer to `fd244313-36e5-4a17-a27c-f8265bc46590` mount: 50.75

    ```sql
    WITH account_balances AS (
    SELECT
        u.id AS user_id,
        a.account_id,
        a.id AS account_uuid,
        a.mount AS initial_mount,
        COALESCE(
        SUM(
            CASE
            WHEN m.type = 'TRANSFER' AND m.account_from = a.id THEN -m.mount
            WHEN m.type = 'TRANSFER' AND m.account_to = a.id THEN m.mount
            WHEN m.type = 'IN' AND m.account_from = a.id THEN m.mount
            WHEN m.type = 'OUT' AND m.account_from = a.id THEN -m.mount
            WHEN m.type = 'OTHER' AND m.account_from = a.id THEN m.mount
            ELSE 0
            END
        ),
        0
        ) AS movement_total
    FROM
        users AS u
        INNER JOIN accounts AS a ON u.id = a.user_id
        LEFT JOIN movements AS m ON a.id IN (m.account_from, m.account_to)
    GROUP BY
        u.id, a.account_id, a.id, a.mount
    ),
        
    balanced_accounts AS (
    SELECT
        ab.account_uuid AS account_id,
        (ab.initial_mount + ab.movement_total) AS balanced_mount
    FROM
        account_balances AS ab
    )

    SELECT
    a.id AS account_id,
    ba.balanced_mount,
    CASE
        WHEN ba.balanced_mount < 50.75 THEN ba.balanced_mount
        WHEN a.id = 'fd244313-36e5-4a17-a27c-f8265bc46590' THEN (ba.balanced_mount + 50.75)
        ELSE (ba.balanced_mount - 50.75)
    END AS new_balance_result,
    CASE
        WHEN ba.balanced_mount < 50.75 THEN 'transaction not allowed: insufficient funds'
        ELSE 'transaction completed'
    END AS status
    FROM
    accounts AS a
    INNER JOIN balanced_accounts AS ba ON ba.account_id = a.id
    WHERE
    a.id IN (
        '3b79e403-c788-495a-a8ca-86ad7643afaf',
        'fd244313-36e5-4a17-a27c-f8265bc46590'
    );
    ```
    <p align="center">
     <img src="src/my-results/result5B.png" alt="result_5"/>
    </p>
    c. Add a new movement with the information:
        from: `3b79e403-c788-495a-a8ca-86ad7643afaf` 
        type: OUT
        mount: 731823.56
    
        * Note: if the account does not have enough money you need to reject this insert and make a rollback for the entire transaction
    ```sql
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
    ```

    d. Put your answer here if the transaction fails(YES/NO):
    failure:
    <p align="center">
     <img src="src/my-results/result5C.png" alt="result_5"/>
    </p>
    success:
    <p align="center">
     <img src="src/my-results/result5C2.png" alt="result_5"/>
    </p>
    e. If the transaction fails, make the correction on step _c_ to avoid the failure:

    ```sql
    INSERT INTO movements(id, type, account_from, account_to, mount)
    VALUES (gen_random_uuid(), 'OUT', '3b79e403-c788-495a-a8ca-86ad7643afaf', NULL, 1000.05)
    RETURNING * INTO record;
    ```

    f. Once the transaction is correct, make a commit
    ```sql
    RAISE NOTICE 'Transaction successful: Movement ID %, Account ID %, New Balance %.',
        record.id, accounts_record.id, accounts_record.mount;

    COMMIT;
    ```

    e. How much money the account `fd244313-36e5-4a17-a27c-f8265bc46590` have:
    ```sql
    SELECT id, mount
    FROM accounts
    WHERE id = 'fd244313-36e5-4a17-a27c-f8265bc46590';
    ```
    <p align="center">
     <img src="src/my-results/result5E.png" alt="result_5"/>
    </p>

6. All the movements and the user information with the account `3b79e403-c788-495a-a8ca-86ad7643afaf`

```SQL
WITH user_info AS (
  SELECT 
    u.id AS user_id, 
    CONCAT(u.name, ' ', u.last_name) AS full_name, 
    u.email AS user_email, 
    u.date_joined AS user_date_joined, 
    a.id AS account_id 
  FROM 
    users u 
    INNER JOIN accounts a ON u.id = a.user_id 
  WHERE 
    a.id = '3b79e403-c788-495a-a8ca-86ad7643afaf'
) 
SELECT 
  ui.full_name, 
  ui.user_email, 
  ui.user_date_joined, 
  m.type, 
  m.account_from, 
  m.account_to, 
  m.mount 
FROM 
  user_info ui 
  LEFT JOIN movements m ON m.account_from = ui.account_id 
  OR m.account_to = ui.account_id;

```
<p align="center">
     <img src="src/my-results/result6.png" alt="result_6"/>
</p>


7. The name and email of the user with the highest money in all his/her accounts

```sql
WITH highest_account_mount AS (
  SELECT
    user_id,
    MAX(mount) AS max_mount
  FROM
    accounts
  GROUP BY
    user_id
  ORDER BY
    max_mount DESC
  LIMIT
    1
)
SELECT
  CONCAT(u.name, ' ', u.last_name) AS full_name,
  u.email,
  ham.max_mount AS total_money
FROM
  users AS u
  INNER JOIN highest_account_mount AS ham ON u.id = ham.user_id;
```

<p align="center">
     <img src="src/my-results/result7.png" alt="result_7"/>
</p>

8. Show all the movements for the user `Kaden.Gusikowski@gmail.com` order by account type and created_at on the movements table

```sql
WITH user_info AS (
  SELECT 
    u.id, 
    u.email, 
    a.id AS account_id 
  FROM 
    users AS u 
    INNER JOIN accounts AS a ON u.id = a.user_id 
  WHERE 
    u.email = 'Kaden.Gusikowski@gmail.com'
) 
SELECT 
  DISTINCT ui.email, 
  m.id AS id_movement, 
  m.type, 
  m.account_from, 
  m.account_to, 
  m.mount, 
  m.created_at 
FROM 
  movements m 
  INNER JOIN user_info ui ON m.account_from = ui.account_id 
  OR m.account_to = ui.account_id 
ORDER BY 
  m.type, 
  m.created_at;

```

<p align="center">
     <img src="src/my-results/result8.png" alt="result_8"/>
</p>