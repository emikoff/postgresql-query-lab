INSERT INTO person_order (id, person_id, menu_id, order_date)
SELECT
    (SELECT MAX(id) FROM person_order) + gs,
    person.id,
    menu.id,
    '2022-02-25'
FROM person
JOIN generate_series(1, (SELECT MAX(id) FROM person)) AS gs
    ON gs = person.id
JOIN menu
    ON menu.pizza_name = 'greek pizza';