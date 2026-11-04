WITH top_orders AS (
    SELECT
        menu.pizzeria_id,
        'order' AS action_type,
        COUNT(*) AS count
    FROM person_order
    JOIN menu
        ON menu.id = person_order.menu_id
    GROUP BY menu.pizzeria_id
    ORDER BY count DESC
    FETCH FIRST 3 ROWS ONLY
),
top_visits AS (
    SELECT
        pizzeria_id,
        'visit' AS action_type,
        COUNT(*) AS count
    FROM person_visits
    GROUP BY pizzeria_id
    ORDER BY count DESC
    FETCH FIRST 3 ROWS ONLY
),
combined_stat AS (
    SELECT *
    FROM top_orders

    UNION ALL

    SELECT *
    FROM top_visits
)

SELECT
    pizzeria.name,
    combined_stat.count,
    combined_stat.action_type
FROM combined_stat
JOIN pizzeria
    ON pizzeria.id = combined_stat.pizzeria_id
ORDER BY
    action_type ASC,
    count DESC;