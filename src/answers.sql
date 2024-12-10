-- Your answers here:
-- 1
select
    type,
    sum(mount)
from accounts
group by
    type;

-- 2
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

-- 3
select
    *
from
    accounts
order by
    mount desc
    limit 5;

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

-- 5
BEGIN TRANSACTION ;

WITH relevant_movements as (
    select * from movements
    where
        account_from in ('3b79e403-c788-495a-a8ca-86ad7643afaf','fd244313-36e5-4a17-a27c-f8265bc46590')
       OR
        account_to in ('3b79e403-c788-495a-a8ca-86ad7643afaf','fd244313-36e5-4a17-a27c-f8265bc46590')
),
     processed_movements(account, mount) as (
         (
             -- deposits
             select
                 account_from as account,
                 mount
             from
                 relevant_movements
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
                 relevant_movements
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
                 relevant_movements
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
                 relevant_movements
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
             where
                 id in ('3b79e403-c788-495a-a8ca-86ad7643afaf','fd244313-36e5-4a17-a27c-f8265bc46590')
         )
     ),
     calc_balances(account, mount) as (
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

     ),
     current_balances(account,mount) as (
         select * from calc_balances
         where
             account in ('3b79e403-c788-495a-a8ca-86ad7643afaf','fd244313-36e5-4a17-a27c-f8265bc46590')
     )

-- 5.a
--First, get the ammount for the account faf and 590 after all their movements.
select * from current_balances;

--5.b
-- Add a new movement with the information: from: faf make a transfer to 590 mount: 50.75
insert into movements(id, type,account_from,account_to,mount)
values(
          gen_random_uuid(),
          'TRANSFER',
          '3b79e403-c788-495a-a8ca-86ad7643afaf',
          'fd244313-36e5-4a17-a27c-f8265bc46590',
          50.75);

-- 5.c step 1
-- Add a new movement with the information: from: faf type: OUT mount: 731823.56
insert into movements(id, type,account_from,account_to,mount)
values(
          gen_random_uuid(),
          'OUT',
          '3b79e403-c788-495a-a8ca-86ad7643afaf',
          DEFAULT,
          --5.e. If the transaction fails, make the correction on step c to avoid the failure:
          --731823.56, -- 5.e correction is to make amount lower. Or could also be a deposit (IN).
          123);

-- 5.c step 2
-- we check for negative balances and fail if so.
DO
$$
    BEGIN

        IF (
               WITH relevant_movements as (
                   select * from movements
                   where
                       account_from in ('3b79e403-c788-495a-a8ca-86ad7643afaf','fd244313-36e5-4a17-a27c-f8265bc46590')
                      OR
                       account_to in ('3b79e403-c788-495a-a8ca-86ad7643afaf','fd244313-36e5-4a17-a27c-f8265bc46590')
               ),
                    processed_movements(account, mount) as (
                        (
                            -- deposits
                            select
                                account_from as account,
                                mount
                            from
                                relevant_movements
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
                                relevant_movements
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
                                relevant_movements
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
                                relevant_movements
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
                            where
                                id in ('3b79e403-c788-495a-a8ca-86ad7643afaf','fd244313-36e5-4a17-a27c-f8265bc46590')
                        )
                    ),
                    calc_balances(account, mount) as (
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

                    ),
                    current_balances(account,mount) as (
                        select * from calc_balances
                        where
                            account in ('3b79e403-c788-495a-a8ca-86ad7643afaf','fd244313-36e5-4a17-a27c-f8265bc46590')
                    )
               select count(*) as c from current_balances where mount < 0) > 0 then
            RAISE EXCEPTION 'Balance is negative after insertion';

        end if;

    END;
$$ LANGUAGE plpgsql;



-- 5.f. Once the transaction is correct, make a commit
COMMIT;


WITH relevant_movements as (
    select * from movements
    where
        account_from in ('3b79e403-c788-495a-a8ca-86ad7643afaf','fd244313-36e5-4a17-a27c-f8265bc46590')
       OR
        account_to in ('3b79e403-c788-495a-a8ca-86ad7643afaf','fd244313-36e5-4a17-a27c-f8265bc46590')
),
     processed_movements(account, mount) as (
         (
             -- deposits
             select
                 account_from as account,
                 mount
             from
                 relevant_movements
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
                 relevant_movements
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
                 relevant_movements
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
                 relevant_movements
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
             where
                 id in ('fd244313-36e5-4a17-a27c-f8265bc46590')
         )
     ),
     calc_balances(account, mount) as (
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

     ),
     current_balances(account,mount) as (
         select * from calc_balances
         where
             account in ('fd244313-36e5-4a17-a27c-f8265bc46590')
     )

-- 5.e
--How much money the account fd244313-36e5-4a17-a27c-f8265bc46590 have:
select * from current_balances;

-- 6. All the movements and the user information with the account 3b79e403-c788-495a-a8ca-86ad7643afaf
-- My understanding is that we don't want a big table with all the info, thus two queries for two tables.
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

-- 7. The name and email of the user with the highest money in all his/her accounts
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