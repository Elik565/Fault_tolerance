CREATE INDEX idx_posts_parentid ON "Dump_schema"."Posts"("ParentId");

ANALYZE "Dump_schema"."Posts";
ANALYZE "Dump_schema"."Users";

explain analyze
WITH "PostTagPairs" AS (  -- находим пары тегов для каждого поста
    WITH tags AS (
        SELECT "Id" AS post_id, unnest(string_to_array("Tags", '|')) AS tag
        FROM "Dump_schema"."Posts"
    )
    SELECT t1.post_id, LEAST(t1.tag, t2.tag) AS tag1, GREATEST(t1.tag, t2.tag) AS tag2
    FROM tags t1
    JOIN tags t2 ON t1.post_id = t2.post_id AND t1.tag < t2.tag
    WHERE t1.tag <> '' AND t2.tag <> ''
), 
"TagPairUses" AS (  -- находим количество использований пар тегов
    SELECT pt1.tag1, pt1.tag2, COUNT(*) AS count
    FROM "PostTagPairs" pt1
    GROUP BY pt1.tag1, pt1.tag2
), 
"QueAns" AS (  -- находим вопросы-ответы, у которых есть тег 'postgresql'
    SELECT p1."Id" AS question_id, p2."Id" AS answer_id,
           p2."CreationDate" - p1."CreationDate" AS time_response
    FROM "Dump_schema"."Posts" p1
    JOIN "Dump_schema"."Posts" p2 ON p1."Id" = p2."ParentId"
    WHERE p1."PostTypeId" = 1 
    AND p2."PostTypeId" = 2
    AND p1."Tags" LIKE '%postgresql%'
), 
"AnsTagPairUses" AS (  -- находим ответы с количеством использований их пар тегов
    SELECT qa.answer_id, tpu.tag1, tpu.tag2, qa.time_response, tpu.count
    FROM "QueAns" qa 
    JOIN "PostTagPairs" ptp ON ptp.post_id = qa.question_id
    JOIN "TagPairUses" tpu ON tpu.tag1 = ptp.tag1 AND tpu.tag2 = ptp.tag2
) 
SELECT atc.tag1, atc.tag2, AVG(EXTRACT(EPOCH FROM atc.time_response) / 60) AS avg_time_response,
       AVG(u."Reputation") AS avg_reputation, atc.count AS tag_pair_uses
FROM "Dump_schema"."Posts" p
JOIN "AnsTagPairUses" atc ON p."Id" = atc.answer_id 
JOIN "Dump_schema"."Users" u ON u."Id" = p."OwnerUserId"
GROUP BY atc.tag1, atc.tag2, atc.count
ORDER BY atc.count DESC
LIMIT 10;

DROP INDEX idx_posts_parentid 
