WITH male_visits AS (
    SELECT
        person_visits.pizzeria_id
    FROM person
    JOIN person_visits
        ON person_visits.person_id = person.id
    WHERE person.gender = 'male'
),

female_visits AS (
    SELECT
        person_visits.pizzeria_id
    FROM person
    JOIN person_visits
        ON person_visits.person_id = person.id
    WHERE person.gender = 'female'
),

best_male_visits AS (
    SELECT
        pizzeria_id
    FROM male_visits

    EXCEPT ALL

    SELECT
        pizzeria_id
    FROM female_visits
),

best_female_visits AS (
    SELECT
        pizzeria_id
    FROM female_visits

    EXCEPT ALL

    SELECT
        pizzeria_id
    FROM male_visits
),

result AS (
    SELECT
        pizzeria_id
    FROM best_male_visits

    UNION

    SELECT
        pizzeria_id
    FROM best_female_visits
)

SELECT
    pizzeria.name AS pizzeria_name
FROM result
JOIN pizzeria
    ON pizzeria.id = result.pizzeria_id
ORDER BY pizzeria.name;