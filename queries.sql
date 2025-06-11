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