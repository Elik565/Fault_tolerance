explain analyze
SELECT p1."Id" AS question_id, p2."Id" AS answer_id,
p2."Score" AS answer_score, u."DisplayName" AS user_name
FROM "Dump_schema"."Posts" p1
JOIN "Dump_schema"."Posts" p2 ON p1."AcceptedAnswerId" = p2."Id"
JOIN "Dump_schema"."Users" u ON u."Id" = p2."OwnerUserId"
WHERE p1."PostTypeId" = 1 
AND p1."Tags" LIKE '%postgresql%'
ORDER BY p2."Score" ASC
LIMIT 10;
