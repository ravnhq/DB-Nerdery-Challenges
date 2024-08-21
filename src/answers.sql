-- Your answers here:
-- 1
select a.type, sum(mount) from accounts a 
group by a.type

-- 2

select 
count(*) as user_account_more_t_2
from(select 
u.id, 
u.name,
a.type
from users as u 
inner join accounts a 
on u.id = a.user_id 
where a.type = 'CURRENT_ACCOUNT'
group by u.id , a.type
having 
count(*) >= 2) as subQuery

-- 3
select * from accounts a 
order by mount desc 
limit 5  

-- 4
select 
u.name,
m.mount as movement_amount, 
a.mount,
a.mount - m.mount as total
from  accounts a
left join movements m
on a.id  = m.account_from 
inner join users u  
on u.id = a.user_id 
group  by m.account_from , a.id , m.mount ,u.name
order by total desc limit 3

-- 5
create or replace FUNCTION getAmountAcount(param_account_id uuid)
 returns DOUBLE PRECISION AS $$

 DECLARE reault_amount DOUBLE PRECISION;
    
    begin
         
        select (case m.type 
        when 'IN'
            then a.mount + m.mount
            else a.mount - m.mount
            end ) as real_mount
            into reault_amount
        from accounts a    
        inner join movements m 
        on a.id = m.account_from
        where a.id = param_account_id;
        RAISE NOTICE 'amount: %', reault_amount;
        RETURN reault_amount;
        COMMIT;
    
END;
$$ LANGUAGE plpgsql;


BEGIN TRANSACTION;

    /*
     a.
    */
    
    SELECT getAmountAcount('3b79e403-c788-495a-a8ca-86ad7643afaf');
    SELECT getAmountAcount('fd244313-36e5-4a17-a27c-f8265bc46590');

    /*
     b.
    */
    DO $$
        DECLARE
            real_amount DOUBLE PRECISION;
        BEGIN
            SELECT getAmountAcount('3b79e403-c788-495a-a8ca-86ad7643afaf') INTO real_amount;
            IF real_amount >= 50.75 THEN
                INSERT INTO movements 
                VALUES (gen_random_uuid(),'TRANSFER','3b79e403-c788-495a-a8ca-86ad7643afaf','fd244313-36e5-4a17-a27c-f8265bc46590',50.75, NOW(),NOW());
                UPDATE accounts SET mount = mount + 50.75 WHERE id = '3b79e403-c788-495a-a8ca-86ad7643afaf';
                UPDATE accounts SET mount = mount - 50.75 WHERE id = 'fd244313-36e5-4a17-a27c-f8265bc46590';
                RAISE NOTICE 'Success';
            ELSE
                RAISE NOTICE 'not money';
            END IF;
        END;
        $$;
    SAVEPOINT check_point;

    /*
        c.  new movement 
    */
     DO $$
        DECLARE
            real_amount DOUBLE PRECISION;
        BEGIN
            SELECT getAmountAcount('3b79e403-c788-495a-a8ca-86ad7643afaf')INTO real_amount;
            IF real_amount >= 731823.56 THEN
                INSERT INTO movements
                VALUES (gen_random_uuid(),'OUT','3b79e403-c788-495a-a8ca-86ad7643afaf',731823.56, NOW(),NOW());
                UPDATE accounts SET mount = mount + 731823.56 WHERE id = '3b79e403-c788-495a-a8ca-86ad7643afaf';
                UPDATE accounts SET mount = mount - 731823.56 WHERE id = 'fd244313-36e5-4a17-a27c-f8265bc46590';
                RAISE NOTICE 'Success';
            ELSE
                RAISE NOTICE 'Error ';
            END IF;
        END;
        $$;
    
       -- d.
       -- yes, it has error, because not money for transaction
    
    ROLLBACK TO SAVEPOINT check_point;
    
   
    COMMIT TRANSACTION;
    --e
    select  (case m.type 
        when 'IN'
            then a.mount + m.mount
            else a.mount - m.mount
            end ) as real_mount
        from accounts a    
        inner join movements m 
        on a.id = m.account_from 
        where a.id = 'fd244313-36e5-4a17-a27c-f8265bc46590';
   

-- 6

   select 
   u.id ,
   m.type as type_movement,
   CONCAT(u.name, ',', u.last_name ) AS fullName,
   u.email ,
   a.id, 
   u.created_at ,
   u.date_joined ,
   u.updated_at 
   from accounts a 
   right join  movements m
   on m.account_from  = a.id or m.account_to  = a.id 
   inner  join users u 
   on u.id  = a.user_id 
   where a.id = '3b79e403-c788-495a-a8ca-86ad7643afaf'

-- 7
 select 
   u.id ,
   CONCAT(u.name, ',', u.last_name ) AS fullName,
   u.email ,
   sum(a.mount) as sum_total
   from accounts a 
   inner  join users u 
   on u.id  = a.user_id 
   group  by u.id 
   order by sum_total desc limit 1 

--8 
 select 
   a.type,
   u.id,
   a.account_id, 
   m.type as type_transaction,
   m.mount,
   m.created_at,
   u.name as user_name,
   m.id as movement_id
   from users u 
   inner join accounts a 
   on u.id  = a.user_id 
   inner join movements m 
   on a.id = m.account_from  
   where u.email  = 'Kaden.Gusikowski@gmail.com'
   group by a.type, u.id , m.id, a.account_id, m.created_at , m.type
    

