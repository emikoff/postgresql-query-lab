SELECT generate_date.visit_date AS missing_date
FROM (
    SELECT generate_series(
        '2022-01-01'::date,
        '2022-01-10'::date,
        '1 day'
    )::date AS visit_date
) AS generate_date
LEFT JOIN person_visits
    ON generate_date.visit_date = person_visits.visit_date
    AND person_visits.person_id IN (1, 2)
WHERE person_visits.id IS NULL
ORDER BY missing_date;
