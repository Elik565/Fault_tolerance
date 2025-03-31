select clock_timestamp() as start_time;

-- создаем таблицу с id поста и его парами тегов
--CREATE INDEX IF NOT EXISTS posts_idtags_idx ON "Dump_schema"."Posts"("Id", "Tags");
CREATE TEMP TABLE "PostTagPairs" AS
WITH tags AS (
    SELECT "Id" AS post_id, unnest(string_to_array("Tags", '|')) AS tag
    FROM "Dump_schema"."Posts"
)
SELECT t1.post_id, LEAST(t1.tag, t2.tag) AS tag1, GREATEST(t1.tag, t2.tag) AS tag2
FROM tags t1
JOIN tags t2 ON t1.post_id = t2.post_id AND t1.tag < t2.tag
WHERE t1.tag <> '' AND t2.tag <> '';
--DROP INDEX "Dump_schema".posts_idtags_idx;

-- создаем таблицу с количеством использований пар тегов
CREATE TEMP table "TagPairUses" AS
SELECT pt1.tag1, pt1.tag2, COUNT(*) AS count
FROM "PostTagPairs" pt1
GROUP BY pt1.tag1, pt1.tag2;

-- создаем таблицу с id вопросов-ответов, у которых есть тег 'postresql'
--CREATE INDEX IF NOT EXISTS posts_parentid_idx ON "Dump_schema"."Posts"("ParentId");
CREATE TEMP TABLE "QueAns" AS
SELECT p1."Id" AS question_id, p2."Id" AS answer_id,
p2."CreationDate" - p1."CreationDate" AS time_response
FROM "Dump_schema"."Posts" p1
JOIN "Dump_schema"."Posts" p2 ON p1."Id" = p2."ParentId"
WHERE p1."PostTypeId" = 1 
AND p2."PostTypeId" = 2
AND p1."Tags" LIKE '%postgresql%';  -- like работает быстрее, чем exists
--DROP INDEX "Dump_schema".posts_parentid_idx;

-- создаем таблицу с id ответов и количеством использований их пар тегов
--CREATE INDEX posttagpairs_tag1tag2_idx ON "PostTagPairs"(tag1, tag2);
--CREATE INDEX tagpairuses_tag1tag2_idx ON "TagPairUses"(tag1, tag2);
CREATE TEMP TABLE "AnsTagPairUses" AS
SELECT qa.answer_id, tpu.tag1, tpu.tag2, qa.time_response, tpu.count
FROM "QueAns" qa 
JOIN "PostTagPairs" ptp ON ptp.post_id = qa.question_id
JOIN "TagPairUses" tpu ON tpu.tag1 = ptp.tag1
AND tpu.tag2 = ptp.tag2;
--DROP INDEX posttagpairs_tag1tag2_idx;
--DROP INDEX tagpairuses_tag1tag2_idx;

SELECT atc.tag1, atc.tag2, AVG(atc.time_response) AS avg_time_response,
avg(u."Reputation") AS avg_reputation, atc.count AS tag_pair_uses
FROM "Dump_schema"."Posts" p
JOIN "AnsTagPairUses" atc ON p."Id" = atc.answer_id 
JOIN "Dump_schema"."Users" u ON u."Id" = p."OwnerUserId"
GROUP BY atc.tag1, atc.tag2, atc.count
ORDER BY atc.count DESC
LIMIT 10;

select clock_timestamp() as end_time;
