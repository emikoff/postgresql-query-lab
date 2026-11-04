INSERT INTO person_order (id, person_id, menu_id, order_date)
SELECT
      (SELECT MAX(id) +
            (CASE
                  WHEN person.name = 'Denis' THEN 1
                  WHEN person.name = 'Irina' THEN 2
            END) FROM person_order),
      person.id,
      menu.id,
      '2022-02-24'
FROM person
CROSS JOIN menu
WHERE person.name IN ('Denis', 'Irina')
      AND menu.pizza_name = 'sicilian pizza';
