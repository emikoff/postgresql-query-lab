WITH orders AS (
    SELECT
        menu.pizzeria_id,
        COUNT(*) AS count
    FROM person_order
    JOIN menu
        ON menu.id = person_order.menu_id
    GROUP BY menu.pizzeria_id
),
visits AS (
    SELECT
        pizzeria_id,
        COUNT(*) AS count
    FROM person_visits
    GROUP BY pizzeria_id
),
combined_stat AS (
    SELECT pizzeria_id, count
    FROM orders

    UNION ALL

    SELECT pizzeria_id, count
    FROM visits
),
result AS(
    SELECT
        pizzeria.name,
        SUM(count) AS total_count
    FROM combined_stat

    JOIN pizzeria
        ON pizzeria.id = combined_stat.pizzeria_id
    GROUP BY
        pizzeria.id,
        pizzeria.name
)

SELECT *
FROM result
ORDER BY total_count DESC,
    name ASC;