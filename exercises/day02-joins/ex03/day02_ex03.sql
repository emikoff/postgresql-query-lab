WITH date_list AS (
    SELECT generate_series(
        '2022-01-01'::date,
        '2022-01-10'::date,
        '1 day'
    )::date AS visit_date
)

SELECT date_list.visit_date AS missing_date
FROM date_list

LEFT JOIN person_visits
    ON date_list.visit_date = person_visits.visit_date
    AND (person_visits.person_id = 1
        OR person_visits.person_id = 2)

WHERE person_visits.id IS NULL
ORDER BY missing_date;
