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
SELECT countries.name,
       COUNT(*)
FROM countries
INNER JOIN states ON countries.id = states.country_id
GROUP BY countries.name;
```

<p align="center">
 <img src="src/results/result1.png" alt="result_1"/>
</p>

2. How many employees do not have supervisores.

```
SELECT COUNT(*) AS employees_without_bosses
FROM employees
WHERE employees.supervisor_id IS NULL;
```

<p align="center">
 <img src="src/results/result2.png" alt="result_2"/>
</p>

3. List the top five offices address with the most amount of employees, order the result by country and display a column with a counter.

```
SELECT countries.name,
       offices.address,
       count(*)
FROM employees
INNER JOIN offices ON employees.office_id = offices.id
INNER JOIN countries ON offices.country_id = countries.id
GROUP BY countries.name,
         offices.address
ORDER BY count(*) DESC
LIMIT 5;
```

<p align="center">
 <img src="src/results/result3.png" alt="result_3"/>
</p>

4. Three supervisors with the most amount of employees they are in charge.

```
SELECT supervisor.id AS supervisor_id,
       count(*)
FROM employees
INNER JOIN employees AS supervisor ON employees.supervisor_id = supervisor.id
GROUP BY supervisor.id
ORDER BY count(*) DESC
LIMIT 3;
```

<p align="center">
 <img src="src/results/result4.png" alt="result_4"/>
</p>

5. How many offices are in the state of Colorado (United States).

```
SELECT count(*) AS list_of_office
FROM offices                                                             
WHERE offices.state_id  IN                                              
    (SELECT states.id
     FROM states INNER JOIN countries ON countries.id = states.country_id
     WHERE states.name LIKE 'Colorado%' AND countries.name='United States');
```

<p align="center">
 <img src="src/results/result5.png" alt="result_5"/>
</p>

6. The name of the office with its number of employees ordered in a desc.

```
SELECT offices.name,
       count(*)
FROM offices
INNER JOIN employees ON offices.id = employees.office_id
GROUP BY offices.name
ORDER BY count(*) DESC;
```

<p align="center">
 <img src="src/results/result6.png" alt="result_6"/>
</p>

7. The office with more and less employees.

```
WITH number_of_employees_per_address AS
  (SELECT offices.address,
          count(*)
   FROM offices
   INNER JOIN employees ON offices.id = employees.office_id
   GROUP BY offices.address)
  (SELECT *
   FROM number_of_employees_per_address
   ORDER BY COUNT DESC
   LIMIT 1)
UNION ALL
  (SELECT address,
          COUNT
   FROM number_of_employees_per_address
   ORDER BY COUNT ASC
   LIMIT 1);
```

<p align="center">
 <img src="src/results/result7.png" alt="result_7"/>
</p>

8. Show the uuid of the employee, first_name and lastname combined, email, job_title, the name of the office they belong to, the name of the country, the name of the state and the name of the boss (boss_name)

```
SELECT employees.uuid,
       employees.first_name || ' ' || employees.last_name AS full_name,
       employees.email,
       employees.job_title,
       offices.name AS company,
       countries.name AS country,
       states.name AS state,
       boss.first_name AS boss_name
FROM employees
LEFT JOIN offices ON employees.office_id=offices.id
LEFT JOIN countries ON offices.country_id = countries.id
LEFT JOIN states ON offices.state_id = states.id
LEFT JOIN employees AS boss ON employees.id = boss.id;
```

<p align="center">
 <img src="src/results/result8.png" alt="result_8"/>
</p>
