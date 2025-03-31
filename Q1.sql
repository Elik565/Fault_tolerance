SELECT clock_timestamp() AS start_time;

-- создаем таблицу с id поста и его парами тегов
CREATE TEMP TABLE "PostTagPairs" AS
WITH tags AS (
    SELECT "Id" AS post_id, unnest(string_to_array("Tags", '|')) AS tag
    FROM "Dump_schema"."Posts"
)
SELECT t1.post_id, LEAST(t1.tag, t2.tag) AS tag1, GREATEST(t1.tag, t2.tag) AS tag2
FROM tags t1
JOIN tags t2 ON t1.post_id = t2.post_id AND t1.tag < t2.tag
WHERE t1.tag <> '' and t2.tag <> '';

-- создаем таблицу с количеством использований пар тегов
create TEMP table "TagPairUses" as
SELECT pt1.tag1, pt1.tag2, COUNT(*) AS count
FROM "PostTagPairs" pt1
GROUP BY pt1.tag1, pt1.tag2;

-- создаем таблицу с id вопросов-ответов, у которых есть тег 'postresql'
create TEMP table "QueAns" as
SELECT p1."Id" as question_id, p2."Id" as answer_id,
p2."CreationDate" - p1."CreationDate" as time_response
FROM "Dump_schema"."Posts" p1
JOIN "Dump_schema"."Posts" p2 ON p1."Id" = p2."ParentId"
WHERE p1."PostTypeId" = 1 
AND p2."PostTypeId" = 2
AND p1."Tags" LIKE '%postgresql%';  -- like работает быстрее, чем exists

-- создаем таблицу с id ответов и количеством использований их пар тегов
create TEMP table "AnsTagPairUses" as
select qa.answer_id, tpu.tag1, tpu.tag2, qa.time_response, tpu.count
from "QueAns" qa 
join "PostTagPairs" ptp on ptp.post_id = qa.question_id
join "TagPairUses" tpu on tpu.tag1 = ptp.tag1
and tpu.tag2 = ptp.tag2;
 
select atc.tag1, atc.tag2, AVG(atc.time_response) AS avg_time_response,
avg(u."Reputation") as avg_reputation, atc.count as tag_pair_uses
from "Dump_schema"."Posts" p
join "AnsTagPairUses" atc on p."Id" = atc.answer_id 
join "Dump_schema"."Users" u on u."Id" = p."OwnerUserId"
group by atc.tag1, atc.tag2, atc.count
order by atc.count desc
limit 10;

SELECT clock_timestamp() AS end_time;
