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

```postgresql
select
    type,
    sum(mount)
from accounts
group by
    type;
```


2. How many users with at least 2 `CURRENT_ACCOUNT`.

```postgresql
select
    count(*)
from
    (
        select
            count(user_id) as count
        from
            accounts
        where
            type = 'CURRENT_ACCOUNT'
        group by
            user_id
    ) as target
where
    count >= 2;
```


3. List the top five accounts with more money.

```postgresql
select
    *
from
    accounts
order by
    mount desc
limit 5;
```


4. Get the three users with the most money after making movements.

```postgresql
-- 4 SUBQUERY VERSION
select
    u.id,
    u.name,
    u.last_name,
    u.email,
    u.date_joined,
    u.created_at,
    u.updated_at
from
    (
        select
            account,
            ROUND(
                    sum(mount):: numeric,
                    2
            ) as mount
        from
            (
                (
                    -- deposits
                    select
                        account_from as account,
                        mount
                    from
                        movements
                    where
                        type = 'IN'
                    order by
                        type
                )
                union all
                (
                    -- withdrawals
                    select
                        account_from as account,
                        mount * -1 as mount
                    from
                        movements
                    where
                        type in ('OUT', 'OTHER')
                    order by
                        type
                )
                union all
                (
                    -- outbound transfers
                    select
                        account_from as account,
                        mount * -1 as mount
                    from
                        movements
                    where
                        type = 'TRANSFER'
                )
                union all
                (
                    -- inbound transfers
                    select
                        account_to as account,
                        mount
                    from
                        movements
                    where
                        type = 'TRANSFER'
                )
                union all
                (
                    -- starting balances
                    select
                        id as account,
                        mount
                    from
                        accounts
                )
            ) as target
        group by
            account
        order by
            mount desc
        limit
            3
    ) as top
        left join accounts on accounts.id = top.account
        left join users as u on accounts.user_id = u.id;
```
```postgresql
-- 4 WITH CTE VERSION
WITH processed_movements(account, mount) as (
    (
        -- deposits
        select
            account_from as account,
            mount
        from
            movements
        where
            type = 'IN'
        order by
            type
    )
    union all
    (
        -- withdrawals
        select
            account_from as account,
            mount * -1 as mount
        from
            movements
        where
            type in ('OUT', 'OTHER')
        order by
            type
    )
    union all
    (
        -- outbound transfers
        select
            account_from as account,
            mount * -1 as mount
        from
            movements
        where
            type = 'TRANSFER'
    )
    union all
    (
        -- inbound transfers
        select
            account_to as account,
            mount
        from
            movements
        where
            type = 'TRANSFER'
    )
    union all
    (
        -- starting balances
        select
            id as account,
            mount
        from
            accounts
    )
),
     top(account, mount) as (
         select
             account,
             ROUND(
                     sum(mount):: numeric,
                     2
             ) as mount
         from
             processed_movements
         group by
             account
         order by
             mount desc
         limit 3
     )
select
    u.*
from
    top
        left join accounts on accounts.id = top.account
        left join users as u on accounts.user_id = u.id;
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
    ```postgresql
        --Code does not display correctly please see answers.sql for the code.
   ```

        * Note: if the account does not have enough money you need to reject this insert and make a rollback for the entire transaction
    
    d. Put your answer here if the transaction fails(YES/NO):
    ```postgresql
        --YES with my exception after checks added to fulfill the note above.
    ```

    e. If the transaction fails, make the correction on step _c_ to avoid the failure:
    ```postgresql
        insert into movements(id, type,account_from,account_to,mount)
        values(
        gen_random_uuid(),
        'OUT',
        '3b79e403-c788-495a-a8ca-86ad7643afaf',
        DEFAULT,
        --5.e. If the transaction fails, make the correction on step c to avoid the failure:
        --731823.56, -- 5.e correction is to make amount lower. Or could also be a deposit (IN).
        123);
    ```

    f. Once the transaction is correct, make a commit
    ```postgresql
        -- 5.f. Once the transaction is correct, make a commit
        COMMIT;
    ```

    e. How much money the account `fd244313-36e5-4a17-a27c-f8265bc46590` have:
    ```postgresql
   -- CODE DISPLAY IS BROKEN PLEASE SEE ANSWERS.SQL INSTEAD
       
    ```


6. All the movements and the user information with the account `3b79e403-c788-495a-a8ca-86ad7643afaf`

```postgresql
-- My understanding is that we don't want a big table with all the info, 
-- thus two queries for two tables.
-- movements
select * from movements
where
    ('3b79e403-c788-495a-a8ca-86ad7643afaf') in (account_from, account_to);
-- user info
select *
from users
where
    id = (select user_id
          from accounts
          where accounts.id = '3b79e403-c788-495a-a8ca-86ad7643afaf');
```


7. The name and email of the user with the highest money in all his/her accounts

```postgresql
WITH processed_movements(account, mount) as (
    (
        -- deposits
        select
            account_from as account,
            mount
        from
            movements
        where
            type = 'IN'
        order by
            type
    )
    union all
    (
        -- withdrawals
        select
            account_from as account,
            mount * -1 as mount
        from
            movements
        where
            type in ('OUT', 'OTHER')
        order by
            type
    )
    union all
    (
        -- outbound transfers
        select
            account_from as account,
            mount * -1 as mount
        from
            movements
        where
            type = 'TRANSFER'
    )
    union all
    (
        -- inbound transfers
        select
            account_to as account,
            mount
        from
            movements
        where
            type = 'TRANSFER'
    )
    union all
    (
        -- starting balances
        select
            id as account,
            mount
        from
            accounts
    )
),
     top(account, mount) as (
         select
             account,
             ROUND(
                     sum(mount):: numeric,
                     2
             ) as mount
         from
             processed_movements
         group by
             account
         order by
             mount desc
         limit 1
     )
select
    u.*
from
    top
        left join accounts on accounts.id = top.account
        left join users as u on accounts.user_id = u.id;
```


8. Show all the movements for the user `Kaden.Gusikowski@gmail.com` order by account type and created_at on the movements table

```postgresql
-- 8. Show all the movements for the user Kaden.Gusikowski@gmail.com order by account type and created_at on the movements table
select * from 
users
left join accounts on accounts.user_id = users.id
left join movements on accounts.id IN  (movements.account_from, movements.account_to)
where
users.email = 'Kaden.Gusikowski@gmail.com'
order by
    accounts.type,
	movements.created_at;
```

