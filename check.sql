SET search_path TO "Dump_schema";

-- Проверяем ограничение "Fk_Badges_Users"
DELETE FROM "Badges" b
WHERE b."UserId" IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM "Users" WHERE "Id" = b."UserId");

-- Проверяем ограничение "Fk_Comments_Posts"
DELETE FROM "Comments" c
WHERE c."PostId" IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM "Posts" WHERE "Id" = c."PostId");

-- Проверяем ограничение "Fk_Comments_Users"
UPDATE "Comments" c
SET "UserId" = NULL
WHERE c."UserId" IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM "Users" WHERE "Id" = c."UserId");

-- Проверяем ограничение "Fk_PostHistory_Posts"
DELETE FROM "PostHistory" ph
WHERE ph."PostId" IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM "Posts" WHERE "Id" = ph."PostId");

-- Проверяем ограничение "Fk_PostHistory_Users"
UPDATE "PostHistory" ph
SET "UserId" = NULL
WHERE ph."UserId" IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM "Users" WHERE "Id" = ph."UserId");

-- Проверяем ограничение "Fk_PostLinks_Posts"
DELETE FROM "PostLinks" pl
WHERE pl."PostId" IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM "Posts" WHERE "Id" = pl."PostId");

-- Проверяем ограничение "Fk_PostLinks_Posts_001"
DELETE FROM "PostLinks" pl
WHERE pl."RelatedPostId" IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM "Posts" WHERE "Id" = pl."RelatedPostId");

-- Проверяем ограничение "Fk_Posts_Users"
UPDATE "Posts" p
SET "OwnerUserId" = NULL
WHERE p."OwnerUserId" IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM "Users" WHERE "Id" = p."OwnerUserId");

-- Проверяем ограничение "Fk_Posts_Users_001"
UPDATE "Posts" p
SET "LastEditorUserId" = NULL
WHERE p."LastEditorUserId" IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM "Users" WHERE "Id" = p."LastEditorUserId");

-- Проверяем ограничение "Fk_Posts_Posts"
CREATE INDEX posts_acceptedanswerid_idx ON "Posts"("AcceptedAnswerId");
UPDATE "Posts" p
SET "AcceptedAnswerId" = NULL
WHERE p."AcceptedAnswerId" IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM "Posts" WHERE "Id" = p."AcceptedAnswerId");

-- Проверяем ограничение "Fk_Posts_Posts_001"
UPDATE "Posts" p
SET "ParentId" = NULL
WHERE p."ParentId" IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM "Posts" WHERE "Id" = p."ParentId");

-- Проверяем ограничение "Fk_Tags_Posts"
UPDATE "Tags" t
SET "ExcerptPostId" = NULL
WHERE t."ExcerptPostId" IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM "Posts" WHERE "Id" = t."ExcerptPostId");

-- Проверяем ограничение "Fk_Tags_Posts_001"
UPDATE "Tags" t
SET "WikiPostId" = NULL
WHERE t."WikiPostId" IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM "Posts" WHERE "Id" = t."WikiPostId");

-- Проверяем ограничение "Fk_Votes_Posts"
DELETE FROM "Votes" v
WHERE v."PostId" IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM "Posts" WHERE "Id" = v."PostId");

-- Проверяем ограничение "Fk_Votes_Users"
UPDATE "Votes" v
SET "UserId" = NULL
WHERE v."UserId" IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM "Posts" WHERE "Id" = v."UserId");

-- Узнаем конечное время
SELECT clock_timestamp() AS end_time
