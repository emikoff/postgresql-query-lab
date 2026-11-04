SELECT menu.pizza_name,
       menu.price,
       pizzeria.name AS pizzeria_name,
       pv.visit_date
FROM person

JOIN person_visits AS pv
    ON pv.person_id = person.id
JOIN pizzeria
    ON pizzeria.id = pv.pizzeria_id
JOIN menu
    ON pv.pizzeria_id = menu.pizzeria_id

WHERE person.name = 'Kate'
      AND menu.price BETWEEN 800 AND 1000

ORDER BY menu.pizza_name ASC,
         menu.price ASC,
         pizzeria.name ASC;
