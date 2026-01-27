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

- [📝 Table of Contents](#-table-of-contents)
- [🤓 Case ](#-case-)
  - [ERD - Diagram ](#erd---diagram-)
- [🛠️ Docker Installation ](#️-docker-installation-)
- [📚 Recover the data to your machine ](#-recover-the-data-to-your-machine-)
- [📊 Excersises ](#-excersises-)

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
SELECT a.type, SUM(a.mount) 
FROM accounts a 
GROUP BY a.type;
```

2. How many users with at least 2 `CURRENT_ACCOUNT`.

```
SELECT count(*) 
FROM(
    SELECT u.name, count(a.id) AS current_accounts 
    FROM users u 
    LEFT JOIN accounts a ON a.user_id = u.id AND a.type = 'CURRENT_ACCOUNT' 
    GROUP BY u.id 
    HAVING count(a.id) >= 2
    ) AS total_people;
```

3. List the top five accounts with more money.

```
SELECT a.id, a.mount
FROM accounts a 
ORDER BY a.mount DESC 
LIMIT 5;
```

4. Get the three users with the most money after making movements.

```
WITH normalized_movements AS (
    SELECT account_to as account_id, mount as delta 
    FROM movements WHERE type = 'TRANSFER'
    UNION ALL
    SELECT account_from as account_id, -mount as delta 
    FROM movements WHERE type IN ('OUT', 'TRANSFER', 'OTHER')
    UNION ALL
    SELECT account_from as account_id, mount as delta 
    FROM movements WHERE type = 'IN'
),
account_changes AS (
    SELECT n.account_id , sum(delta) AS net_change
    FROM normalized_movements n 
    GROUP BY n.account_id
)
SELECT
    u.name,
    SUM(a.mount + COALESCE(ac.net_change , 0)) as current_amount
FROM users u
JOIN accounts a ON u.id = a.user_id
LEFT JOIN account_changes ac ON ac.account_id = a.id
GROUP BY u.id
ORDER BY current_amount DESC
LIMIT 3; 
```

5. In this part you need to create a transaction with the following steps:

   a. First, get the ammount for the account `3b79e403-c788-495a-a8ca-86ad7643afaf` and `fd244313-36e5-4a17-a27c-f8265bc46590` after all their movements.

   ```
   -- Function to calculate current amount FROM an account using only its ID
   CREATE OR REPLACE FUNCTION get_current_balance(p_account_id UUID)
   RETURNS FLOAT AS $$
   DECLARE
       v_balance FLOAT;
   BEGIN
           SELECT 
               (a.mount + 
                   SUM(
                       case 
                           WHEN t.type = 'IN' or (t.type = 'TRANSFER' AND t.account_to = a.id) THEN t.mount
                           WHEN t.type = 'OUT' or (t.type = 'TRANSFER' AND t.account_FROM = a.id) THEN -t.mount
                           else 0
                       END
                   )
               ) 
           INTO v_balance
           FROM accounts a 
           LEFT JOIN movements t ON a.id IN (t.account_FROM , t.account_to)
           WHERE a.id = p_account_id
           GROUP BY a.id , a.mount;
           IF v_balance IS NULL THEN
               SELECT mount INTO v_balance FROM accounts WHERE id = p_account_id;
           END IF;
           RETURN coalesce(v_balance, 0);
   END;
   $$ language plpgsql;
   ```

   b. Add a new movement with the information: from: `3b79e403-c788-495a-a8ca-86ad7643afaf`make a transfer to`fd244313-36e5-4a17-a27c-f8265bc46590`
   mount: 50.75

   ```
   DO $$
   BEGIN
           IF get_current_balance('3b79e403-c788-495a-a8ca-86ad7643afaf') < 50.75 THEN
               RAISE EXCEPTION 'Insuf. current amount on account';
           END if;
           INSERT INTO movements(id , mount , account_FROM , account_to , type , created_at , updated_at)
           VALUES (gen_rANDom_uuid() , 50.75 , '3b79e403-c788-495a-a8ca-86ad7643afaf' , 'fd244313-36e5-4a17-a27c-f8265bc46590' , 'TRANSFER' , now() , now()); 
   END $$;
   ```

   c. Add a new movement with the information: from: `3b79e403-c788-495a-a8ca-86ad7643afaf`
   type: OUT
   mount: 731823.56

   * Note: if the account does not have enough money you need to reject this insert and make a rollback for the entire transaction

   d. Put your answer here if the transaction fails(YES/NO):

   ```
    Yes, the transactions fails caused by insufficient current amount.
   ```

   e. If the transaction fails, make the correction on step _c_ to avoid the failure:

   ```
   -- Change the value from 731823.56 to 1823.56
   BEGIN
        IF get_current_balance('3b79e403-c788-495a-a8ca-86ad7643afaf') < 1823.56 THEN
            RAISE EXCEPTION 'Insuf. current amount on account';
        END IF;
        INSERT INTO movements(id , mount , account_FROM, type , created_at , updated_at)
        VALUES (gen_rANDom_uuid() , 1823.56, '3b79e403-c788-495a-a8ca-86ad7643afaf', 'OUT' , now() , now()); 
   END $$;
   ```

   f. Once the transaction is correct, make a commit

   ```
   COMMIT;
   ```

   e. How much money the account `fd244313-36e5-4a17-a27c-f8265bc46590` have:

   ```
   --- RAISE NOTICE 'Current amount: %' , get_current_balance('fd244313-36e5-4a17-a27c-f8265bc46590');
   Current amount: 3265.72
   ```
6. All the movements and the user information with the account `3b79e403-c788-495a-a8ca-86ad7643afaf`

```
SELECT m.*, u.name , u.last_name , u.email 
FROM movements m 
LEFT JOIN accounts a ON a.id in (m.account_FROM , m.account_to)
LEFT JOIN users u ON a.user_id = u.id
WHERE a.id = '3b79e403-c788-495a-a8ca-86ad7643afaf';
```

7. The name and email of the user with the highest money in all his/her accounts

```
-- Use the function defined previously to calculate total_balance for each user
SELECT 
    CONCAT(u.name, ' ', u.last_name) AS full_name, 
    u.email, 
    SUM(get_current_balance(a.id)) AS total_balance
FROM users u 
LEFT JOIN accounts a ON a.user_id = u.id
GROUP BY u.id
ORDER BY total_balance DESC
```

8. Show all the movements for the user `Kaden.Gusikowski@gmail.com` order by account type and created_at on the movements table

```
SELECT m.*, u.email, a.type, a.created_at
FROM users u 
INNER JOIN accounts a ON a.user_id = u.id 
INNER JOIN movements m ON a.id IN (m.account_from, m.account_to)
WHERE u.email = 'Kaden.Gusikowski@gmail.com'
ORDER BY a.type ASC, a.created_at DESC; 
```
