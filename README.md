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
                                                                                              QUERY PLAN                                                                                              
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 Limit  (cost=1076109763.46..1076109763.48 rows=10 width=136) (actual time=1706.896..1706.908 rows=10 loops=1)
   CTE PostTagPairs
     ->  Merge Join  (cost=938783.76..563857510.05 rows=9789574773 width=68) (actual time=550.588..941.692 rows=309141 loops=1)
           Merge Cond: (t1.post_id = t2.post_id)
           Join Filter: (t1.tag < t2.tag)
           Rows Removed by Join Filter: 587407
           CTE tags
             ->  ProjectSet  (cost=0.00..50074.32 rows=2435760 width=36) (actual time=0.026..241.259 rows=484318 loops=1)
                   ->  Seq Scan on "Posts"  (cost=0.00..35459.76 rows=243576 width=35) (actual time=0.014..65.289 rows=243410 loops=1)
           ->  Sort  (cost=444354.72..450413.67 rows=2423581 width=36) (actual time=426.367..453.980 rows=278266 loops=1)
                 Sort Key: t1.post_id
                 Sort Method: external merge  Disk: 6776kB
                 ->  CTE Scan on tags t1  (cost=0.00..54804.60 rows=2423581 width=36) (actual time=0.033..376.165 rows=278266 loops=1)
                       Filter: (tag <> ''::text)
                       Rows Removed by Filter: 206052
           ->  Materialize  (cost=444354.72..456472.62 rows=2423581 width=36) (actual time=124.203..217.767 rows=896546 loops=1)
                 ->  Sort  (cost=444354.72..450413.67 rows=2423581 width=36) (actual time=124.200..154.932 rows=278266 loops=1)
                       Sort Key: t2.post_id
                       Sort Method: external merge  Disk: 7112kB
                       ->  CTE Scan on tags t2  (cost=0.00..54804.60 rows=2423581 width=36) (actual time=0.018..57.525 rows=278266 loops=1)
                             Filter: (tag <> ''::text)
                             Rows Removed by Filter: 206052
   ->  Sort  (cost=512252253.41..512252263.41 rows=4000 width=136) (actual time=1706.894..1706.900 rows=10 loops=1)
         Sort Key: (count(*)) DESC
         Sort Method: top-N heapsort  Memory: 26kB
         ->  HashAggregate  (cost=512252106.97..512252166.97 rows=4000 width=136) (actual time=1698.719..1704.942 rows=9171 loops=1)
               Group Key: (count(*)), pt1.tag1, pt1.tag2
               Batches: 1  Memory Usage: 5265kB
               ->  Nested Loop  (cost=269287370.85..508782815.69 rows=173464564 width=92) (actual time=1514.436..1651.072 rows=66194 loops=1)
                     ->  Hash Join  (cost=269287370.42..504435159.01 rows=173464564 width=92) (actual time=1514.391..1605.264 rows=69294 loops=1)
                           Hash Cond: ((ptp.tag1 = pt1.tag1) AND (ptp.tag2 = pt1.tag2))
                           ->  Hash Join  (cost=73064.16..234310110.66 rows=173464564 width=84) (actual time=892.256..959.080 rows=69294 loops=1)
                                 Hash Cond: (ptp.post_id = p1."Id")
                                 ->  CTE Scan on "PostTagPairs" ptp  (cost=0.00..195791495.46 rows=9789574773 width=68) (actual time=550.591..578.802 rows=309141 loops=1)
                                 ->  Hash  (cost=73010.21..73010.21 rows=4316 width=28) (actual time=341.615..341.618 rows=21168 loops=1)
                                       Buckets: 32768 (originally 8192)  Batches: 1 (originally 1)  Memory Usage: 1652kB
                                       ->  Nested Loop  (cost=37171.74..73010.21 rows=4316 width=28) (actual time=101.827..334.992 rows=21168 loops=1)
                                             ->  Merge Join  (cost=37171.32..66911.68 rows=4316 width=28) (actual time=101.810..288.144 rows=21168 loops=1)
                                                   Merge Cond: (p2."ParentId" = p1."Id")
                                                   ->  Index Scan using idx_posts_parentid on "Posts" p2  (cost=0.42..51983.83 rows=138156 width=16) (actual time=0.029..167.231 rows=138650 loops=1)
                                                         Filter: ("PostTypeId" = 2)
                                                   ->  Sort  (cost=37168.24..37187.27 rows=7610 width=12) (actual time=101.591..103.097 rows=17389 loops=1)
                                                         Sort Key: p1."Id"
                                                         Sort Method: quicksort  Memory: 1448kB
                                                         ->  Seq Scan on "Posts" p1  (cost=0.00..36677.64 rows=7610 width=12) (actual time=0.021..98.025 rows=17389 loops=1)
                                                               Filter: (("Tags" ~~ '%postgresql%'::text) AND ("PostTypeId" = 1))
                                                               Rows Removed by Filter: 226021
                                             ->  Index Scan using "Posts_pkey" on "Posts" p  (cost=0.42..1.41 rows=1 width=8) (actual time=0.002..0.002 rows=1 loops=21168)
                                                   Index Cond: ("Id" = p2."Id")
                           ->  Hash  (cost=269213706.26..269213706.26 rows=40000 width=72) (actual time=621.854..621.855 rows=41361 loops=1)
                                 Buckets: 65536  Batches: 1  Memory Usage: 3161kB
                                 ->  HashAggregate  (cost=269213306.26..269213706.26 rows=40000 width=72) (actual time=605.763..611.273 rows=41361 loops=1)
                                       Group Key: pt1.tag1, pt1.tag2
                                       Batches: 1  Memory Usage: 5137kB
                                       ->  CTE Scan on "PostTagPairs" pt1  (cost=0.00..195791495.46 rows=9789574773 width=64) (actual time=0.000..506.878 rows=309141 loops=1)
                     ->  Memoize  (cost=0.43..0.56 rows=1 width=8) (actual time=0.000..0.000 rows=1 loops=69294)
                           Cache Key: p."OwnerUserId"
                           Cache Mode: logical
                           Hits: 65320  Misses: 3974  Evictions: 0  Overflows: 0  Memory Usage: 420kB
                           ->  Index Scan using "Users_pkey" on "Users" u  (cost=0.42..0.55 rows=1 width=8) (actual time=0.004..0.004 rows=1 loops=3974)
                                 Index Cond: ("Id" = p."OwnerUserId")
 Planning Time: 2.352 ms
 Execution Time: 1711.712 ms
(63 rows)


План запроса Q2:
                                                                            QUERY PLAN                                                                            
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
 Limit  (cost=52497.93..52497.95 rows=10 width=22) (actual time=207.482..207.485 rows=10 loops=1)
   ->  Sort  (cost=52497.93..52516.59 rows=7466 width=22) (actual time=207.480..207.482 rows=10 loops=1)
         Sort Key: p2."Score"
         Sort Method: top-N heapsort  Memory: 26kB
         ->  Nested Loop  (cost=3.56..52336.59 rows=7466 width=22) (actual time=0.044..205.488 rows=8199 loops=1)
               ->  Merge Join  (cost=3.14..48248.72 rows=7466 width=16) (actual time=0.037..183.031 rows=8969 loops=1)
                     Merge Cond: (p1."AcceptedAnswerId" = p2."Id")
                     ->  Index Scan using idx_posts_ans on "Posts" p1  (cost=0.42..39928.64 rows=7466 width=8) (actual time=0.016..81.828 rows=8970 loops=1)
                           Filter: (("Tags" ~~ '%postgresql%'::text) AND ("PostTypeId" = 1))
                           Rows Removed by Filter: 40876
                     ->  Index Scan using "Posts_pkey" on "Posts" p2  (cost=0.42..39427.27 rows=243494 width=12) (actual time=0.005..80.710 rows=243316 loops=1)
               ->  Index Scan using "Users_pkey" on "Users" u  (cost=0.42..0.55 rows=1 width=14) (actual time=0.002..0.002 rows=1 loops=8969)
                     Index Cond: ("Id" = p2."OwnerUserId")
 Planning Time: 0.889 ms
 Execution Time: 207.525 ms
(15 rows)





