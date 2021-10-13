##########################################################
##########################################################
##########################################################

# MySQL for Data Analytics and Business Intelligence

##########################################################
##########################################################
##########################################################


-- SECTION 1.1: Creating a Database

CREATE DATABASE IF NOT EXISTS Sales;

CREATE SCHEMA IF NOT EXISTS Sales;

USE Sales;

-- SECTION 1.2: Creating tables

CREATE TABLE sales
(
	purchase_number INT AUTO_INCREMENT,
    date_of_purchase DATE,
    customer_id INT,
    item_code VARCHAR(10),
PRIMARY KEY (purchase_number)
);

SELECT * FROM sales.sales;

CREATE TABLE items (
    item_id VARCHAR(255),
    item VARCHAR(255),
    unit_price NUMERIC(10 , 2 ),
    company_id VARCHAR(255),
PRIMARY KEY (item_id)
);

 -- SECTION 1.3: UNIQUE KEY Constraint
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT,
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    email_address VARCHAR(255),
    number_of_complaints INT,
PRIMARY KEY (customer_id)
);

ALTER TABLE customers
ADD COLUMN gender ENUM('M', 'F') AFTER last_name;
 
INSERT INTO customers (first_name, last_name, gender, email_address, number_of_complaints)
VALUES ('John', 'Mackinley', 'M', 'john.mckinley@365careers.com', 0)
;

ALTER TABLE customers
CHANGE COLUMN number_of_complaints number_of_complaints INT DEFAULT 0;

INSERT INTO customers (first_name, last_name, gender) 
VALUES	('Peter', 'Figaro', 'M')
;

SELECT * FROM customers;

-- SECTION 1.4: DEFAULT Constraint
CREATE TABLE companies
(
	company_id INT AUTO_INCREMENT,
    headquarters_phone_number VARCHAR(255),
    company_name VARCHAR(255) NOT NULL,
PRIMARY KEY (company_id)
);

ALTER TABLE companies
MODIFY company_name VARCHAR(255) NULL;

ALTER TABLE companies
CHANGE COLUMN company_name company_name VARCHAR(255) NOT NULL;

INSERT INTO companies (headquarters_phone_number, company_name)
VALUES	('+1 (202) 555-0196', 'Company A')
;

SELECT * FROM companies;

ALTER TABLE companies
MODIFY headquarters_phone_number VARCHAR(255) NULL;

ALTER TABLE companies
CHANGE COLUMN headquarters_phone_number headquarters_phone_number VARCHAR(255) NOT NULL;


##########################################################
##########################################################

-- SECTION 2: Aggregate Function with 'employees' Database

USE employees;

-- Using FROM / AND / OR / BETWEEN-AND

SELECT first_name, last_name FROM employees;
    
SELECT * FROM employees LIMIT 20;

SELECT dept_no FROM departments;
SELECT DISTINCT gender FROM employees;

SELECT * FROM employees
WHERE first_name <=> 'Denis'; 

SELECT * FROM employees
WHERE first_name = 'Denis' AND gender = 'M';
    
SELECT * FROM employees
WHERE first_name = 'Denis' OR first_name = 'Elvis';

SELECT  * FROM employees
WHERE last_name = 'Denis' AND gender = 'M' OR gender = 'F';

SELECT   dept_name FROM departments
WHERE dept_no BETWEEN 'd003' AND 'd006';
 
 -- Using: IN / LIKE / NULL
 
SELECT   * FROM  employees 
WHERE  first_name IN ('Cathie' , 'Mark', 'Nathan');

SELECT   * FROM  employees 
WHERE  first_name NOT IN ('Cathie' , 'Mark', 'Nathan');


SELECT  * FROM employees
WHERE  first_name LIKE('Mar%');
    
SELECT   *  FROM employees
WHERE first_name LIKE('%ar%');

SELECT  * FROM  employees
WHERE  hire_date LIKE ('%2000%');

    
SELECT   * FROM employees
WHERE first_name IS NOT NULL;

SELECT  dept_name  FROM departments
WHERE  dept_no IS NULL;
    
-- Using COUNT / GROUP BY / ORDER BY

SELECT COUNT(first_name) FROM employees;

SELECT COUNT(DISTINCT first_name) FROM employees;


SELECT  * FROM employees
ORDER BY first_name , last_name ASC;

SELECT   first_name, COUNT(first_name) FROM employees
GROUP BY first_name
ORDER BY first_name DESC;


--  Using Aliases (AS)
SELECT  salary, COUNT(emp_no) AS emps_with_same_salary
FROM  salaries
WHERE  salary > 80000
GROUP BY salary
ORDER BY salary;

--  Using HAVING

SELECT  first_name, COUNT(first_name) as names_count
FROM  employees
GROUP BY first_name
HAVING COUNT(first_name) > 250
ORDER BY first_name;

# When using WHERE instead of HAVING, the output is larger because in the output we include 
# individual contracts higher than $120,000 per year. The output does not contain average salary values.

-- Using INSERT 

CREATE TABLE departments_dup 
(
    dept_no CHAR(4) NOT NULL,
    dept_name VARCHAR(40) NOT NULL
);

INSERT INTO departments_dup
(
    dept_no,
    dept_name
)
SELECT * FROM  departments;

-- Using: SUM / MIN / MAX / AVG / ROUND

SELECT  SUM(salary) FROM salaries
WHERE
    from_date > '1997-01-01';

SELECT  MAX(salary) FROM  salaries;

SELECT  ROUND(AVG(salary), 2) FROM salaries
WHERE  from_date > '1997-01-01';


-- Using: COALESCE
ALTER TABLE departments_dup
CHANGE COLUMN dept_name dept_name VARCHAR(40) NULL;
 
INSERT INTO departments_dup(dept_no) VALUES ('d010'), ('d011');

SELECT  * FROM  departments_dup
ORDER BY dept_no ASC; 

ALTER TABLE employees.departments_dup 
ADD COLUMN dept_manager VARCHAR(255) NULL AFTER dept_name;

SELECT   * FROM  departments_dup
ORDER BY dept_no;

SELECT  dept_no,  IFNULL(dept_name,'Department name not provided') AS dept_name
FROM departments_dup;


SELECT  dept_no,  COALESCE(dept_name, 'Department name not provided') AS dept_name
FROM  departments_dup;

SELECT 
    dept_no, dept_name, COALESCE(dept_manager, dept_name, 'N/A') AS dept_manager
FROM  departments_dup
ORDER BY dept_no ASC;

##########################################################
##########################################################

-- SECTION 3: SQl Joins 2 Table

-- Setting up table 
ALTER TABLE departments_dup
DROP COLUMN dept_manager;

ALTER TABLE departments_dup
CHANGE COLUMN dept_no dept_no CHAR(4) NULL;

ALTER TABLE departments_dup
CHANGE COLUMN dept_name dept_name VARCHAR(40) NULL;

DROP TABLE IF EXISTS dept_manager_dup;
CREATE TABLE dept_manager_dup (
  emp_no int(11) NOT NULL,
  dept_no char(4) NULL,
  from_date date NOT NULL,
  to_date date NULL
  );

INSERT INTO dept_manager_dup
select * from dept_manager;

INSERT INTO dept_manager_dup (emp_no, from_date)
VALUES  (999904, '2017-01-01'),
		(999905, '2017-01-01'),
        (999906, '2017-01-01'),
       	(999907, '2017-01-01');


-- Using: INNER JOIN

SELECT m.dept_no, m.emp_no, d.dept_name
FROM dept_manager_dup m
        INNER JOIN departments_dup d ON m.dept_no = d.dept_no
ORDER BY m.dept_no;

-- add m.to_date and d.dept_name
SELECT  m.dept_no, m.emp_no, m.from_date, m.to_date, d.dept_name
FROM  dept_manager_dup m 
INNER JOIN  departments_dup d ON m.dept_no = d.dept_no
ORDER BY m.dept_no;


-- Using: LEFT JOIN

-- remove the duplicates from the two tables
DELETE FROM dept_manager_dup 
WHERE emp_no = '110228';
        
DELETE FROM departments_dup 
WHERE dept_no = 'd009';

-- add back the initial records
INSERT INTO dept_manager_dup 
VALUES 	('110228', 'd003', '1992-03-21', '9999-01-01');
        
INSERT INTO departments_dup 
VALUES	('d009', 'Customer Service');

SELECT   m.dept_no, m.emp_no, d.dept_name
FROM departments_dup d
LEFT JOIN  dept_manager_dup m ON m.dept_no = d.dept_no
ORDER BY m.dept_no;


SELECT  d.dept_no, m.emp_no, d.dept_name
FROM  departments_dup d
LEFT OUTER JOIN dept_manager_dup m ON m.dept_no = d.dept_no
ORDER BY d.dept_no;


-- Using: RIGHT JOIN

SELECT   d.dept_no, m.emp_no, d.dept_name
FROM  dept_manager_dup m
RIGHT JOIN departments_dup d ON m.dept_no = d.dept_no
ORDER BY dept_no;


-- Using: CROSS JOIN
SELECT   dm.*, d.*
FROM departments d
CROSS JOIN dept_manager dm
WHERE d.dept_no <> dm.dept_no
ORDER BY dm.emp_no , d.dept_no;




##########################################################
##########################################################

-- SECTION 4: SQL joins more than Two Tables in SQL

SELECT e.first_name, e.last_name,  e.hire_date, m.from_date, d.dept_name
FROM departments d
RIGHT JOIN dept_manager m ON d.dept_no = m.dept_no
JOIN  employees e ON m.emp_no = e.emp_no;

SELECT   d.dept_name, AVG(salary)
FROM departments d
JOIN dept_manager m ON d.dept_no = m.dept_no
JOIN salaries s ON m.emp_no = s.emp_no
GROUP BY d.dept_name
ORDER BY d.dept_no;

-- add HAVING average_salary > 60000
SELECT  d.dept_name, AVG(salary) AS average_salary
FROM  departments d
JOIN dept_manager m ON d.dept_no = m.dept_no
JOIN salaries s ON m.emp_no = s.emp_no
GROUP BY dept_name
HAVING average_salary > 60000
ORDER BY average_salary DESC;

-- Using UNION ALL
DROP TABLE IF EXISTS employees_dup;
CREATE TABLE employees_dup (
   emp_no int(11),
   birth_date date,
   first_name varchar(14),
   last_name varchar(16),
   gender enum('M','F'),
   hire_date date
  );
  
INSERT INTO employees_dup 
SELECT   e.* FROM  employees e LIMIT 20;



INSERT INTO employees_dup VALUES
('10001', '1953-09-02', 'Georgi', 'Facello', 'M', '1986-06-26');
    
SELECT e.emp_no, e.first_name,e.last_name,NULL AS dept_no,NULL AS from_date
FROM employees_dup e
WHERE e.emp_no = 10001 
UNION ALL SELECT  NULL AS emp_no, NULL AS first_name, NULL AS last_name, m.dept_no, m.from_date
FROM dept_manager m;
    

SELECT e.emp_no, e.first_name,e.last_name,NULL AS dept_no,NULL AS from_date
FROM employees_dup e
WHERE e.emp_no = 10001 
UNION SELECT   NULL AS emp_no,  NULL AS first_name, NULL AS last_name,  m.dept_no,  m.from_date
FROM  dept_manager m;

##########################################################
##########################################################

-- SECTION 5: Subqueries
-- Using Subqueries with IN nested inside WHERE

SELECT  e.first_name, e.last_name FROM  employees e
WHERE e.emp_no IN (SELECT dm.emp_no  FROM dept_manager dm);
                
-- add ORDER BY emp_no
SELECT   e.first_name, e.last_name FROM  employees e
WHERE EXISTS( SELECT *  FROM  dept_manager dm WHERE  dm.emp_no = e.emp_no
        ORDER BY emp_no);



-- EXERCISE 1: Subqueries with IN nested inside WHERE
SELECT 
    *
FROM
    employees e
WHERE
    EXISTS( SELECT 
            *
        FROM
            titles t
        WHERE
            t.emp_no = e.emp_no
                AND title = 'Assistant Engineer');


###########
-- Using: Subqueries nested in SELECT and FROM

SELECT  e.emp_no AS employee_ID, MIN(de.dept_no) AS department_code, (SELECT emp_no
        FROM  dept_manager
        WHERE  emp_no = 110022) AS manager_ID
FROM employees e
JOIN  dept_emp de ON e.emp_no = de.emp_no
WHERE  e.emp_no <= 10020
GROUP BY e.emp_no
ORDER BY e.emp_no;


########## END #########



