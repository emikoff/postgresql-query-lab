SELECT object_name
FROM (
        SELECT '2' || pizza_name AS sort_name, pizza_name AS object_name
        FROM menu
        UNION ALL SELECT '1' || name AS sort_name, name AS object_name
        FROM person
        ) AS objects
ORDER BY sort_name, object_name;
