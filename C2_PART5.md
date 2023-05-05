# Exercise 5

## **Instructions**

In this part you need to create a transaction with the following steps:

a. First, get the amount for the account `3b79e403-c788-495a-a8ca-86ad7643afaf` and `fd244313-36e5-4a17-a27c-f8265bc46590` after all their movements. 

> Start of the note 

If we review the table `ACCOUNTS` you're gonna see that you have a field named `type`. We have 4 types, `TRANSFER, IN, OUT, OTHER` what I got when I asked is that `OTHER and OUT` are *expenses* and I assumed that the others one *incomes*. Based on that, what I did to handle this was: 

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

> End of the note

b. Add a new movement with the information: from: `3b79e403-c788-495a-a8ca-86ad7643afaf` make a transfer to `fd244313-36e5-4a17-a27c-f8265bc46590` mount: 50.75

> Start of the note

This is what I did to handle the second requirement: 

```
BEGIN;
DO
$$
    DECLARE
        amount_a         double precision;
        DECLARE amount_b double precision;
    BEGIN
        SELECT get_account_amount_after_movements('3b79e403-c788-495a-a8ca-86ad7643afaf') INTO amount_a;
        SELECT get_account_amount_after_movements('fd244313-36e5-4a17-a27c-f8265bc46590') INTO amount_b;

        INSERT INTO movements (id, type, account_from, account_to, mount)
        VALUES (gen_random_uuid(), 'TRANSFER', '3b79e403-c788-495a-a8ca-86ad7643afaf',
                'fd244313-36e5-4a17-a27c-f8265bc46590',
                50.75);

        SAVEPOINT created_mov;

        UPDATE accounts SET mount = mount + 50.75 WHERE id = 'fd244313-36e5-4a17-a27c-f8265bc46590';
        UPDATE accounts SET mount = mount - 50.75 WHERE id = '3b79e403-c788-495a-a8ca-86ad7643afaf';

        SAVEPOINT updated_amount;

        INSERT INTO movements (id, type, account_from, account_to, mount)
        VALUES (gen_random_uuid(), 'TRANSFER', '3b79e403-c788-495a-a8ca-86ad7643afaf',
                'fd244313-36e5-4a17-a27c-f8265bc46590',
                50.75);
    END;
$$;
```

c. Add a new movement with the information: from: `3b79e403-c788-495a-a8ca-86ad7643afaf` type: OUT mount: 731823.56 ( * Note: if the account does not have enough money you need to reject this insert and make a rollback for the entire transaction)

> Start of the note 

I started to get more confused with this point, because of the note and the next steps

**d. Put your answer here if the transaction fails(YES/NO):**

This is ok, is you a yes or no answer

But with this, 

**e. If the transaction fails, make the correction on step c to avoid the failure:**

How exactly do I have to correct it? If we think about a real scenario, the bank is just gonna reject the transaction, and that is suppossed to gonna happen in the letter C, because if you're doing a rollback you're preventing this type of error

Questions: 

* How should correction be handled?
* What involves correcting, rolling back the entire insert, or ignoring only the transactions?

**f. Once the transaction is correct, make a commit** 

I'm not getting this idea, because if you don't have enough money, there is no way to make a successful transaction, and this is the same, you're considering this in the rollback 

Questions: 

* In a real scenario if you don't have enough money, you cannot make a transaction, so, in a real scenario you have to rewrite the transfer amount or get more money, which scenario is expected here? 
* If we think in transactions, this can be handle in a rollback exception, is this expected or is there anything else that is expected?

> End of the note
