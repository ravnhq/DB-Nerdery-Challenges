SELECT 
    u.id AS user_id,
    u.name AS user_name,
    u.email AS user_email,
    a.id AS account_id,
    a.mount AS initial_money,
    m.id AS movement_id,
    m.type AS movement_type,
    m.account_from AS account_from,
    m.account_to AS account_to,
    m.mount AS movement_amount,
    a.mount + 
    SUM(
        CASE 
            WHEN m.account_from = a.id THEN -m.mount
            WHEN m.account_to = a.id THEN m.mount
        END
    ) OVER (
        PARTITION BY a.id 
        ORDER BY m.created_at
    ) AS total_money
FROM 
    users u
INNER JOIN 
    accounts a
ON 
    u.id = a.user_id
LEFT JOIN 
    movements m
ON 
    a.id IN (m.account_from, m.account_to)
WHERE 
    a.id = '3b79e403-c788-495a-a8ca-86ad7643afaf'
ORDER BY 
    m.created_at ASC;
