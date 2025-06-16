SELECT
COUNT(customer_id) AS customers_count 
FROM customers;
-- Вывести одну колонку. Использую функцию COUNT(), чтобы подсчитать строки в колонке customer_id, использую AS чтобы присвоить колонке с результатом имя customers_count, из таблицы customers.

------------------------------------------
top_10_total_income

SELECT CONCAT(e.first_name, ' ', e.last_name) AS seller, -- вывод Имени и Фамилии продавца в один столбец
       COUNT(s.sales_id) AS operations, -- количестве проведенных сделок,
       FLOOR(SUM(p.price * s.quantity)) AS income -- выручка с проданных товаров
FROM sales s
JOIN employees e ON s.sales_person_id = e.employee_id --соединение с таблицей employees по общему id
JOIN products p ON s.product_id = p.product_id --соединение с таблицей products по общему id
GROUP BY e.first_name, e.last_name -- группировка по столбцам
ORDER BY income desc -- сортировка по убываюнию по столбцу income
LIMIT 10; -- выводит первые 10 строк

--------------------------------------
lowest_average_income

WITH average_sales AS (
    SELECT AVG(p.price * s.quantity) AS average_all_sales -- средняя общая выручка
    FROM sales s
    JOIN products p ON s.product_id = p.product_id -- объединение таблиц sales и products по product_id
) -- создается временная таблица для расчетов


SELECT CONCAT(e.first_name, ' ', e.last_name) AS seller,  -- вывод Имени и Фамилии продавца в один столбец
       FLOOR(AVG(p.price * s.quantity)) AS average_income -- средняя выручка продавца и округляет её.
FROM sales s
JOIN employees e ON s.sales_person_id = e.employee_id -- соединение таблиц
JOIN products p ON s.product_id = p.product_id -- соединение таблиц
GROUP BY e.first_name, e.last_name -- группировка по столбцам
HAVING AVG(p.price * s.quantity) < (SELECT average_all_sales FROM average_sales) -- условие - средняя выручка меньше, чем общая средняя выручка по всем продавцам
ORDER BY average_income ASC; -- Сортирует продавцов по средней выручке в порядке возрастания.

--------------------------------------------
day_of_the_week_income

SELECT 
    CONCAT(e.first_name, ' ', e.last_name) AS seller, -- вывод Имени и Фамилии продавца в один столбец
    TO_CHAR(s.sale_date, 'Day') AS day_of_week, --выделение из даты продажи названиее дня недели
    FLOOR(SUM(p.price * s.quantity)) AS income -- подсчет и округление вниз выручки продавца за день
FROM sales s
JOIN employees e ON s.sales_person_id = e.employee_id -- соединение таблиц
JOIN products p ON s.product_id = p.product_id -- соединение таблиц
GROUP BY e.first_name, e.last_name, TO_CHAR(s.sale_date, 'Day'), EXTRACT(DOW FROM s.sale_date) -- группировка по ФИО, дню недели
ORDER BY EXTRACT(DOW FROM s.sale_date), seller; -- сортировка по дню и продавцу

-------------------------------------------------------------------------
age_groups

SELECT 
    CASE -- начало конструкции CASE
        WHEN age BETWEEN 16 AND 25 THEN '16-25'  -- если значение в столбце возраст между 16 и 25, то попадает в эту колонку
        WHEN age BETWEEN 26 AND 40 THEN '26-40'  -- если значение в столбце возраст между 26 и 40, то попадает в эту колонку
        ELSE '40+' -- Иначе (если не выполняется ни одно из условий) попадает в колонку 40+
    END AS age_category, -- конец конструкции CASE
    COUNT(customer_id) AS age_count 
FROM customers -- из таблицы customers
GROUP BY age_category -- группировка по колонке возрастная категория
ORDER BY age_category; -- группировка по колонке возрастная категория

----------------------------------------------------------------------
customers_by_month


SELECT 
    TO_CHAR(s.sale_date, 'YYYY-MM') AS selling_month, --выделение из даты продажи формат даты 'YYYY-MM'
    COUNT(DISTINCT s.customer_id) AS total_customers, --подсчет уникальных покупателей
    FLOOR(SUM(p.price * s.quantity)) AS income -- выручка округленная в меньшую сторону
FROM sales AS s
JOIN products AS p ON s.product_id = p.product_id -- соединение таблиц
GROUP BY selling_month -- группировка по дате
ORDER BY selling_month; -- сортировка по дате по возрастанию

-----------------------------------------------

special_offer

WITH promo_sales AS (
    SELECT s.customer_id, s.sale_date -- вывод покупателя и даты покупки
    FROM sales AS s
    JOIN products AS p ON s.product_id = p.product_id -- соединение таблиц
    WHERE p.price = 0 -- условие что покупка была 0 (акционная)
), -- Создание временной таблицы, где товары были по цене 0
first_promo_sales AS (
    SELECT ps.customer_id, MIN(ps.sale_date) AS first_sale_date
    FROM promo_sales AS ps
    GROUP BY ps.customer_id
) -- временная таблица, в которой вычисляем дату первой акционной покупки для каждого покупателя
SELECT 
    CONCAT(c.first_name, ' ', c.last_name) AS customer, -- вывод Имени и Фамилии продавца в один столбец покупателя
    fps.first_sale_date AS sale_date, -- дата покупки из временно таблицы
    CONCAT(e.first_name, ' ', e.last_name) AS seller -- вывод Имени и Фамилии продавца в один столбец продавца
FROM first_promo_sales AS fps
JOIN sales AS s -- соединение таблиц
ON fps.customer_id = s.customer_id AND fps.first_sale_date = s.sale_date
JOIN customers AS c 
ON s.customer_id = c.customer_id
JOIN employees AS e 
ON s.sales_person_id = e.employee_id
ORDER BY c.customer_id; -- сортировка по покупателю


