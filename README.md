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

```sql
SELECT c.name,
    COUNT(c.name)
FROM countries c
    INNER JOIN states s ON c.id = s.country_id
GROUP BY c.name;
```

<p align="center">
 <img src="src/results/result1.png" alt="result_1"/>
</p>

2. How many employees do not have supervisores.

```sql
SELECT COUNT(*) employees_without_bosses
FROM employees
WHERE supervisor_id IS NULL;
```

<p align="center">
 <img src="src/results/result2.png" alt="result_2"/>
</p>

3. List the top five offices address with the most amount of employees, order the result by country and display a column with a counter.

```sql
SELECT c.name,
    o.address,
    COUNT(e.id) as count
FROM employees e
    INNER JOIN offices o ON e.office_id = o.id
    INNER JOIN countries c ON c.id = o.country_id
GROUP BY c.name,
    o.address
ORDER BY count DESC,
    c.name
LIMIT 5;
```

<p align="center">
 <img src="src/results/result3.png" alt="result_3"/>
</p>

4. Three supervisors with the most amount of employees they are in charge.

```sql
SELECT e.supervisor_id,
    COUNT(e.id) as count
FROM employees e
WHERE e.supervisor_id IS NOT NULL
GROUP BY e.supervisor_id
ORDER BY count DESC
LIMIT 3;
```

<p align="center">
 <img src="src/results/result4.png" alt="result_4"/>
</p>

5. How many offices are in the state of Colorado (United States).

```sql
SELECT COUNT(*) offices_in_colorado
FROM offices o
    INNER JOIN states s ON o.state_id = s.id
WHERE s.name = 'Colorado';
```

<p align="center">
 <img src="src/results/result5.png" alt="result_5"/>
</p>

6. The name of the office with its number of employees ordered in a desc.

```sql
SELECT o.name,
    COUNT(o.name) as count
FROM offices o
    INNER JOIN employees e ON e.office_id = o.id
GROUP BY o.name
ORDER BY count DESC;
```

<p align="center">
 <img src="src/results/result6.png" alt="result_6"/>
</p>

7. The office with more and less employees.

```sql

WITH counts AS (
    SELECT o.address, COUNT(o.id) AS count
    FROM offices o
        INNER JOIN employees e ON e.office_id = o.id
    GROUP BY o.address
	ORDER BY count
) 
(
    SELECT * FROM counts
	ORDER BY count DESC
	LIMIT 1 
)
UNION ALL
(
	SELECT * FROM counts
	LIMIT 1 
);
```

<p align="center">
 <img src="src/results/result7.png" alt="result_7"/>
</p>

8. Show the uuid of the employee, first_name and lastname combined, email, job_title, the name of the office they belong to, the name of the country, the name of the state and the name of the boss (boss_name)

```sql
SELECT e.uuid,
    e.first_name || ' ' || e.last_name as full_name,
    e.email,
    e.job_title,
    o.name as company,
    c.name country,
    s.name as state,
    es.first_name as boss_name
FROM employees e
    INNER JOIN offices o ON e.office_id = o.id
    INNER JOIN countries c ON c.id = o.country_id
    INNER JOIN employees es ON e.supervisor_id = es.id
    INNER JOIN states s ON s.id = o.state_id
```

<p align="center">
 <img src="src/results/result8.png" alt="result_8"/>
</p>
