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
SELECT c.name, COUNT(c.id)
FROM countries c
         INNER JOIN states s
                    ON s.country_id = c.id
GROUP BY c.name;
```

<p align="center">
 <img src="src/results/result1.png" alt="result_1"/>
</p>

2. How many employees do not have supervisores.

```
SELECT COUNT(*) AS "employees_without_boss"
FROM employees em
WHERE supervisor_id IS NULL;
```

<p align="center">
 <img src="src/results/result2.png" alt="result_2"/>
</p>

3. List the top five offices address with the most amount of employees, order the result by country and display a column with a counter.

```
SELECT co.name, address, COUNT(em.id) AS count
FROM countries co
         INNER JOIN offices of
                    ON of.country_id = co.id
         INNER JOIN employees em
                    ON em.office_id = of.id
GROUP BY co.name, address
ORDER BY count DESC
LIMIT 5;

```

<p align="center">
 <img src="src/results/result3.png" alt="result_3"/>
</p>

4. Three supervisors with the most amount of employees they are in charge.

```
SELECT em.supervisor_id, COUNT(*) AS count
FROM employees em
WHERE em.supervisor_id IS NOT NULL
GROUP BY em.supervisor_id
ORDER BY count DESC
LIMIT 3;
```

<p align="center">
 <img src="src/results/result4.png" alt="result_4"/>
</p>

5. How many offices are in the state of Colorado (United States).

```
SELECT COUNT(*) AS list_of_office
FROM states st
         INNER JOIN offices of
                    ON of.state_id = st.id
WHERE st.name = 'Colorado';
```

<p align="center">
 <img src="src/results/result5.png" alt="result_5"/>
</p>

6. The name of the office with its number of employees ordered in a desc.

```
SELECT of.name, COUNT(*) as count
FROM offices of
         INNER JOIN employees em
                    ON em.office_id = of.id
GROUP BY of.name
ORDER BY count DESC;
```

<p align="center">
 <img src="src/results/result6.png" alt="result_6"/>
</p>

7. The office with more and less employees.

```
(SELECT of.address, COUNT(*) AS count
 FROM offices of
          INNER JOIN employees em
                     ON em.office_id = of.id
 GROUP BY of.address
 ORDER BY count DESC
 LIMIT 1)
UNION ALL
(SELECT offices.address,
        COUNT(*) AS count
 FROM offices
          INNER JOIN employees em
                     ON em.office_id = offices.id
 GROUP BY offices.address
 ORDER BY count
 LIMIT 1);
```

<p align="center">
 <img src="src/results/result7.png" alt="result_7"/>
</p>

8. Show the uuid of the employee, first_name and lastname combined, email, job_title, the name of the office they belong to, the name of the country, the name of the state and the name of the boss (boss_name)

```
 SELECT em.uuid,
       CONCAT(em.first_name, ' ', em.last_name) as full_name,
       em.email,
       em.job_title,
       of.name                                  as company,
       co.name                                  as country,
       st.name                                  as state,
       su.first_name                            as boss_name
FROM employees em
         INNER JOIN offices of
                    ON of.id = em.id
         INNER JOIN countries co
                    ON co.id = of.country_id
         INNER JOIN states st
                    ON st.id = of.state_id
         INNER JOIN employees su ON em.supervisor_id = su.id
WHERE em.supervisor_id IS NOT NULL;
```

<p align="center">
 <img src="src/results/result8.png" alt="result_8"/>
</p>
