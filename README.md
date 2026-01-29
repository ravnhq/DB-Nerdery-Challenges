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

```
SELECT countries.name, COUNT(country_id) 
FROM countries 
LEFT JOIN states 
ON countries.id = states.country_id 
GROUP BY countries.name;
```

<p align="center">
 <img src="src/results/result1.png" alt="result_1"/>
</p>

2. How many employees do not have supervisores.

```
SELECT COUNT(id) AS employees_without_bosses 
FROM employees 
WHERE supervisor_id IS NULL;
```

<p align="center">
 <img src="src/results/result2.png" alt="result_2"/>
</p>

3. List the top five offices address with the most amount of employees, order the result by country and display a column with a counter.

```
SELECT countries.name, offices.address, COUNT(office_id)  AS count FROM offices 
LEFT JOIN employees ON offices.id = employees.office_id 
LEFT JOIN countries ON offices.country_id = countries.id 
GROUP BY countries.name,offices.address 
ORDER BY count DESC LIMIT 5;
```

<p align="center">
 <img src="src/results/result3.png" alt="result_3"/>
</p>

4. Three supervisors with the most amount of employees they are in charge.

```
SELECT DISTINCT supervisor_id, COUNT(supervisor_id) AS count 
FROM employees 
WHERE supervisor_id IS NOT NULL 
GROUP BY supervisor_id
ORDER BY count DESC LIMIT 3; 
```

<p align="center">
 <img src="src/results/result4.png" alt="result_4"/>
</p>

5. How many offices are in the state of Colorado (United States).

```
-- 5
SELECT COUNT(offices.id) AS list_of_office FROM offices 
LEFT JOIN states ON offices.state_id = states.id 
WHERE TRIM(states.name) = 'Colorado';
```

```
-- (Inner join version) - Mentor feedback
SELECT COUNT(offices.id) AS list_of_office FROM offices
INNER JOIN states ON offices.state_id = states.id
WHERE TRIM(states.name) = 'Colorado';
```
```

-- (Inner join version but looking out for states id) - Mentor feedback + personal enhancement given that it might not find the exact string is better look it up for id
SELECT COUNT(offices.id) AS list_of_office FROM offices
INNER JOIN states ON offices.state_id = states.id
WHERE states.id = '8';
```


<p align="center">
 <img src="src/results/result5.png" alt="result_5"/>
</p>

6. The name of the office with its number of employees ordered in a desc.

```
SELECT offices.name, COUNT(office_id)  AS count FROM offices 
LEFT JOIN employees ON offices.id = employees.office_id 
GROUP BY offices.name 
ORDER BY count DESC;
```

<p align="center">
 <img src="src/results/result6.png" alt="result_6"/>
</p>

7. The office with more and less employees.

```
WITH GroupedCount AS (
    SELECT 
        o.address as Address,
        COUNT(e.id) AS employee_count
    FROM offices o
    LEFT JOIN employees e ON o.id = e.office_id
    GROUP BY o.address
    HAVING COUNT(e.id) > 0
)
(SELECT Address, employee_count FROM GroupedCount ORDER BY employee_count DESC LIMIT 1)
UNION ALL
(SELECT Address, employee_count FROM GroupedCount ORDER BY employee_count ASC LIMIT 1)
ORDER BY employee_count DESC;
```
Version without union all - Mentor feedback
```
WITH GroupedCount AS (
    SELECT 
        o.address AS office_address,
        COUNT(e.id) AS employee_count,
        ROW_NUMBER() OVER (ORDER BY COUNT(e.id) DESC) AS row_desc,
        ROW_NUMBER() OVER (ORDER BY COUNT(e.id) ASC) AS row_asc
    FROM offices o
    INNER JOIN employees e ON o.id = e.office_id
    GROUP BY o.address
)
SELECT 
    office_address AS address,
    employee_count AS count
FROM GroupedCount
WHERE row_desc = 1 OR row_asc = 1
ORDER BY employee_count DESC;
```

<p align="center">
 <img src="src/results/result7.png" alt="result_7"/>
</p>

8. Show the uuid of the employee, first_name and lastname combined, email, job_title, the name of the office they belong to, the name of the country, the name of the state and the name of the boss (boss_name)

```
SELECT e.uuid, CONCAT(e.first_name,' ',e.last_name) as full_name,
e.email,
e.job_title, 
offices.name AS office_name,
countries.name as country_name, 
states.name as state_name, 
es.first_name as supervisor_name FROM employees e 
LEFT JOIN offices ON e.office_id = offices.id 
LEFT JOIN employees es ON e.supervisor_id = es.id 
LEFT JOIN countries ON offices.country_id = countries.id 
RIGHT JOIN states ON states.country_id = countries.id;     
```

<p align="center">
 <img src="src/results/result8.png" alt="result_8"/>
</p>
