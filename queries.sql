--ШАГ 4--

---Напишите запрос, который считает общее количество покупателей из таблицы customers. Назовите колонку customers_count
select
	count(customer_id) as "customers_count"
from public.customers
;

--ШАГ 5--

---Первый отчет о десятке лучших продавцов. Таблица состоит из трех колонок - данных о продавце, суммарной выручке с проданных товаров и количестве проведенных сделок, и отсортирована по убыванию выручки
---seller — имя и фамилия продавца
---operations - количество проведенных сделок
---income — суммарная выручка продавца за все время
select
concat(first_name,' ',last_name) as seller,
count(public.sales.sales_person_id) as operations,
floor(sum(public.products.price*public.sales.quantity)) as income
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
floor(avg(public.products.price*public.sales.quantity)) as average_income
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



--ШАГ 6--

---Первый отчет - количество покупателей в разных возрастных группах: 16-25, 26-40 и 40+. Итоговая таблица должна быть отсортирована по возрастным группам и содержать следующие поля:
---age_category - возрастная группа
---count - количество человек в группе
	select
	  	(case
		  when public.customers.age between 16 and 25 then '16-25'
		  when public.customers.age between 26 and 40 then '26-40' 
		  when public.customers.age > 40 then '40+' 
		 end) as age_category,
  	 	count(public.customers.customer_id) as age_count
  	from public.customers
	group by age_category
  	order by age_category
  	;

  
  
---Во втором отчете предоставьте данные по количеству уникальных покупателей и выручке, которую они принесли. Сгруппируйте данные по дате, которая представлена в числовом виде ГОД-МЕСЯЦ. 
--Итоговая таблица должна быть отсортирована по дате по возрастанию и содержать следующие поля:
---date - дата в указанном формате
---total_customers - количество покупателей
---income - принесенная выручка
  select 
  to_char (public.sales.sale_date, 'YYYY-MM') as selling_month,
  count(distinct public.sales.customer_id) as total_customers,
  floor(sum(public.sales.quantity * public.products.price)) as income 
  from public.sales
  inner join public.products on public.sales.product_id = public.products.product_id
  group by selling_month
  order by selling_month
  ;
 
 
 
 ---Третий отчет следует составить о покупателях, первая покупка которых была в ходе проведения акций (акционные товары отпускали со стоимостью равной 0).
 --- Итоговая таблица должна быть отсортирована по id покупателя. Таблица состоит из следующих полей:
---customer - имя и фамилия покупателя
---sale_date - дата покупки
---seller - имя и фамилия продавца
 with row_group as(
 select 
 --public.sales.customer_id,
 concat(public.customers.first_name,' ',public.customers.last_name) as customer,
 public.sales.sale_date,
 concat(public.employees.first_name,' ',public.employees.last_name) as seller--, 
 --public.products.price
 from public.sales
 inner join public.customers on public.sales.customer_id = public.customers.customer_id 
 inner join public.employees on public.sales.sales_person_id = public.employees.employee_id 
 inner join public.products on public.sales.product_id = public.products.product_id 
 where public.products.price = 0
group by public.sales.customer_id, public.customers.first_name, public.customers.last_name,  public.sales.sale_date, public.employees.first_name, public.employees.last_name, public.products.price
order by public.sales.customer_id, public.products.price
), rn_tab as(
select 
customer,
sale_date,
seller,
ROW_NUMBER() over (PARTITION by customer) as rn 
from row_group
group by customer, sale_date, seller)
select 
customer,
sale_date,
seller
from rn_tab 
where rn = 1
;
 

























