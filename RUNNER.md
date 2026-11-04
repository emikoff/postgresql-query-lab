# Runner PostgreSQL Query Lab

`sql-runner.sh` — единый CLI для поиска и запуска упражнений Query Lab в PostgreSQL-контейнере.

## Быстрый старт

Запустить окружение:

```bash
docker compose up -d
```

Посмотреть список проектов и статус PostgreSQL:

```bash
./sql-runner.sh list
./sql-runner.sh status
```

Запустить весь раздел или одно упражнение:

```bash
./sql-runner.sh run 2
./sql-runner.sh run SQLB2 ex03
```

Выполнить SQL в изолированной временной базе:

```bash
./sql-runner.sh run 8 --fresh
./sql-runner.sh run 8 ex06 --fresh
```

Для выбранного упражнения stateful-раздела `--fresh` выполняет файлы от `ex00` до выбранного. Так к моменту запуска создаются все необходимые таблицы, данные и объекты схемы. После завершения временная база удаляется.

Запуск SQLB4, SQLB7 и SQLB8 в постоянной базе требует подтверждения. Для неинтерактивного запуска используйте `--yes`:

```bash
./sql-runner.sh run 4 --yes
```

Открыть интерактивную сессию PostgreSQL:

```bash
./sql-runner.sh shell
```

## Обработка ошибок

Каждый SQL-файл выполняется с `ON_ERROR_STOP=1`. Runner останавливается при первой ошибке PostgreSQL, печатает сводку PASS/FAIL/SKIP и возвращает ненулевой код при ошибке.

Day 04 отмечается как отсутствующий, поскольку его нет в этой копии. Day 08 имеет режим `multi-session`: транзакционные упражнения требуют двух согласованных сессий и не запускаются командой `run`.

## Конфигурация

Значения по умолчанию можно переопределить без редактирования скрипта:

```bash
SQL_RUNNER_CONTAINER=my_postgres \
SQL_RUNNER_USER=postgres \
SQL_RUNNER_DB=postgres \
./sql-runner.sh status
```

## Тесты

Тесты заменяют Docker локальным mock-объектом и не подключаются к реальной базе:

```bash
./tests/test-runner.sh
```
