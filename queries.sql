--ШАГ 4--
---считает общее количество покупателей из таблицы customers
select count(customer_id) as "customers_count"
from public.customers;

--ШАГ 5--
---Первый отчет о десятке лучших продавцов.
select
    concat(public.employees.first_name, ' ', public.employees.last_name)
    as seller,
    count(public.sales.sales_person_id)
    as operations,
    floor(sum(public.products.price * public.sales.quantity))
    as income
from public.employees
inner join public.sales
    on public.employees.employee_id = public.sales.sales_person_id
inner join public.products
    on public.sales.product_id = public.products.product_id
group by seller
order by income desc
limit 10;

---отчет о продавцах,средняя выручка меньше средней выручкипо всем продавцам
select
    concat(public.employees.first_name, ' ', public.employees.last_name)
    as seller,
    floor(avg(public.products.price * public.sales.quantity)) as average_income
from public.employees
inner join public.sales
    on public.employees.employee_id = public.sales.sales_person_id
inner join public.products
    on public.sales.product_id = public.products.product_id
group by seller
having
    round(avg(public.products.price * public.sales.quantity), 0) < (
        select round(avg(public.products.price * public.sales.quantity), 0)
        from public.sales
        inner join public.products
            on public.sales.product_id = public.products.product_id
    )
order by average_income;

---Третий отчет содержит информацию о выручке по дням недели
with tb_1 as (
    select
        concat(public.employees.first_name, ' ', public.employees.last_name)
        as seller,
        to_char(public.sales.sale_date, 'day') as day_of_week,
        floor(sum(public.products.price * public.sales.quantity)) as income,
        extract(isodow from public.sales.sale_date) as numb
    from public.employees
    inner join public.sales
        on public.employees.employee_id = public.sales.sales_person_id
    inner join public.products
        on public.sales.product_id = public.products.product_id
    group by seller, day_of_week, numb
)

select
    seller,
    day_of_week,
    income
from tb_1
order by numb, seller;

--ШАГ 6--
---отчет количество покупателей в разных возрастных группах: 16-25, 26-40 и 40+
select
    (
        case
            when public.customers.age between 16 and 25 then '16-25'
            when public.customers.age between 26 and 40 then '26-40'
            when public.customers.age > 40 then '40+'
        end
    )
    as age_category,
    count(public.customers.customer_id) as age_count
from public.customers
group by age_category
order by age_category;

---отчет по количеству уникальных покупателей и выручке, которую они принесли
select
    to_char(public.sales.sale_date, 'YYYY-MM') as selling_month,
    count(distinct public.sales.customer_id) as total_customers,
    floor(sum(public.sales.quantity * public.products.price)) as income
from public.sales
inner join public.products
    on public.sales.product_id = public.products.product_id
group by selling_month
order by selling_month;

---отчет о покупателях, первая покупка которых была в ходе проведения акций
with row_group as (
    select
        public.sales.sale_date,
        concat(public.customers.first_name, ' ', public.customers.last_name)
        as customer,
        concat(public.employees.first_name, ' ', public.employees.last_name)
        as seller
    from public.sales
    inner join public.customers
        on public.sales.customer_id = public.customers.customer_id
    inner join public.employees
        on public.sales.sales_person_id = public.employees.employee_id
    inner join public.products
        on public.sales.product_id = public.products.product_id
    where public.products.price = 0
    group by
        public.sales.customer_id,
        public.customers.first_name,
        public.customers.last_name,
        public.sales.sale_date,
        public.employees.first_name,
        public.employees.last_name,
        public.products.price
    order by public.sales.customer_id, public.sales.sale_date
),

rn_tab as (
    select
        customer,
        sale_date,
        seller,
        row_number() over (partition by customer order by sale_date) as rn
    from row_group
)

select
    customer,
    sale_date,
    seller
from rn_tab
where rn = 1;
