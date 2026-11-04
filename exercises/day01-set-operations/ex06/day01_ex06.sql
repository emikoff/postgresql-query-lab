SELECT action_date, person.name AS person_name
FROM (
	SELECT order_date AS action_date, person_id
	FROM person_order
	INTERSECT SELECT visit_date AS action_date, person_id
	FROM person_visits
	ORDER BY action_date, person_id DESC
) AS common_action
JOIN person ON person.id=common_action.person_id
ORDER BY action_date, person_name DESC;
