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
SELECT ac.type, SUM(mount)
FROM accounts ac
GROUP BY ac.type;
```


2. How many users with at least 2 `CURRENT_ACCOUNT`.

```
SELECT COUNT(*)
FROM (SELECT COUNT(*) AS user_account
      FROM users u
               INNER JOIN accounts a on u.id = a.user_id
      WHERE a.type = 'CURRENT_ACCOUNT'
      GROUP BY u.id
      HAVING COUNT(*) > 2) AS sq;
```


3. List the top five accounts with more money.

```
SELECT ac.mount
FROM accounts ac
ORDER BY ac.mount DESC
LIMIT 5;
```


4. Get the three users with the most money after making movements.

```
SELECT us.name,
       us.id,
       a.mount      AS account_amount,
       SUM(m.mount) AS mov_amount,
       CASE
           WHEN m.type = 'TRANSFER' THEN
               SUM(a.mount) + SUM(m.mount)
           WHEN m.type = 'IN' THEN
               SUM(a.mount) + SUM(m.mount)
           ELSE
               SUM(a.mount) - SUM(m.mount)
           END
                    AS total_amount
FROM users us
         INNER JOIN accounts a ON us.id = a.user_id
         INNER JOIN movements m ON a.id = m.account_from
GROUP BY us.name, us.id, a.mount, m.type
ORDER BY total_amount DESC
LIMIT 3;
```


5. In this part you need to create a transaction with the following steps:

```
CREATE OR REPLACE FUNCTION get_account_amount_after_movements(
    acc_id uuid
)
    RETURNS double precision
    LANGUAGE plpgsql
AS
$$
DECLARE
    remaining_amount double precision;
BEGIN
    SELECT CASE
               WHEN m.type = 'TRANSFER' THEN
                   SUM(a.mount) + SUM(m.mount)
               WHEN m.type = 'IN' THEN
                   SUM(a.mount) + SUM(m.mount)
               ELSE
                   SUM(a.mount) - SUM(m.mount)
               END
               AS total_amount
    INTO remaining_amount
    FROM users us
             INNER JOIN accounts a on us.id = a.user_id
             INNER JOIN movements m on a.id = m.account_from
    WHERE a.id = acc_id
    GROUP BY a.id, us.name, us.id, a.mount, m.type;

    RETURN remaining_amount;
END
$$;
```

a. First, get the ammount for the account `3b79e403-c788-495a-a8ca-86ad7643afaf` and `fd244313-36e5-4a17-a27c-f8265bc46590` after all their movements.

```
SELECT get_account_amount_after_movements('3b79e403-c788-495a-a8ca-86ad7643afaf');
SELECT get_account_amount_after_movements('fd244313-36e5-4a17-a27c-f8265bc46590');
```

b. Add a new movement with the information:
from: `3b79e403-c788-495a-a8ca-86ad7643afaf` make a transfer to `fd244313-36e5-4a17-a27c-f8265bc46590`
mount: 50.75

c. Add a new movement with the information:
    from: `3b79e403-c788-495a-a8ca-86ad7643afaf` 
    type: OUT
    mount: 731823.56
    * Note: if the account does not have enough money you need to reject this insert and make a rollback for the entire transaction

```
BEGIN;
DO $$
DECLARE
    temp_amount double precision;
BEGIN
    SELECT get_account_amount_after_movements('3b79e403-c788-495a-a8ca-86ad7643afaf') INTO temp_amount;

    -- Check if amount is sufficient
    IF temp_amount < 50.75 THEN
        BEGIN
            RAISE EXCEPTION 'Insufficient amount';
        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK;
                RAISE;
        END;
    END IF;

    -- Make transfer (create movement, update account mount)
    INSERT INTO movements (id, type, account_from, account_to, mount)
    VALUES (gen_random_uuid(), 'TRANSFER', '3b79e403-c788-495a-a8ca-86ad7643afaf',
            'fd244313-36e5-4a17-a27c-f8265bc46590',
            50.75);

    UPDATE accounts SET mount = mount + 50.75 WHERE id = 'fd244313-36e5-4a17-a27c-f8265bc46590';
    UPDATE accounts SET mount = mount - 50.75 WHERE id = '3b79e403-c788-495a-a8ca-86ad7643afaf';

    -- Update account A amount
    SELECT get_account_amount_after_movements('3b79e403-c788-495a-a8ca-86ad7643afaf') INTO temp_amount;

    IF temp_amount < 731823.56 THEN
        BEGIN
            RAISE EXCEPTION 'Insufficient amount';
        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK;
                RAISE;
        END;
    END IF;

    -- Make out movement (c)
    INSERT INTO movements (id, type, account_from, account_to, mount)
    VALUES (gen_random_uuid(), 'OUT', '3b79e403-c788-495a-a8ca-86ad7643afaf', null, 1.01);

    UPDATE accounts SET mount = mount - 731823.56 WHERE id = '3b79e403-c788-495a-a8ca-86ad7643afaf';
END;
$$;
COMMIT;
SELECT * FROM get_account_amount_after_movements('3b79e403-c788-495a-a8ca-86ad7643afaf');
```
    
d. Put your answer here if the transaction fails(YES/NO):

```
    YES
```

e. If the transaction fails, make the correction on step _c_ to avoid the failure:

```
    SELECT get_account_amount_after_movements('3b79e403-c788-495a-a8ca-86ad7643afaf');
```

f. Once the transaction is correct, make a commit

```
    SELECT get_account_amount_after_movements('3b79e403-c788-495a-a8ca-86ad7643afaf');
```

e. How much money the account `fd244313-36e5-4a17-a27c-f8265bc46590` have:

```
    SELECT get_account_amount_after_movements('fd244313-36e5-4a17-a27c-f8265bc46590');
```

6. All the movements and the user information with the account `3b79e403-c788-495a-a8ca-86ad7643afaf`

```
SELECT us.id,
       CONCAT(us.name, ' ', us.last_name) AS fullname,
       us.email,
       mov.account_from,
       mov.account_to,
       mov.mount
FROM movements mov
         INNER JOIN accounts a on mov.account_from = a.id
         INNER JOIN users us on a.user_id = us.id
WHERE a.id = '3b79e403-c788-495a-a8ca-86ad7643afaf';
```

7. The name and email of the user with the highest money in all his/her accounts

```
SELECT us.name,
       us.email,
       CASE
           WHEN m.type = 'TRANSFER' THEN
               SUM(a.mount) + SUM(m.mount)
           WHEN m.type = 'IN' THEN
               SUM(a.mount) + SUM(m.mount)
           ELSE
               SUM(a.mount) - SUM(m.mount)
           END
           AS total_amount
FROM users us
         INNER JOIN accounts a ON us.id = a.user_id
         INNER JOIN movements m ON a.id = m.account_from
GROUP BY us.name, us.id, a.mount, m.type
ORDER BY total_amount DESC
LIMIT 1;
```


8. Show all the movements for the user `Kaden.Gusikowski@gmail.com` order by account type and created_at on the movements table

```
SELECT mov.id, mov.type, mov.account_from, mov.account_to, mov.mount, mov.created_at, mov.updated_at
FROM movements mov
         INNER JOIN accounts a on mov.account_from = a.id
         INNER JOIN users us on a.user_id = us.id
WHERE us.email = 'Kaden.Gusikowski@gmail.com'
ORDER BY a.type, a.created_at;
```

