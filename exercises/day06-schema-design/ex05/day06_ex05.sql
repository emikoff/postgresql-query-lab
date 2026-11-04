COMMENT ON TABLE person_discounts
IS 'Персональные скидки клиентов в пицериях';

COMMENT ON COLUMN person_discounts.id
IS 'Первичный ключ';

COMMENT ON COLUMN person_discounts.person_id
IS 'id клиента, который получает скидку';

COMMENT ON COLUMN person_discounts.pizzeria_id
IS 'id пиццерии, где действует скидка';

COMMENT ON COLUMN person_discounts.discount
IS '% скидки клиента';