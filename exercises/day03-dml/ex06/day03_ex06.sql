SELECT menu_1.pizza_name AS pizza_name,
       pizzeria_1.name AS pizzeria_name_1,
       pizzeria_2.name AS pizzeria_name_2,
       menu_1.price AS price
FROM menu AS menu_1

JOIN menu AS menu_2
    ON menu_1.price = menu_2.price
    AND menu_1.pizza_name = menu_2.pizza_name
    AND menu_1.pizzeria_id < menu_2.pizzeria_id
JOIN pizzeria AS pizzeria_1
    ON pizzeria_1.id = menu_1.pizzeria_id
JOIN pizzeria AS pizzeria_2
    ON pizzeria_2.id = menu_2.pizzeria_id

ORDER BY pizza_name;