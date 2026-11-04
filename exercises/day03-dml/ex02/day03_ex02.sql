SELECT menu.pizza_name,
       menu.price,
       pizzeria.name AS pizzeria_name
FROM (
    SELECT id AS menu_id
    FROM menu
    EXCEPT
    SELECT menu_id
    FROM person_order
) AS no_order

JOIN menu
    ON menu.id = no_order.menu_id
JOIN pizzeria
    ON pizzeria.id = menu.pizzeria_id

ORDER BY menu.pizza_name,
         menu.price;
