SELECT person_1.name AS person_name1,
       person_2.name AS person_name2,
       person_1.address AS common_address
FROM person AS person_1

JOIN person AS person_2
    ON person_2.address = person_1.address
    AND person_1.id > person_2.id

ORDER BY person_name1 ASC,
         person_name2 ASC,
         common_address ASC;