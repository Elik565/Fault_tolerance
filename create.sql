CREATE SCHEMA IF NOT EXISTS "Dump_schema";

SET search_path TO "Dump_schema";

CREATE TABLE IF NOT EXISTS "Badges" (
	"Id" int PRIMARY KEY,
	"UserId" int NOT NULL,
	"Name" text NOT NULL,
	"Date" timestamp NOT NULL,
	"Class" smallint NOT NULL,
	"TagBased" bool NOT NULL
);

CREATE TABLE IF NOT EXISTS "Comments" (
	"Id" int PRIMARY KEY,
	"PostId" int NOT NULL,
	"Score" int NOT NULL,
	"Text" text NOT NULL,
	"CreationDate" timestamp NOT NULL,
	"UserDisplayName" text NULL,
	"UserId" int NULL
);

CREATE TABLE IF NOT EXISTS "PostHistory" (
	"Id" int PRIMARY KEY,
	"PostHistoryTypeId" smallint NOT NULL,
	"PostId" int NOT NULL,
	"RevisionGUID" UUID NOT NULL,
	"CreationDate" timestamp NOT NULL,
	"UserId" int,
	"UserDisplayName" text,
	"Comment" text,
	"Text" text
);

CREATE TABLE IF NOT EXISTS "PostLinks" (
	"Id" int PRIMARY KEY,
	"CreationDate" timestamp NOT NULL,
	"PostId" int NOT NULL,
	"RelatedPostId" int NOT NULL,
	"LinkTypeId" int NOT NULL
);	

CREATE TABLE IF NOT EXISTS "Posts" (
	"Id" int PRIMARY KEY,
	"PostTypeId" int NOT NULL,
	"AcceptedAnswerId" int,
	"ParentId" int,
	"CreationDate" timestamp NOT NULL,
	"DeletionDate" timestamp,
	"Score" int NOT NULL,
	"ViewCount" int,
	"Body" text,
	"OwnerUserId" int,
	"OwnerDisplayName" text,
	"LastEditorUserId" int,
	"LastEditorDisplayName" text,
	"LastEditDate" timestamp,
	"LastActivityDate" timestamp,
	"Title" text,
	"Tags" text,
	"AnswerCount" int,
	"CommentCount" int,
	"FavoriteCount" int,
	"ClosedDate" timestamp,
	"CommunityOwnedDate" timestamp
);
	
CREATE TABLE IF NOT EXISTS "Tags" (
	"Id" int PRIMARY KEY,
	"TagName" text,
	"Count" int NOT NULL,
	"ExcerptPostId" int,
	"WikiPostId" int
);
	
CREATE TABLE IF NOT EXISTS "Users" (
	"Id" int PRIMARY KEY,
	"Reputation" int NOT NULL,
	"CreationDate" timestamp NOT NULL,
	"DisplayName" text NULL,
	"LastAccessDate" timestamp NOT NULL,
	"WebsiteUrl" text NULL,
	"Location" text NULL,
	"AboutMe" text NULL,
	"Views" int NOT NULL,
	"UpVotes" int NOT NULL, 
	"DownVotes" int NOT NULL,
	"AccountId" int NULL
);

CREATE TABLE IF NOT EXISTS "Votes" (
	"Id" int PRIMARY KEY,
	"PostId" int NOT NULL,
	"VoteTypeId" smallint NOT NULL,
	"UserId" int,
	"CreationDate" timestamp,
	"BountyAmount" int
);

ALTER TABLE "Badges"
ADD CONSTRAINT "Fk_Badges_Users" FOREIGN KEY ("UserId") 
REFERENCES "Users"("Id");

ALTER TABLE "Comments"
ADD CONSTRAINT "Fk_Comments_Posts" FOREIGN KEY ("PostId") 
REFERENCES "Posts"("Id");

ALTER TABLE "Comments"
ADD CONSTRAINT "Fk_Comments_Users" FOREIGN KEY ("UserId") 
REFERENCES "Users"("Id");

ALTER TABLE "PostHistory"
ADD CONSTRAINT "Fk_PostHistory_Posts" FOREIGN KEY ("PostId") 
REFERENCES "Posts"("Id");

ALTER TABLE "PostHistory"
ADD CONSTRAINT "Fk_PostHistory_Users" FOREIGN KEY ("UserId") 
REFERENCES "Users"("Id");

ALTER TABLE "PostLinks"
ADD CONSTRAINT "Fk_PostLinks_Posts" FOREIGN KEY ("PostId") 
REFERENCES "Posts"("Id");

ALTER TABLE "PostLinks"
ADD CONSTRAINT "Fk_PostLinks_Posts_001" FOREIGN KEY ("RelatedPostId") 
REFERENCES "Posts"("Id");

ALTER TABLE "Posts"
ADD CONSTRAINT "Fk_Posts_Users" FOREIGN KEY ("OwnerUserId") 
REFERENCES "Users"("Id");

ALTER TABLE "Posts"
ADD CONSTRAINT "Fk_Posts_Users_001" FOREIGN KEY ("LastEditorUserId") 
REFERENCES "Users"("Id");

ALTER TABLE "Posts"
ADD CONSTRAINT "Fk_Posts_Posts" FOREIGN KEY ("AcceptedAnswerId") 
REFERENCES "Posts"("Id");

ALTER TABLE "Posts"
ADD CONSTRAINT "Fk_Posts_Posts_001" FOREIGN KEY ("ParentId") 
REFERENCES "Posts"("Id");

ALTER TABLE "Tags"
ADD CONSTRAINT "Fk_Tags_Posts" FOREIGN KEY ("ExcerptPostId") 
REFERENCES "Posts"("Id");

ALTER TABLE "Tags"
ADD CONSTRAINT"Fk_Tags_Posts_001" FOREIGN KEY ("WikiPostId") 
REFERENCES "Posts"("Id");

ALTER TABLE "Votes"
ADD CONSTRAINT "Fk_Votes_Posts" FOREIGN KEY ("PostId") 
REFERENCES "Posts"("Id");

ALTER TABLE "Votes"
ADD CONSTRAINT "Fk_Votes_Users" FOREIGN KEY ("UserId") 
REFERENCES "Users"("Id");

