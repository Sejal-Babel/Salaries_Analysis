use employees_mod;



-- Businees Question: How has gender distribution of employees changed over time in each department (from 1990 onwards)? 

SELECT 
    d.dept_name, YEAR(de.from_date) AS calendar_year,
    e.gender,
    COUNT(e.emp_no) as emp_count
FROM
    t_employees e
        JOIN
    t_dept_emp de ON de.emp_no = e.emp_no
        JOIN 
	t_departments d on de.dept_no=d.dept_no
GROUP BY d.dept_name, calendar_year, e.gender
HAVING calendar_year >= '1990'
ORDER BY d.dept_name,calendar_year, e.gender;
 
 
-- How does the number of male and female managers vary across departments over time?
 
SELECT 
    d.dept_name AS dept_name,
    e.gender AS gender,
    dm.emp_no,
    dm.from_date,
    dm.to_date,
    cy.calendar_year,
    CASE
        WHEN cy.calendar_year BETWEEN YEAR(dm.from_date) AND YEAR(dm.to_date) THEN 1
        ELSE 0
    END AS active
FROM
    (SELECT 
        YEAR(e.hire_date) AS calendar_year
    FROM
        t_employees e
	  group by calendar_year) cy
        CROSS JOIN
    t_dept_manager dm
        JOIN
    t_employees e ON dm.emp_no = e.emp_no
        JOIN
    t_departments d ON d.dept_no = dm.dept_no
WHERE
    cy.calendar_year >= '1990'
ORDER BY dm.emp_no, cy.calendar_year;



-- How does average salary differ between male and female employees across departments?

SELECT 
    e.gender,
    d.dept_name,
    ROUND(AVG(s.salary), 2) AS salary,
    YEAR(s.from_date) AS calendar_year
FROM
    t_salaries s
        JOIN
    t_employees e ON s.emp_no = e.emp_no
        JOIN
    t_dept_emp de ON de.emp_no = e.emp_no
        JOIN
    t_departments d ON d.dept_no = de.dept_no
GROUP BY d.dept_no, e.gender, calendar_year
HAVING calendar_year <= 2002
ORDER BY d.dept_no;



-- How does the average salary of each department compare with the overall company average salary?

with avg_salary_cte as
(select round(avg(salary),2) as avg_salary
from t_salaries) 
select a.dept_name, a.dept_avg_salary, c.avg_salary as company_average, c.avg_salary-a.dept_avg_salary as difference
from (
select d.dept_no, d.dept_name, round(avg(s.salary),2) as dept_avg_salary
from t_salaries s 
join t_dept_emp de on s.emp_no=de.emp_no 
join t_departments d on de.dept_no=d.dept_no
group by d.dept_no) a
join avg_salary_cte c;






-- How does the average salary differ across departments within selected salary ranges using procedure?
drop procedure if exists avg_salary_in_range;
delimiter $$
create procedure avg_salary_in_range(in range_1 float, in range_2 float)
begin 
   select d.dept_name, e.gender, round(avg(s.salary),2) as avg_salary 
   from t_employees e 
   join t_dept_emp de on de.emp_no=e.emp_no 
   join t_departments d on d.dept_no=de.dept_no 
   join t_salaries s on s.emp_no=e.emp_no 
   group by d.dept_name, e.gender
   having avg(s.salary) between range_1 and range_2
   order by d.dept_no, e.gender;
end $$
delimiter ;
   






