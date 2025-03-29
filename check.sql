SET search_path TO "Dump_schema";

-- Проверяем ограничение "Fk_Badges_Users"
CREATE INDEX users_id_idx ON "Users"("Id");
CREATE INDEX badges_userid_idx ON "Badges"("UserId");
DELETE FROM "Badges" b
WHERE b."UserId" IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM "Users" WHERE "Id" = b."UserId");

-- Проверяем ограничение "Fk_Comments_Posts"
CREATE INDEX posts_id_idx ON "Posts"("Id");
CREATE INDEX comments_postid_idx ON "Comments"("PostId");
DELETE FROM "Comments" c
WHERE c."PostId" IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM "Posts" WHERE "Id" = c."PostId");

-- Проверяем ограничение "Fk_Comments_Users"
CREATE INDEX comments_userid_idx ON "Comments"("UserId");
UPDATE "Comments" c
SET "UserId" = NULL
WHERE c."UserId" IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM "Users" WHERE "Id" = c."UserId");

-- Проверяем ограничение "Fk_PostHistory_Posts"
CREATE INDEX posthistory_postid_idx ON "PostHistory"("PostId");
DELETE FROM "PostHistory" ph
WHERE ph."PostId" IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM "Posts" WHERE "Id" = ph."PostId");

-- Проверяем ограничение "Fk_PostHistory_Users"
CREATE INDEX posthistory_userid_idx ON "PostHistory"("UserId");
UPDATE "PostHistory" ph
SET "UserId" = NULL
WHERE ph."UserId" IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM "Users" WHERE "Id" = ph."UserId");

-- Проверяем ограничение "Fk_PostLinks_Posts"
CREATE INDEX postlinks_postid_idx ON "PostLinks"("PostId");
DELETE FROM "PostLinks" pl
WHERE pl."PostId" IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM "Posts" WHERE "Id" = pl."PostId");

-- Проверяем ограничение "Fk_PostLinks_Posts_001"
CREATE INDEX postlinks_postid001_idx ON "PostLinks"("RelatedPostId");
DELETE FROM "PostLinks" pl
WHERE pl."RelatedPostId" IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM "Posts" WHERE "Id" = pl."RelatedPostId");

-- Проверяем ограничение "Fk_Posts_Users"
CREATE INDEX posts_owneruserid_idx ON "Posts"("OwnerUserId");
UPDATE "Posts" p
SET "OwnerUserId" = NULL
WHERE p."OwnerUserId" IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM "Users" WHERE "Id" = p."OwnerUserId");

-- Проверяем ограничение "Fk_Posts_Users_001"
CREATE INDEX posts_lasteditoruserid_idx ON "Posts"("LastEditorUserId");
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
CREATE INDEX posts_parentid_idx ON "Posts"("ParentId");
UPDATE "Posts" p
SET "ParentId" = NULL
WHERE p."ParentId" IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM "Posts" WHERE "Id" = p."ParentId");

-- Проверяем ограничение "Fk_Tags_Posts"
CREATE INDEX tags_excerptpostid_idx ON "Tags"("ExcerptPostId");
UPDATE "Tags" t
SET "ExcerptPostId" = NULL
WHERE t."ExcerptPostId" IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM "Posts" WHERE "Id" = t."ExcerptPostId");

-- Проверяем ограничение "Fk_Tags_Posts_001"
CREATE INDEX tags_wikipostid_idx ON "Tags"("WikiPostId");
UPDATE "Tags" t
SET "WikiPostId" = NULL
WHERE t."WikiPostId" IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM "Posts" WHERE "Id" = t."WikiPostId");

-- Проверяем ограничение "Fk_Votes_Posts"
CREATE INDEX votes_postid_idx ON "Votes"("PostId");
DELETE FROM "Votes" v
WHERE v."PostId" IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM "Posts" WHERE "Id" = v."PostId");

-- Проверяем ограничение "Fk_Votes_Users"
CREATE INDEX votes_userid_idx ON "Votes"("UserId");
UPDATE "Votes" v
SET "UserId" = NULL
WHERE v."UserId" IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM "Posts" WHERE "Id" = v."UserId");
