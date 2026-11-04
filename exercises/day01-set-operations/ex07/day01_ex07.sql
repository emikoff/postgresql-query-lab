SELECT order_date, name || ' (age:' || age || ')' AS person_information
FROM (
	SELECT person_id, order_date
	FROM person_order
) AS p_o
JOIN person ON person.id=p_o.person_id
ORDER BY order_date, person_information;
