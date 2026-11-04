SELECT pizzeria.name AS pizzeria_name
FROM person
LEFT JOIN person_visits
    ON person_visits.person_id = person.id
LEFT JOIN pizzeria
    ON person_visits.pizzeria_id = pizzeria.id
LEFT JOIN menu
    ON pizzeria.id = menu.pizzeria_id


WHERE person.name = 'Dmitriy'
      AND person_visits.visit_date = '2022-01-08'::date
      AND menu.price < 800;