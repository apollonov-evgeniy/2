
-------��� ������� ��������� OraclXE 21
/*
���������� ������ ������ ������ ����� �� ����� https://www.sql-ex.ru/learn_exercises.php?LN=1:
10, 11, 12, 13, 15, 17, 18, 20, 21, 22, 25, 27, 28, 30, 37, 40, 41, 44
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

/*10
������� ������ ���������, ������� ����� ������� ����. �������: model, price
*/
SELECT model,
       price
FROM printer
WHERE price =
    (SELECT MAX(price)
     FROM printer);
/* 11
������� ������� �������� ��.
*/
SELECT AVG(speed) AS avg_speed_pc
FROM pc;

/* 12
������� ������� �������� ��-���������, ���� ������� ��������� 1000 ���.
*/
SELECT AVG(speed)
FROM laptop
WHERE price > 1000;
    
/* 13
������� ������� �������� ��, ���������� �������������� A.
*/

SELECT AVG(pc.speed)
FROM product
INNER JOIN pc ON pc.model = product.model
AND product.maker IN ('A');
/* 15
������� ������� ������� ������, ����������� � ���� � ����� PC. �������: HD
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
������� ������ ��-���������, �������� ������� ������ �������� ������� �� ��.
�������: type, model, speed
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
������� �������������� ����� ������� ������� ���������. �������: maker, price
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
������� ��������������, ����������� �� ������� ���� ��� ��������� ������ ��. 
�������: Maker, ����� ������� ��.
*/

SELECT t1.maker,
       COUNT(*)
FROM product t1
WHERE t1.type = 'PC'
GROUP BY t1.maker
HAVING COUNT(*) >= 3;
    
/* 21
������� ������������ ���� ��, ����������� ������ ��������������, � �������� ���� ������ � ������� PC.
�������: maker, ������������ ����.
*/
SELECT maker,
       MAX(price)
FROM product t1
INNER JOIN pc t2 ON t1.model = t2.model
GROUP BY maker;
/* 22
��� ������� �������� �������� ��, ������������ 600 ���, ���������� ������� ���� �� � ����� �� ���������.
�������: speed, ������� ����.
*/

SELECT speed,
       AVG(price)
FROM pc
WHERE speed > 600
GROUP BY speed;

/* 25
������� �������������� ���������, ������� ���������� �� � ���������� ������� RAM 
� � ����� ������� ����������� ����� ���� ��, ������� ���������� ����� RAM. �������: Maker
*/


/* ��� ����������� � ORACL ��-�� INTERSECT. ���� �� ����� ���������. 
-- ���� ������ distinct  ��������, �� ����������� �� ������. ����� �� �����������
� distinct  ������ /������ �������� ������ ���������� �� ����������� ����. ��� ������ 972/
� ORACL ��� �����������
p.s. �������� � �����, ����� �� ���������
*/


WITH maker_pc_printer AS
  (--  ������� �� c ���������������� , ��������� ��������������� ���������
 SELECT t2.maker,
        t2.model,
        t1.ram,
        t1.speed
   FROM pc t1
   INNER JOIN
     (-- ������� �������������� � �������, ����������� �������� ���������
 SELECT maker,
        model,
        TYPE
      FROM product
      WHERE maker in
          (-- ����������� �������������� ���������, ������� ��������� PC
 SELECT maker
           FROM product
           WHERE TYPE = 'Printer' INTERSECT
             SELECT maker
             FROM product WHERE TYPE = 'PC' )
        AND TYPE = 'PC' ) t2 ON t1.model=t2.model),
     maker_min_ram AS
  (--  �����  �������������� �� � ���������� ������� RAM
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
    (--�� � ����� ������� ����������� ����� ���� ��, ������� ���������� ����� RAM
 SELECT max(t1.speed)
     FROM pc t1
     WHERE t1.ram =
         (SELECT min(t2.ram)
          FROM pc t2
          WHERE t2.ram <> 0) );
-- ������ ��������� A  E
             
/* 27
������� ������� ������ ����� �� ������� �� ��� ��������������, ������� ��������� � ��������. 
�������: maker, ������� ������ HD.*/

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
��������� ������� Product, ���������� ���������� ��������������,
����������� �� ����� ������.
*/

SELECT count(*) AS maker_count
FROM
  (SELECT COUNT(*) AS qnty
   FROM Product
   GROUP BY maker
   HAVING COUNT(model)=1);

/* 30
� �������������, ��� ������ � ������ ����� �� ������ ������ ������ ����������� ������������ ����� ��� 
(��������� ������ � �������� �������� ������� code), 
��������� �������� �������, � ������� ������� ������ �� ������ ���� ���������� �������� 
����� ��������������� ���� ������.
�����: point, date, ��������� ������ ������ �� ���� (out), 
��������� ������ ������ �� ���� (inc). 
������������� �������� ������� ��������������� (NULL).
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
������� ������, � ������� ������ ������ ���� ������� �� ���� ������ 
(������ ����� ������� � Outcomes).
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
����� ��������������, ������� ��������� ����� ����� ������, 
��� ���� ��� ����������� �������������� ������ �������� ���������� ������ ����.
�������: maker, type
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
��� ������� �������������, � �������� ������������ ������ ���� �� � ����� �� ������ PC, Laptop ��� Printer,
���������� ������������ ���� �� ��� ���������.
�����: ��� �������������, ���� ����� ��� �� ��������� ������� ������������� ������������ NULL,
�� �������� ��� ����� ������������� NULL,
����� ������������ ����.
*/
WITH total_maker AS
  (SELECT DISTINCT t1.maker,
                   t2.model,
                   t2.price
   FROM product t1
   JOIN laptop t2 ON t1.model = t2.model -- laptop ������� �� �������������
UNION SELECT DISTINCT t1.maker,
                      t2.model,
                      t2.price
   FROM product t1
   JOIN pc t2 ON t1.model = t2.model --PC ������� �� �������������
UNION SELECT DISTINCT t1.maker,
                      t2.model,
                      t2.price
   FROM product t1
   JOIN printer t2 ON t1.model = t2.model) -- Printer ������� �������������

SELECT DISTINCT maker,
                CASE
                    WHEN maker IN
                           (SELECT DISTINCT maker
                            FROM total_maker
                            WHERE price IS NULL) THEN NULL -- ���� ���� Null
                    ELSE MAX(price) -- Max ����
                END price
FROM total_maker
GROUP BY maker
ORDER BY maker;
/* 44
������� �������� ���� �������� � ���� ������, ������������ � ����� R.
*/

SELECT name
FROM ships
WHERE name like 'R%'
UNION
SELECT ship
FROM outcomes
WHERE ship like 'R%';


