WITH top_visits AS (
    SELECT
        person_id,
        COUNT(*) AS count_of_visits
    FROM person_visits
    GROUP BY person_id
    ORDER BY
        count_of_visits DESC,
        person_id ASC
    FETCH FIRST 4 ROWS ONLY
)

SELECT
    person.name AS name,
    top_visits.count_of_visits
FROM top_visits
JOIN person
    ON person.id = top_visits.person_id
ORDER BY name;