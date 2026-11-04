SELECT person_name, pizza_name, pizzeria_name FROM
    (SELECT id, name AS person_name FROM person) AS df_person
    JOIN (SELECT person_id, menu_id FROM person_order) AS df_person_order ON df_person.id=df_person_order.person_id
    JOIN (SELECT id, pizza_name, pizzeria_id FROM menu) df_menu ON df_person_order.menu_id=df_menu.id
    JOIN (SELECT id, name AS pizzeria_name FROM pizzeria) df_pizzeria ON df_pizzeria.id=df_menu.pizzeria_id
ORDER BY person_name, pizza_name, pizzeria_name;