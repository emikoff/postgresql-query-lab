SELECT person.name
FROM person

LEFT JOIN person_order
    ON person_order.person_id = person.id
LEFT JOIN menu
    ON menu.id = person_order.menu_id

WHERE person.gender = 'female'
    AND menu.pizza_name IN ('pepperoni pizza', 'cheese pizza')
GROUP BY person.id, person.name
HAVING COUNT(DISTINCT menu.pizza_name) = 2
ORDER BY person.name;
