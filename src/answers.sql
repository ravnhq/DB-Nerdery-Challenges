-- Your answers here:
-- 1 
select a.type, sum(a.mount) as total from accounts a group by a.type;

-- 2  
select count(user_account.id) as total 
from (select u.id, count(account_id) 
      from accounts a 
      inner join users u on a.user_id = u.id and a."type" = 'CURRENT_ACCOUNT' 
      group by u.id
     ) as user_account 
where user_account.count > 1;

-- 3 
select * from accounts a order by a.mount desc limit 5;

-- 4 
select u.id as user_id, concat_ws(' ', u.name, u.last_name) as full_name, sum((case when m.type = 'IN' then m.mount else - m.mount end) + a.mount) as total 
from movements m 
inner join accounts a on a.id = m.account_from 
inner join users u on u.id  = a.user_id 
group by u.id 
order by total desc limit 3;

-- 5 
do $$
declare
    balance NUMERIC;
begin

select (a.mount + sum(
        case 
            when m.type = 'IN' or (m.type = 'OTHER' and m.account_to is null) or (a.id = m.account_to) then m.mount 
            else -m.mount 
        end)) 
    into balance  
from movements m 
inner join  accounts a 
    on (a.id = m.account_from or a.id = m.account_to) 
where a.id = '3b79e403-c788-495a-a8ca-86ad7643afaf'
group by a.id;

insert into movements (id, type, account_from, account_to, mount)
values ('68403d93-9391-48ba-adcb-4e0069350177', 'TRANSFER', '3b79e403-c788-495a-a8ca-86ad7643afaf', 'fd244313-36e5-4a17-a27c-f8265bc46590', 50.75);


if balance < 731823.56 then
	rollback;
    
else
    insert into movements (id, type, account_from, mount)
    values ('68403d93-9391-48ba-adcb-4e0069350144', 'OUT', '3b79e403-c788-495a-a8ca-86ad7643afaf', 731823.56);
end if;

end $$;

commit;

select a.id, (a.mount + sum(
        case 
            when m.type = 'IN' OR (m.type = 'OTHER' and m.account_to is null) or (a.id = m.account_to) then m.mount 
            else -m.mount 
        end)) 
    as total 
from movements m 
inner join accounts a 
    on (a.id = m.account_from OR a.id = m.account_to) 
where a.id = 'fd244313-36e5-4a17-a27c-f8265bc46590'
group by a.id;



-- 6 
select m.id as movements_id, m.type, m.account_from, m.account_to, m.mount, u.id as user_ud, u.name, u.last_name, u.email 
from accounts a 
inner join users u on a.user_id = u.id and a.id = '3b79e403-c788-495a-a8ca-86ad7643afaf'
inner join movements m on m.account_from = a.id or m.account_to = a.id;

-- 7 
select u.id, u.name, u.last_name, u.email, sum(a.mount) as sum_total
from users u 
inner join accounts a on a.user_id  = u.id
group by u.id
order by sum_total desc
limit 1;

-- 8 
select m.id as movement_id, m.type, m.account_from, m.account_to , m.mount, m.created_at 
from movements m 
inner join accounts a on a.id = m.account_from or a.id = m.account_to
inner join users u on a.user_id = u.id where u.email = 'Kaden.Gusikowski@gmail.com'
order by m.type, m.created_at;