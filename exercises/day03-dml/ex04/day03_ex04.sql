WITH orders_with_pizzeria AS(
    SELECT person_order.person_id,
           menu.pizzeria_id
    FROM menu
    JOIN person_order
         ON person_order.menu_id  = menu.id
),
male_pizzerias AS(
    SELECT pizzeria_id
    FROM person
    JOIN orders_with_pizzeria
        ON orders_with_pizzeria.person_id = person.id
    WHERE person.gender = 'male'
),
female_pizzerias AS(
    SELECT pizzeria_id
    FROM person
    JOIN orders_with_pizzeria
        ON orders_with_pizzeria.person_id = person.id
    WHERE person.gender = 'female'
),
best_male_pizzerias AS (
    SELECT pizzeria_id
    FROM male_pizzerias
    EXCEPT
    SELECT pizzeria_id
    FROM female_pizzerias
),
best_female_pizzerias AS (
    SELECT pizzeria_id
    FROM female_pizzerias
    EXCEPT
    SELECT pizzeria_id
    FROM male_pizzerias
),
union_order AS(
    SELECT pizzeria_id
    FROM best_male_pizzerias
    UNION
    SELECT pizzeria_id
    FROM best_female_pizzerias)

SELECT pizzeria.name AS pizzeria_name
FROM union_order
JOIN pizzeria
    ON pizzeria.id = union_order.pizzeria_id

ORDER BY pizzeria.name;
