SELECT
    pers.name AS name,
    m.pizza_name AS pizza_name,
    m.price AS price,
    ROUND(m.price * (1 - pers_d.discount / 100)) AS discount_price,
    piz.name AS pizzeria_name
FROM person pers
JOIN person_order pers_o ON pers_o.person_id = pers.id
JOIN menu m ON m.id = pers_o.menu_id
JOIN pizzeria piz ON piz.id = m.pizzeria_id
JOIN person_discounts pers_d
    ON pers_d.person_id = pers.id
    AND pers_d.pizzeria_id = piz.id
ORDER BY name, pizza_name;