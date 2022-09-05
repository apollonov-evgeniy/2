
-------Все примеры выполнены OraclXE 21
/*
Необходимо решить данные номера задач на сайте https://www.sql-ex.ru/learn_exercises.php?LN=1:
10, 11, 12, 13, 15, 17, 18, 20, 21, 22, 25, 27, 28, 30, 37, 40, 41, 44
Скрипты баз https://www.sql-ex.ru/db_script_download.php?Lang=0
схема бд https://www.sql-ex.ru/help/select13.php#db_1

Схема БД состоит из четырех таблиц:
Product(maker, model, type)
PC(code, model, speed, ram, hd, cd, price)
Laptop(code, model, speed, ram, hd, price, screen)
Printer(code, model, color, type, price)
Таблица Product представляет производителя (maker), номер модели (model) и тип ('PC' - ПК, 'Laptop' - ПК-блокнот 
или 'Printer' - принтер). Предполагается, что номера моделей в таблице Product уникальны для всех производителей 
и типов продуктов. 
В таблице PC для каждого ПК, однозначно определяемого уникальным кодом – code, указаны модель – 
model (внешний ключ к таблице Product), скорость - speed (процессора в мегагерцах), объем памяти - ram (в мегабайтах),
размер диска - hd (в гигабайтах), скорость считывающего устройства - cd (например, '4x') и цена - price (в долларах). 
Таблица Laptop аналогична таблице РС за исключением того, что вместо скорости CD содержит размер экрана -screen (в дюймах). 
В таблице Printer для каждой модели принтера указывается, является ли он цветным - color ('y', если цветной), тип принтера -
type (лазерный – 'Laser', струйный – 'Jet' или матричный – 'Matrix') и цена - price.
*/

/*10
Найдите модели принтеров, имеющих самую высокую цену. Вывести: model, price
*/
SELECT model,
       price
FROM printer
WHERE price =
    (SELECT MAX(price)
     FROM printer);
/* 11
Найдите среднюю скорость ПК.
*/
SELECT AVG(speed) AS avg_speed_pc
FROM pc;

/* 12
Найдите среднюю скорость ПК-блокнотов, цена которых превышает 1000 дол.
*/
SELECT AVG(speed)
FROM laptop
WHERE price > 1000;
    
/* 13
Найдите среднюю скорость ПК, выпущенных производителем A.
*/

SELECT AVG(pc.speed)
FROM product
INNER JOIN pc ON pc.model = product.model
AND product.maker IN ('A');
/* 15
Найдите размеры жестких дисков, совпадающих у двух и более PC. Вывести: HD
*/
SELECT hd
FROM
  (SELECT hd,
          COUNT(*) AS count_hd
   FROM pc
   WHERE hd IS NOT NULL
   GROUP BY hd
   HAVING COUNT(*) >= 2);

----------OR---------------------
WITH t1 AS
  (SELECT hd,
          COUNT(*)
   FROM pc
   WHERE hd IS NOT NULL
   GROUP BY hd
   HAVING COUNT(*) >= 2)
SELECT t1.hd
FROM t1;
/* 17
Найдите модели ПК-блокнотов, скорость которых меньше скорости каждого из ПК.
Вывести: type, model, speed
*/
SELECT DISTINCT product.type,
                laptop.model,
                laptop.speed
FROM product,
     laptop
WHERE speed < ALL
    (SELECT speed
     FROM pc)
  AND product.model = laptop.model;
    
/*18
Найдите производителей самых дешевых цветных принтеров. Вывести: maker, price
*/
WITH t1 AS
  (SELECT product.maker AS maker,
          printer.price AS price
   FROM product
   INNER JOIN printer ON product.model = printer.model
   AND printer.color = 'y')
SELECT DISTINCT t1.maker,
                t1.price
FROM t1
WHERE t1.price =
    (SELECT MIN(price)
     FROM t1);
    
/* 20
Найдите производителей, выпускающих по меньшей мере три различных модели ПК. 
Вывести: Maker, число моделей ПК.
*/

SELECT t1.maker,
       COUNT(*)
FROM product t1
WHERE t1.type = 'PC'
GROUP BY t1.maker
HAVING COUNT(*) >= 3;
    
/* 21
Найдите максимальную цену ПК, выпускаемых каждым производителем, у которого есть модели в таблице PC.
Вывести: maker, максимальная цена.
*/
SELECT maker,
       MAX(price)
FROM product t1
INNER JOIN pc t2 ON t1.model = t2.model
GROUP BY maker;
/* 22
Для каждого значения скорости ПК, превышающего 600 МГц, определите среднюю цену ПК с такой же скоростью.
Вывести: speed, средняя цена.
*/

SELECT speed,
       AVG(price)
FROM pc
WHERE speed > 600
GROUP BY speed;

/* 25
Найдите производителей принтеров, которые производят ПК с наименьшим объемом RAM 
и с самым быстрым процессором среди всех ПК, имеющих наименьший объем RAM. Вывести: Maker
*/


/* Все запускалось в ORACL из-за INTERSECT. Сайт не хочет проверять. 
-- если убрать distinct  работает, но неправильно по логике. ответ не засчитывает
с distinct  выдает /Запрос вызывает ошибку выполнения на проверочной базе. Код ошибки 972/
в ORACL все запускается
p.s. Забрался в дебри, решил не отступать
*/


WITH maker_pc_printer AS
  (--  моделей ПС c характеристиками , сделанных производителями принтеров
 SELECT t2.maker,
        t2.model,
        t1.ram,
        t1.speed
   FROM pc t1
   INNER JOIN
     (-- таблица производителей и моделей, выпускаемых производ принтеров
 SELECT maker,
        model,
        TYPE
      FROM product
      WHERE maker in
          (-- определение производителей принтеров, которые выпускают PC
 SELECT maker
           FROM product
           WHERE TYPE = 'Printer' INTERSECT
             SELECT maker
             FROM product WHERE TYPE = 'PC' )
        AND TYPE = 'PC' ) t2 ON t1.model=t2.model),
     maker_min_ram AS
  (--  вывод  производителей ПК с наименьшим объемом RAM
 SELECT maker,
        speed,
        ram
   FROM maker_pc_printer
   WHERE maker_pc_printer.ram =
       (SELECT min(maker_pc_printer.ram)
        FROM maker_pc_printer)
     AND maker_pc_printer.ram <>0 )
SELECT DISTINCT maker
FROM maker_min_ram
WHERE maker_min_ram.speed =
    (--ПК с самым быстрым процессором среди всех ПК, имеющих наименьший объем RAM
 SELECT max(t1.speed)
     FROM pc t1
     WHERE t1.ram =
         (SELECT min(t2.ram)
          FROM pc t2
          WHERE t2.ram <> 0) );
-- выдает результат A  E
             
/* 27
Найдите средний размер диска ПК каждого из тех производителей, которые выпускают и принтеры. 
Вывести: maker, средний размер HD.*/

SELECT maker,
       AVG(t2.hd) AS avg_hd
FROM product t1
INNER JOIN pc t2 ON t1.model=t2.model
WHERE maker IN
    (SELECT maker
     FROM product
     WHERE TYPE='Printer' )
GROUP BY maker;

/* 28
Используя таблицу Product, определить количество производителей,
выпускающих по одной модели.
*/

SELECT count(*) AS maker_count
FROM
  (SELECT COUNT(*) AS qnty
   FROM Product
   GROUP BY maker
   HAVING COUNT(model)=1);

/* 30
В предположении, что приход и расход денег на каждом пункте приема фиксируется произвольное число раз 
(первичным ключом в таблицах является столбец code), 
требуется получить таблицу, в которой каждому пункту за каждую дату выполнения операций 
будет соответствовать одна строка.
Вывод: point, date, суммарный расход пункта за день (out), 
суммарный приход пункта за день (inc). 
Отсутствующие значения считать неопределенными (NULL).
*/
SELECT point,
       "date",
       SUM(sum_out) as out,
       SUM(sum_inc) as inc
FROM
  (SELECT point,
          "date",
          SUM(inc) AS sum_inc,
          NULL AS sum_out
   FROM Income
   GROUP BY point,
            "date"
   UNION 
   SELECT point,
                "date",
                NULL AS sum_inc,
                SUM("out") AS sum_out
   FROM Outcome
   GROUP BY point,
            "date")
GROUP BY point,
         "date"
ORDER BY point;

/* 37
Найдите классы, в которые входит только один корабль из базы данных 
(учесть также корабли в Outcomes).
*/
SELECT class
FROM
  (SELECT name,
          class
   FROM ships
   UNION 
   SELECT class AS name,
                         class
   FROM classes t1,
        outcomes t2
   WHERE t1.class=t2.ship) A
GROUP BY class
HAVING count(A.name)=1;

/* 40
Найти производителей, которые выпускают более одной модели, 
при этом все выпускаемые производителем модели являются продуктами одного типа.
Вывести: maker, type
*/
SELECT maker,
       type
FROM product
WHERE maker in
    (SELECT maker
     FROM
       (SELECT maker,
               type
        FROM product
        GROUP BY maker,type)
     GROUP BY maker
     HAVING count(maker) = 1)
GROUP BY maker,type
HAVING count(type)>1;

/* 41
Для каждого производителя, у которого присутствуют модели хотя бы в одной из таблиц PC, Laptop или Printer,
определить максимальную цену на его продукцию.
Вывод: имя производителя, если среди цен на продукцию данного производителя присутствует NULL,
то выводить для этого производителя NULL,
иначе максимальную цену.
*/
WITH total_maker AS
  (SELECT DISTINCT t1.maker,
                   t2.model,
                   t2.price
   FROM product t1
   JOIN laptop t2 ON t1.model = t2.model -- laptop таблица от производителя
UNION SELECT DISTINCT t1.maker,
                      t2.model,
                      t2.price
   FROM product t1
   JOIN pc t2 ON t1.model = t2.model --PC таблица от производителя
UNION SELECT DISTINCT t1.maker,
                      t2.model,
                      t2.price
   FROM product t1
   JOIN printer t2 ON t1.model = t2.model) -- Printer таблица производителя

SELECT DISTINCT maker,
                CASE
                    WHEN maker IN
                           (SELECT DISTINCT maker
                            FROM total_maker
                            WHERE price IS NULL) THEN NULL -- Если есть Null
                    ELSE MAX(price) -- Max цена
                END price
FROM total_maker
GROUP BY maker
ORDER BY maker;
/* 44
Найдите названия всех кораблей в базе данных, начинающихся с буквы R.
*/

SELECT name
FROM ships
WHERE name like 'R%'
UNION
SELECT ship
FROM outcomes
WHERE ship like 'R%';


