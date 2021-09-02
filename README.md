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

select countries.name, count(countries.name) 
from countries 
inner join states on countries.id = states.country_id 
group by countries.name;

```

<p align="center">
 <img src="src/results/result1.png" alt="result_1"/>
</p>

2. How many employees do not have supervisores.

```

select count(*) as employees_without_bosses 
from employees 
where supervisor_id is null;

```

<p align="center">
 <img src="src/results/result2.png" alt="result_2"/>
</p>

3. List the top five offices address with the most amount of employees, order the result by country and display a column with a counter.

```

select countries.name, offices.address, count(employees.id) 
from offices inner join employees on offices.id = employees.office_id 
inner join countries on countries.id = offices.country_id 
group by countries.name, offices.address  
order by  count(employees.id) desc limit 5;

```

<p align="center">
 <img src="src/results/result3.png" alt="result_3"/>
</p>

4. Three supervisors with the most amount of employees they are in charge.

```

select supervisor_id, count(supervisor_id) as count
from employees
group by supervisor_id
order by count desc
limit 3;

```

<p align="center">
 <img src="src/results/result4.png" alt="result_4"/>
</p>

5. How many offices are in the state of Colorado (United States).

```

select count(offices.id) as list_of_office 
from offices 
inner join states 
on offices.state_id = states.id 
where states.name='Colorado';

```

<p align="center">
 <img src="src/results/result5.png" alt="result_5"/>
</p>

6. The name of the office with its number of employees ordered in a desc.

```

select offices.name, count(employees.id) 
from offices 
inner join employees on offices.id = employees.office_id 
group by offices.name 
order by count(employees.id) desc;

```

<p align="center">
 <img src="src/results/result6.png" alt="result_6"/>
</p>

7. The office with more and less employees.

```

(select o.address, count(e.office_id) as count 
from offices as o 
inner join employees as e 
on o.id=e.office_id
group by o.address 
order by count desc   
limit 1)

union all 

(select o.address, count(e.office_id) as count 
from offices as o
inner join employees as e
on o.id=e.office_id 
group by o.address 
order by count  
limit 1) ;

```

<p align="center">
 <img src="src/results/result7.png" alt="result_7"/>
</p>

8. Show the uuid of the employee, first_name and lastname combined, email, job_title, the name of the office they belong to, the name of the country, the name of the state and the name of the boss (boss_name)

```

select e.uuid, concat(e.first_name, ' ', e.last_name) as full_name, e.email, e.job_title, o.name as company, c.name as country, s.name as state, boss.first_name as boos_name
from employees as e
inner join employees as boss on e.supervisor_id = boss.id
inner join offices as o on o.id = e.office_id 
inner join countries as c on o.country_id = c.id
inner join states as s on s.id=o.state_id;

```

<p align="center">
 <img src="src/results/result8.png" alt="result_8"/>
</p>
