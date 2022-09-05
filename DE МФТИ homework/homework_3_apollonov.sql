/*
Необходимо решить данные номера задач на сайте https://www.sql-ex.ru/learn_exercises.php?LN=1:
6, 7, 9, 14, 16, 29, 34, 36, 38, 49, 50.
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

/*  6
Для каждого производителя, выпускающего ПК-блокноты c объёмом жесткого диска не менее 10 Гбайт, 
найти скорости таких ПК-блокнотов. Вывод: производитель, скорость.
*/

select distinct
	t1.maker,
	t2.speed 
from product t1
join laptop t2
on t2.model=t1.model
where t2.hd>=10
ORDER BY maker, speed;

/* 7
Найдите номера моделей и цены всех имеющихся в продаже продуктов (любого типа) 
производителя B (латинская буква).
*/

Select t1.model, t2.price
from 	product t1 inner join
	pc t2 on t1.model=t2.model
where t1.maker = 'B'
union
Select t1.model, t3.price
from 	product t1 inner join
	laptop t3 on t1.model=t3.model
where t1.maker = 'B'
union
Select t1.model, t4.price
from 	product t1 inner join
	printer t4 on t1.model=t4.model
where t1.maker = 'B';

/*  9 
Найдите производителей ПК с процессором не менее 450 Мгц. Вывести: Maker
*/

Select distinct
	t1.maker
from 	product t1 inner join 
	pc t2
on t1.model=t2.model
where t2.speed >= 450;

/*
14 Найдите класс, имя и страну для кораблей из таблицы Ships, имеющих не менее 10 орудий.
*/
Select
	t1.class,
	t1.name,
	t2.country

from 	ships t1 inner join
	classes t2
on t1.class=t2.class
where t2.numGuns >=10;

/*  16
Найдите пары моделей PC, имеющих одинаковые скорость и RAM. 
В результате каждая пара указывается только один раз, т.е. (i,j), но не (j,i), 
Порядок вывода: модель с большим номером, модель с меньшим номером, скорость и RAM.
*/

Select distinct
	t1.model,
	t2.model,
	t1.speed,
	t1.ram
from 	pc t1 inner join
	pc t2
on 	t1.model>t2.model 
	and t1.speed=t2.speed 
	and t1.ram=t2.ram
ORDER BY t1.model, t2.model ;

/*  29
В предположении, что приход и расход денег на каждом пункте приема фиксируется не чаще одного раза в день 
[т.е. первичный ключ (пункт, дата)], написать запрос с выходными данными (пункт, дата, приход, расход).
Использовать таблицы Income_o и Outcome_o.
*/
SELECT 	t1.point, 
	t1."date",
	SUM(t1.inc) ,
	SUM(t2."out")
FROM 	income_o 	t1 LEFT JOIN
	outcome_o 	t2 ON 	t1.point = t2.point AND
				t1."date" = t2."date"
GROUP BY t1.point, 
	 t1."date"
UNION 
SELECT 
	t2.point, 
	t2."date",
	SUM(t1.inc),
	SUM(t2."out")
FROM 	income_o 	t1 RIGHT JOIN
	outcome_o 	t2 ON   t1.point = t2.point AND
				t1."date" = t2."date"
GROUP BY t2.point, 
	 t2."date"
ORDER BY point, 
	 "date";

/*  34
По Вашингтонскому международному договору от начала 1922 г. 
запрещалось строить линейные корабли водоизмещением более 35 тыс.тонн. 
Укажите корабли, нарушившие этот договор 
(учитывать только корабли c известным годом спуска на воду). 
Вывести названия кораблей.
*/
select 
    t1.name

from    ships t1, 
        classes t2
where   t1.launched is not Null 
        and t1.class=t2.class 
        and t2.DISPLACEMENT > 35000 
        and t1.launched >=1922 
        and t2.type='bb'
order by t1.name;

/*  36
Перечислите названия головных кораблей, имеющихся в базе данных 
(учесть корабли в Outcomes).
*/
select distinct 
        t2.name
from    ships t1 inner join 
        ships t2
on 
        t1.class = t2.name 
union
select distinct 
        t2.ship
from    classes t1 inner join 
        outcomes t2
on      
        t1.class = t2.ship
order by name;

/*  38
Найдите страны, имевшие когда-либо классы обычных боевых кораблей ('bb') 
и имевшие когда-либо классы крейсеров ('bc').
*/

select 
        t1.country
from    classes t1
where   t1.type='bb'
intersect
select 
        t2.country
from    classes t2
where   t2.type='bc';

/* 49
Найдите названия кораблей с орудиями калибра 16 дюймов 
(учесть корабли из таблицы Outcomes).
*/
select t2.name 
from    classes t1, 
        ships t2 
where   t1.bore=16 
        and t1.class = t2.class
union
select  t2.ship
from    classes t1, 
        outcomes t2 
where   t1.bore=16 
        and t1.class = t2.ship
order by name;

/*50
Найдите сражения, в которых участвовали корабли класса Kongo
из таблицы Ships.
*/
select distinct t1.battle
from    outcomes t1 inner join 
        ships t2
on  t1.ship=t2.name 
    and t2.class='Kongo'


