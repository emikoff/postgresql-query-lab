SELECT person.name
FROM person
LEFT JOIN person_order
    ON person_order.person_id = person.id
LEFT JOIN menu
    ON menu.id = person_order.menu_id

WHERE person.gender = 'male'
      AND (person.address = 'Moscow'
           OR person.address = 'Samara')
      AND menu.pizza_name IN ('pepperoni pizza', 'mushroom pizza')

ORDER BY person.name DESC;