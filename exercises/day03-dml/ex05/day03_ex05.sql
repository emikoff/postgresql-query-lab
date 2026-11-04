WITH orders_with_pizzeria AS(
    SELECT person_order.person_id,
           menu.pizzeria_id
    FROM menu
    JOIN person_order
         ON person_order.menu_id  = menu.id
), andrey_visits AS(
    SELECT  pizzeria_id
    FROM person_visits
    JOIN person
        ON person.id = person_visits.person_id
    WHERE person.name = 'Andrey'
),
andrey_orders AS(
    SELECT pizzeria_id
    FROM orders_with_pizzeria
    JOIN person
        ON person.id = orders_with_pizzeria.person_id
    WHERE person.name = 'Andrey'
),
andrey_except AS(
    SELECT pizzeria_id
    FROM andrey_visits
    EXCEPT
    SELECT pizzeria_id
    FROM andrey_orders
)

SELECT pizzeria.name AS pizzeria_name
FROM andrey_except
JOIN pizzeria
    ON pizzeria.id = andrey_except.pizzeria_id

ORDER BY pizzeria.name;
