# Анализ индекса через EXPLAIN ANALYZE

[← Day 05](day05-indexes.md) · [README](../README.md)

Эксперимент выполнен запросом [`day05_ex06.sql`](../exercises/day05-indexes/ex06/day05_ex06.sql). Для наглядного сравнения планировщику задано `SET enable_seqscan = off`.

## Без дополнительного индекса

До создания `idx_1` соединение получает строки `pizzeria` через первичный ключ, после чего отдельно сортирует их по рейтингу:

```text
Sort  (cost=64.54..64.58 rows=18)
  -> WindowAgg  (cost=63.80..64.16 rows=18)
       -> Sort  (cost=63.80..63.85 rows=18)
            Sort Key: pz.rating
            -> Nested Loop
                 -> Index Only Scan using idx_menu_unique on menu
                 -> Index Scan using pizzeria_pkey on pizzeria

Planning Time:  0.955 ms
Execution Time: 0.346 ms
```

## После создания индекса

Добавляется составной индекс:

```sql
CREATE INDEX idx_1 ON pizzeria (rating, id);
```

План использует его как источник уже упорядоченных значений `rating` и `id`:

```text
Sort  (cost=25.90..25.95 rows=18)
  -> WindowAgg  (cost=0.27..25.53 rows=18)
       -> Nested Loop  (cost=0.27..25.21 rows=18)
            -> Index Only Scan using idx_1 on pizzeria
            -> Index Only Scan using idx_menu_unique on menu

Planning Time:  0.381 ms
Execution Time: 0.298 ms
```

## Сравнение

| Показатель | До индекса | После индекса | Изменение |
| --- | ---: | ---: | ---: |
| Верхняя оценка стоимости плана | 64.54 | 25.90 | −59.9% |
| Planning Time | 0.955 ms | 0.381 ms | −60.1% |
| Execution Time | 0.346 ms | 0.298 ms | −13.9% |
| Доступ к `pizzeria` | primary-key Index Scan | `idx_1` Index Only Scan | новый путь доступа |

Индекс заметно снижает оценочную стоимость и устраняет внутреннюю сортировку по `rating`. Разница фактического времени невелика, потому что демонстрационная таблица содержит только шесть пиццерий. Кроме того, последовательное сканирование принудительно отключено, поэтому результаты показывают устройство плана, но не являются production-бенчмарком.
