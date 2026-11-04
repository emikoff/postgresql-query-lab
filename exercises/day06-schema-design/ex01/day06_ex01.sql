  INSERT INTO person_discounts (id, person_id, pizzeria_id, discount)

  SELECT
      ROW_NUMBER() OVER () AS id,
      person_id,
      pizzeria_id,
      CASE
        WHEN orders_count = 1 THEN 10.5
        WHEN orders_count = 2 THEN 22
        ELSE 30
      END AS discount
  FROM (
      SELECT
        p_o.person_id,
        m.pizzeria_id,
        COUNT(*) AS orders_count
      FROM person_order p_o
      JOIN menu m ON p_o.menu_id = m.id
      GROUP BY p_o.person_id, m.pizzeria_id
      ) t;