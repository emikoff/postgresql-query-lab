INSERT INTO menu (id, pizzeria_id, pizza_name, price)
SELECT
    (SELECT MAX(id) + 1 FROM menu),
    pizzeria.id,
    'sicilian pizza',
    900
FROM pizzeria
WHERE pizzeria.name = 'Dominos';
