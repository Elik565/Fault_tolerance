Вопросы, возникшие при выполнении задания:
1. Нужно ли сохранять регистр в названиях таблиц и полей?
2. При загрузке данных в таблицу "Posts" возникают ошибки при отсутствии связанной записи. Например: ERROR:  insert or update on table "Posts" violates foreign key constraint "Fk_Posts_Users" DETAIL:  Key (OwnerUserId)=(288868) is not present in table "Users";

Принятые решения:
1. Решил сохранять регистр для соответствия названий со схемой бд;
2. Проверил, что в файлах xml действительно нет таких значений, значит целостность данных нарушена уже в дампе, что странно. Решил отключать проблемные ограничения на время загрузки данных. После импорта можно запустить скрипт check.sql, чтобы проверить соблюдение всех ограничений в схеме;


Инструкция по запуску:
1. С помощью программы Find_fields/find_fields находим только те поля таблиц, данные которых присутствуют в дампе. Для этого запускаем программу и передаем ей путь до директории, в которой хранятся xml файлы дампа. Пример: ./Find_fields/find_fields dump. После запуска в консоли печатаются названия файлов(таблиц) и поля, присутствующие в них. Также создается файл (в той же директории что и дамп) с названием "<ваша_директория_с xml_файлами>_fields.txt" для последующего парсинга;
2. С помощью программы Convert_xml_to_csv конвертируем xml файлы дампа в файлы csv для более быстрого импорта данных. Для этого запускаем прогрмму и передаем ей путь до директории, в которой хранятся xml файлы дампа, и путь до файла с полями таблиц. Пример: ./Convert_xml_to_csv/convert dump dump_fields.txt. Создастся папка с названием "<ваша_директория_с xml_файлами>_csv" с файлами csv;
3. С помощью скрипта create.sql создается схема данных "Dump_schema". Для этого запускаем скрипт через psql, указывая базу данных, где будет создана схема. Пример: psql -d StackExchange -f create.sql;
4. Импортировать данные можно, запустив скрипт import.sh, указав путь до папки с csv файлами дампа и базу данных со схемой "Dump_schema". Пример: ./import.sh dump_csv StackExchange;
5. Чтобы выполнить соблюдение всех ограничений в схеме, запускаем скрипт check.sql через psql, указывая базу данных со схемой "Dump_schema". Пример: psql -d StackExchange -f check.sql;
6. Для выполнения запроса Q1 - "Репутационные пары" запускаем скрипт Q1.sql. Пример: psql -d StackExchange -f Q1.sql;
7. Для выполнения запроса Q2 - "Успешные шутники" запускаем скрипт Q2.sql. Пример: psql -d StackExchange -f Q2.sql.


План запроса Q1:
 Limit  (cost=1074850499.49..1074850499.52 rows=10 width=136) (actual time=1674.703..1675.103 rows=10 loops=1)
   CTE PostTagPairs
     ->  Merge Join  (cost=938141.47..563090194.58 rows=9776241542 width=68) (actual time=724.029..1110.297 rows=309141 loops=1)
           Merge Cond: (t1.post_id = t2.post_id)
           Join Filter: (t1.tag < t2.tag)
           Rows Removed by Join Filter: 587407
           CTE tags
             ->  ProjectSet  (cost=0.00..50062.70 rows=2434100 width=36) (actual time=0.233..324.164 rows=484318 loops=1)
                   ->  Seq Scan on "Posts"  (cost=0.00..35458.10 rows=243410 width=35) (actual time=0.187..92.900 rows=243410 loops=1)
           ->  Sort  (cost=444039.39..450094.21 rows=2421930 width=36) (actual time=570.313..597.572 rows=278266 loops=1)
                 Sort Key: t1.post_id
                 Sort Method: external merge  Disk: 6776kB
                 ->  CTE Scan on tags t1  (cost=0.00..54767.25 rows=2421930 width=36) (actual time=0.250..502.629 rows=278266 loops=1)
                       Filter: (tag <> ''::text)
                       Rows Removed by Filter: 206052
           ->  Materialize  (cost=444039.39..456149.04 rows=2421930 width=36) (actual time=153.685..245.983 rows=896546 loops=1)
                 ->  Sort  (cost=444039.39..450094.21 rows=2421930 width=36) (actual time=153.681..183.997 rows=278266 loops=1)
                       Sort Key: t2.post_id
                       Sort Method: external merge  Disk: 7112kB
                       ->  CTE Scan on tags t2  (cost=0.00..54767.25 rows=2421930 width=36) (actual time=0.021..70.460 rows=278266 loops=1)
                             Filter: (tag <> ''::text)
                             Rows Removed by Filter: 206052
   ->  Sort  (cost=511760304.91..511760314.91 rows=4000 width=136) (actual time=1674.699..1675.094 rows=10 loops=1)
         Sort Key: (count(*)) DESC
         Sort Method: top-N heapsort  Memory: 26kB
         ->  HashAggregate  (cost=511760158.48..511760218.48 rows=4000 width=136) (actual time=1666.418..1673.059 rows=9171 loops=1)
               Group Key: (count(*)), pt1.tag1, pt1.tag2
               Batches: 1  Memory Usage: 5265kB
               ->  Nested Loop  (cost=268920743.20..508227361.12 rows=176639868 width=92) (actual time=1492.314..1620.405 rows=66194 loops=1)
                     ->  Hash Join  (cost=268920742.77..503800291.47 rows=176639868 width=92) (actual time=1492.286..1581.172 rows=69294 loops=1)
                           Hash Cond: ((ptp.tag1 = pt1.tag1) AND (ptp.tag2 = pt1.tag2))
                           ->  Hash Join  (cost=73100.36..234025235.67 rows=176639868 width=84) (actual time=875.445..941.630 rows=69294 loops=1)
                                 Hash Cond: (ptp.post_id = p1."Id")
                                 ->  CTE Scan on "PostTagPairs" ptp  (cost=0.00..195524830.84 rows=9776241542 width=68) (actual time=724.034..752.076 rows=309141 loops=1)
                                 ->  Hash  (cost=73045.39..73045.39 rows=4398 width=28) (actual time=151.336..151.727 rows=21168 loops=1)
                                       Buckets: 32768 (originally 8192)  Batches: 1 (originally 1)  Memory Usage: 1652kB
                                       ->  Gather  (cost=35585.81..73045.39 rows=4398 width=28) (actual time=67.710..146.370 rows=21168 loops=1)
                                             Workers Planned: 2
                                             Workers Launched: 2
                                             ->  Nested Loop  (cost=34585.81..71605.59 rows=1832 width=28) (actual time=64.029..142.474 rows=7056 loops=3)
                                                   ->  Parallel Hash Join  (cost=34585.39..69029.31 rows=1832 width=28) (actual time=63.998..118.183 rows=7056 loops=3)
                                                         Hash Cond: (p2."ParentId" = p1."Id")
                                                         ->  Parallel Seq Scan on "Posts" p2  (cost=0.00..34291.76 rows=57965 width=16) (actual time=0.029..41.204 rows=46217 loops=3
)
                                                               Filter: ("PostTypeId" = 2)
                                                               Rows Removed by Filter: 34920
                                                         ->  Parallel Hash  (cost=34545.31..34545.31 rows=3206 width=12) (actual time=63.637..63.638 rows=5796 loops=3)
                                                               Buckets: 32768 (originally 8192)  Batches: 1 (originally 1)  Memory Usage: 1344kB
                                                               ->  Parallel Seq Scan on "Posts" p1  (cost=0.00..34545.31 rows=3206 width=12) (actual time=0.080..56.457 rows=5796 loo
ps=3)
                                                                     Filter: (("Tags" ~~ '%postgresql%'::text) AND ("PostTypeId" = 1))
                                                                     Rows Removed by Filter: 75340
                                                   ->  Index Scan using "Posts_pkey" on "Posts" p  (cost=0.42..1.41 rows=1 width=8) (actual time=0.003..0.003 rows=1 loops=21168)
                                                         Index Cond: ("Id" = p2."Id")
                           ->  Hash  (cost=268847042.40..268847042.40 rows=40000 width=72) (actual time=616.417..616.418 rows=41361 loops=1)
                                 Buckets: 65536  Batches: 1  Memory Usage: 3161kB
                                 ->  HashAggregate  (cost=268846642.40..268847042.40 rows=40000 width=72) (actual time=600.107..605.796 rows=41361 loops=1)
                                       Group Key: pt1.tag1, pt1.tag2
                                       Batches: 1  Memory Usage: 5137kB
                                       ->  CTE Scan on "PostTagPairs" pt1  (cost=0.00..195524830.84 rows=9776241542 width=64) (actual time=0.001..502.612 rows=309141 loops=1)
                     ->  Memoize  (cost=0.43..0.56 rows=1 width=8) (actual time=0.000..0.000 rows=1 loops=69294)
                           Cache Key: p."OwnerUserId"
                           Cache Mode: logical
                           Hits: 65320  Misses: 3974  Evictions: 0  Overflows: 0  Memory Usage: 420kB
                           ->  Index Scan using "Users_pkey" on "Users" u  (cost=0.42..0.55 rows=1 width=8) (actual time=0.003..0.003 rows=1 loops=3974)
                                 Index Cond: ("Id" = p."OwnerUserId")
 Planning Time: 7.486 ms
 Execution Time: 1685.888 ms
(66 rows)

План запроса Q2:
 Limit  (cost=49737.43..49744.07 rows=10 width=22) (actual time=147.036..152.616 rows=10 loops=1)
   ->  Nested Loop  (cost=49737.43..54846.76 rows=7695 width=22) (actual time=147.033..152.610 rows=10 loops=1)
         ->  Gather Merge  (cost=49737.01..50633.22 rows=7695 width=16) (actual time=147.000..152.469 rows=10 loops=1)
               Workers Planned: 2
               Workers Launched: 2
               ->  Sort  (cost=48736.98..48745.00 rows=3206 width=16) (actual time=135.988..136.086 rows=965 loops=3)
                     Sort Key: p2."Score"
                     Sort Method: quicksort  Memory: 220kB
                     Worker 0:  Sort Method: quicksort  Memory: 213kB
                     Worker 1:  Sort Method: quicksort  Memory: 208kB
                     ->  Nested Loop  (cost=0.42..48550.29 rows=3206 width=16) (actual time=0.257..133.654 rows=2990 loops=3)
                           ->  Parallel Seq Scan on "Posts" p1  (cost=0.00..34545.31 rows=3206 width=8) (actual time=0.136..102.500 rows=5796 loops=3)
                                 Filter: (("Tags" ~~ '%postgresql%'::text) AND ("PostTypeId" = 1))
                                 Rows Removed by Filter: 75340
                           ->  Index Scan using "Posts_pkey" on "Posts" p2  (cost=0.42..4.37 rows=1 width=12) (actual time=0.004..0.004 rows=1 loops=17389)
                                 Index Cond: ("Id" = p1."AcceptedAnswerId")
         ->  Index Scan using "Users_pkey" on "Users" u  (cost=0.42..0.55 rows=1 width=14) (actual time=0.012..0.012 rows=1 loops=10)
               Index Cond: ("Id" = p2."OwnerUserId")
 Planning Time: 3.019 ms
 Execution Time: 152.903 ms
(20 rows)




