<p align="center" style="background-color:white">
 <a href="https://www.ravn.co/" rel="noopener">
 <img src="https://www.ravn.co/img/logo-ravn.png" alt="RAVN logo"></a>
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
docker run --name nerdery-container -e POSTGRES_PASSWORD=password123 -p 5432:5432 -d --rm postgres:13.0
```
C:\Users\arago\OneDrive\Escritorio\nerdery-repos\DB-Nerdery-Challenges2\src\dump.sql
2. Now, we access the container:

```
docker exec -it -u postgres nerdery-container psql
```

3. Create the database:

```
create database nerdery_challenge;
```

4. Restore de postgres backup file

```
cat /.../src/dump.sql | docker exec -i nerdery-container psql -U postgres -d nerdery_challenge
```

- Note: The `...` mean the location where the src folder is located on your computer
- Your data is now on your database to use for the challenge

---

## 📊 Excersises <a name = "excersises"></a>

Now it's your turn to write SQL querys to achieve the following results:

1. Count the total number of states in each country.

```sql
SELECT
  c.name AS country,
  count(s.name) AS states_count
FROM
  states AS s
  INNER JOIN countries AS c ON s.country_id = c.id
group by
  country;
```

<p align="center">
 <img src="src/results/result1.png" alt="result_1"/>
</p>

2. How many employees do not have supervisores.

```sql
SELECT COUNT(*) AS employees_without_supervisors
FROM employees
WHERE supervisor_id IS NULL;
```

<p align="center">
 <img src="src/results/result2.png" alt="result_2"/>
</p>

3. List the top five offices address with the most amount of employees, order the result by country and display a column with a counter.

```SQL
SELECT 
  c.name AS country, 
  o.address AS office_address, 
  COUNT(e.id) AS total_employees 
FROM 
  offices AS o 
  LEFT JOIN employees AS e ON o.id = e.office_id 
  INNER JOIN countries AS c ON o.country_id = c.id 
group by 
  country, 
  office_address
ORDER BY 
  total_employees DESC, 
  country
LIMIT 
  5;

```

<p align="center">
 <img src="src/results/result3.png" alt="result_3"/>
</p>

4. Three supervisors with the most amount of employees they are in charge.

```sql
SELECT 
  supervisor_id, 
  COUNT(*) AS employees_in_charge 
FROM 
  employees 
WHERE 
  supervisor_id IS NOT NULL 
group by 
  supervisor_id 
ORDER BY 
  employees_in_charge DESC 
LIMIT 
  3;

```

<p align="center">
 <img src="src/results/result4.png" alt="result_4"/>
</p>

5. How many offices are in the state of Colorado (United States).

```sql
SELECT 
  count(*) AS list_of_office 
FROM 
  offices AS o 
  INNER JOIN states AS s ON o.state_id = s.id 
  INNER JOIN countries AS c ON o.country_id = c.id 
WHERE 
  s.name = 'Colorado' 
  AND c.name = 'United States';
```

<p align="center">
 <img src="src/results/result5.png" alt="result_5"/>
</p>

6. The name of the office with its number of employees ordered in a desc.

```SQL
SELECT
  o.name AS office_name,
  COUNT(*) AS employees_count
FROM
  offices AS o
  INNER JOIN employees AS e ON o.id = e.office_id
GROUP BY
  office_name
ORDER BY
  employees_count DESC;

```

<p align="center">
 <img src="src/results/result6.png" alt="result_6"/>
</p>

7. The office with more and less employees.

```sql
WITH office_count AS (
  SELECT 
    o.address AS office_address,
    COUNT(*) AS total_employees
  FROM
    offices AS o
    INNER JOIN employees AS e ON o.id = e.office_id
  GROUP BY
    office_address
) (
  SELECT
    *
  FROM 
    office_count 
  ORDER BY 
    total_employees DESC
  LIMIT 
    1
) 
UNION 
  (
    SELECT 
      * 
    FROM 
      office_count 
    ORDER BY 
      total_employees
    LIMIT 
      1
  );
```

<p align="center">
 <img src="src/results/result7.png" alt="result_7"/>
</p>

8. Show the uuid of the employee, first_name and lastname combined, email, job_title, the name of the office they belong to, the name of the country, the name of the state and the name of the boss (boss_name)

```sql
WITH offices_by_countries_with_states AS (
  SELECT 
    o.id AS office_id, 
    o.name AS office_name, 
    c.name AS country_name, 
    s.name AS state_name 
  FROM 
    offices AS o 
    INNER JOIN countries AS c ON o.country_id = c.id 
    LEFT JOIN states AS s ON o.state_id = s.id
) 
SELECT 
  e.uuid, 
  CONCAT(e.first_name, ' ', e.last_name) AS full_name, 
  e.email, 
  e.job_title, 
  o.office_name AS company, 
  o.country_name AS country, 
  o.state_name AS state, 
  supervisors.first_name AS boss_name 
FROM 
  employees AS e 
  INNER JOIN offices_by_countries_with_states AS o ON e.office_id = o.office_id 
  LEFT JOIN employees AS supervisors ON e.supervisor_id = supervisors.id 
WHERE 
  supervisors.first_name IS NOT NULL;
```

<p align="center">
 <img src="src/results/result8.png" alt="result_8"/>
</p>
