INSERT INTO person_visits (id, person_id, pizzeria_id, visit_date)
SELECT
      (SELECT MAX(id) +
            (CASE
                  WHEN person.name = 'Denis' THEN 1
                  WHEN person.name = 'Irina' THEN 2
            END) FROM person_visits),
      person.id,
      pizzeria.id,
      '2022-02-24'
FROM person
CROSS JOIN pizzeria
WHERE person.name IN ('Denis', 'Irina')
      AND pizzeria.name = 'Dominos';
