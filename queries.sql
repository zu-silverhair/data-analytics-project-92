---считает общее количество покупателей из таблицы customers

select
	count(customer_id) as "customers_count"
from public.customers
;



---Первый отчет о десятке лучших продавцов. Таблица состоит из трех колонок - данных о продавце, суммарной выручке с проданных товаров и количестве проведенных сделок, и отсортирована по убыванию выручки
---seller — имя и фамилия продавца
---operations - количество проведенных сделок
---income — суммарная выручка продавца за все время
select
concat(first_name,' ',last_name) as seller,
count(public.sales.sales_person_id) as operations,
sum(public.products.price*public.sales.quantity) as income
from public.employees
inner join public.sales on public.employees.employee_id = public.sales.sales_person_id 
inner join public.products on public.sales.product_id = public.products.product_id 
group by seller
order by income desc 
;



---Второй отчет содержит информацию о продавцах, чья средняя выручка за сделку меньше средней выручки за сделку по всем продавцам. Таблица отсортирована по выручке по возрастанию.
---seller — имя и фамилия продавца
---average_income — средняя выручка продавца за сделку с округлением до целого
select
concat(first_name,' ',last_name) as seller,
ROUND(avg(public.products.price*public.sales.quantity),0) as average_income
from public.employees
inner join public.sales on public.employees.employee_id = public.sales.sales_person_id 
inner join public.products on public.sales.product_id = public.products.product_id 
group by seller
having ROUND(avg(public.products.price*public.sales.quantity),0) < (select
																		ROUND(avg(public.products.price*public.sales.quantity),0)
																	from public.sales
																	inner join public.products on public.sales.product_id = public.products.product_id)
order by average_income
;



---Третий отчет содержит информацию о выручке по дням недели. Каждая запись содержит имя и фамилию продавца, день недели и суммарную выручку. Отсортируйте данные по порядковому номеру дня недели и seller
---seller — имя и фамилия продавца
---day_of_week — название дня недели на английском языке
---income — суммарная выручка продавца в определенный день недели, округленная до целого числа
with tb_1 as(
select
concat(first_name,' ',last_name) as seller,
to_char(public.sales.sale_date,'day') as day_of_week,
floor(sum(public.products.price*public.sales.quantity)) as income,
extract (dow from public.sales.sale_date) as numb
from public.employees
inner join public.sales on public.employees.employee_id = public.sales.sales_person_id 
inner join public.products on public.sales.product_id = public.products.product_id 
group by seller, day_of_week, numb
) select 
	seller,
	day_of_week,
	income
 from tb_1
order  by numb, seller
;































