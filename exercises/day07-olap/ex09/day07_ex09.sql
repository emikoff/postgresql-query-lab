WITH result AS (
    SELECT
        address,
        MAX(age) - CAST(MIN(age) AS numeric) / MAX(age) AS formula,
        AVG(age) AS average
    FROM person
    GROUP BY address
)

SELECT
    address,
    ROUND(formula, 2) AS formula,
    ROUND(average, 2) AS average,
    formula > average AS comparison
FROM result
ORDER BY address;