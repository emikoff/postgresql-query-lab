SELECT menu.pizza_name AS pizza_name,
       pizzeria.name AS pizzeria_name,
       menu.price AS price
FROM menu

JOIN pizzeria
    ON pizzeria.id = menu.pizzeria_id


WHERE menu.pizza_name IN ('pepperoni pizza', 'mushroom pizza')

ORDER BY pizza_name,
         pizzeria_name;