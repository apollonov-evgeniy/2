/*
���������� ������ ������ ������ ����� �� ����� https://www.sql-ex.ru/learn_exercises.php?LN=1:
6, 7, 9, 14, 16, 29, 34, 36, 38, 49, 50.
������� ��� https://www.sql-ex.ru/db_script_download.php?Lang=0
����� �� https://www.sql-ex.ru/help/select13.php#db_1

����� �� ������� �� ������� ������:
Product(maker, model, type)
PC(code, model, speed, ram, hd, cd, price)
Laptop(code, model, speed, ram, hd, price, screen)
Printer(code, model, color, type, price)
������� Product ������������ ������������� (maker), ����� ������ (model) � ��� ('PC' - ��, 'Laptop' - ��-������� 
��� 'Printer' - �������). ��������������, ��� ������ ������� � ������� Product ��������� ��� ���� �������������� 
� ����� ���������. 
� ������� PC ��� ������� ��, ���������� ������������� ���������� ����� � code, ������� ������ � 
model (������� ���� � ������� Product), �������� - speed (���������� � ����������), ����� ������ - ram (� ����������),
������ ����� - hd (� ����������), �������� ������������ ���������� - cd (��������, '4x') � ���� - price (� ��������). 
������� Laptop ���������� ������� �� �� ����������� ����, ��� ������ �������� CD �������� ������ ������ -screen (� ������). 
� ������� Printer ��� ������ ������ �������� �����������, �������� �� �� ������� - color ('y', ���� �������), ��� �������� -
type (�������� � 'Laser', �������� � 'Jet' ��� ��������� � 'Matrix') � ���� - price.
*/

/*  6
��� ������� �������������, ������������ ��-�������� c ������� �������� ����� �� ����� 10 �����, 
����� �������� ����� ��-���������. �����: �������������, ��������.
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
������� ������ ������� � ���� ���� ��������� � ������� ��������� (������ ����) 
������������� B (��������� �����).
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
������� �������������� �� � ����������� �� ����� 450 ���. �������: Maker
*/

Select distinct
	t1.maker
from 	product t1 inner join 
	pc t2
on t1.model=t2.model
where t2.speed >= 450;

/*
14 ������� �����, ��� � ������ ��� �������� �� ������� Ships, ������� �� ����� 10 ������.
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
������� ���� ������� PC, ������� ���������� �������� � RAM. 
� ���������� ������ ���� ����������� ������ ���� ���, �.�. (i,j), �� �� (j,i), 
������� ������: ������ � ������� �������, ������ � ������� �������, �������� � RAM.
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
� �������������, ��� ������ � ������ ����� �� ������ ������ ������ ����������� �� ���� ������ ���� � ���� 
[�.�. ��������� ���� (�����, ����)], �������� ������ � ��������� ������� (�����, ����, ������, ������).
������������ ������� Income_o � Outcome_o.
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
�� �������������� �������������� �������� �� ������ 1922 �. 
����������� ������� �������� ������� �������������� ����� 35 ���.����. 
������� �������, ���������� ���� ������� 
(��������� ������ ������� c ��������� ����� ������ �� ����). 
������� �������� ��������.
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
����������� �������� �������� ��������, ��������� � ���� ������ 
(������ ������� � Outcomes).
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
������� ������, ������� �����-���� ������ ������� ������ �������� ('bb') 
� ������� �����-���� ������ ��������� ('bc').
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
������� �������� �������� � �������� ������� 16 ������ 
(������ ������� �� ������� Outcomes).
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
������� ��������, � ������� ����������� ������� ������ Kongo
�� ������� Ships.
*/
select distinct t1.battle
from    outcomes t1 inner join 
        ships t2
on  t1.ship=t2.name 
    and t2.class='Kongo'


