#!/bin/bash

csv_dir_path="$1"
db_name="$2"

if [ -z "$csv_dir_path" ]; then
    echo "Не передан путь до csv директории!"
    exit 1
fi

if [ -z "$db_name" ]; then
    echo "Не передано название базы данных!"
    exit 1
fi

# загружаем Badges
psql -d "$db_name" -c "ALTER TABLE \"Dump_schema\".\"Badges\" DISABLE TRIGGER ALL"
psql -d "$db_name" -c "\
\COPY \"Dump_schema\".\"Badges\"(\"Class\", \"Date\", \"Id\", \"Name\", \"TagBased\", \"UserId\") 
FROM '$csv_dir_path/Badges.csv' 
WITH CSV HEADER"
psql -d "$db_name" -c "ALTER TABLE \"Dump_schema\".\"Badges\" ENABLE TRIGGER ALL"

# загружаем Comments
psql -d "$db_name" -c "ALTER TABLE \"Dump_schema\".\"Comments\" DISABLE TRIGGER ALL"
psql -d "$db_name" -c "\
\COPY \"Dump_schema\".\"Comments\"(\"CreationDate\", \"Id\", \"PostId\", \"Score\", \"Text\", \"UserDisplayName\", \"UserId\") 
FROM '$csv_dir_path/Comments.csv' 
WITH CSV HEADER"
psql -d "$db_name" -c "ALTER TABLE \"Dump_schema\".\"Comments\" ENABLE TRIGGER ALL"

# загружаем PostHistory
psql -d "$db_name" -c "ALTER TABLE \"Dump_schema\".\"PostHistory\" DISABLE TRIGGER ALL"
psql -d "$db_name" -c "\
\COPY \"Dump_schema\".\"PostHistory\"(\"Comment\", \"CreationDate\", \"Id\", \"PostHistoryTypeId\", \"PostId\", \"RevisionGUID\", \"Text\", \"UserDisplayName\", \"UserId\") 
FROM '$csv_dir_path/PostHistory.csv' 
WITH CSV HEADER"
psql -d "$db_name" -c "ALTER TABLE \"Dump_schema\".\"PostHistory\" ENABLE TRIGGER ALL"

# загружаем PostLinks
psql -d "$db_name" -c "ALTER TABLE \"Dump_schema\".\"PostLinks\" DISABLE TRIGGER ALL"
psql -d "$db_name" -c "\
\COPY \"Dump_schema\".\"PostLinks\"(\"CreationDate\", \"Id\", \"LinkTypeId\", \"PostId\", \"RelatedPostId\") 
FROM '$csv_dir_path/PostLinks.csv' 
WITH CSV HEADER"
psql -d "$db_name" -c "ALTER TABLE \"Dump_schema\".\"PostLinks\" ENABLE TRIGGER ALL"

# загружаем Posts
psql -d "$db_name" -c "ALTER TABLE \"Dump_schema\".\"Posts\" DISABLE TRIGGER ALL"
psql -d "$db_name" -c "\
\COPY \"Dump_schema\".\"Posts\"(\"AcceptedAnswerId\", \"AnswerCount\", \"Body\", \"ClosedDate\", \"CommentCount\", \"CommunityOwnedDate\", \"CreationDate\", \"FavoriteCount\", \"Id\", \"LastActivityDate\", \"LastEditDate\", \"LastEditorDisplayName\", \"LastEditorUserId\", \"OwnerDisplayName\", \"OwnerUserId\", \"ParentId\", \"PostTypeId\", \"Score\", \"Tags\", \"Title\", \"ViewCount\") 
FROM '$csv_dir_path/Posts.csv' 
WITH CSV HEADER"
psql -d "$db_name" -c "ALTER TABLE \"Dump_schema\".\"Posts\" ENABLE TRIGGER ALL"

# загружаем Tags
psql -d "$db_name" -c "ALTER TABLE \"Dump_schema\".\"Tags\" DISABLE TRIGGER ALL"
psql -d "$db_name" -c "\
\COPY \"Dump_schema\".\"Tags\"(\"Count\", \"ExcerptPostId\", \"Id\", \"TagName\", \"WikiPostId\") 
FROM '$csv_dir_path/Tags.csv' 
WITH CSV HEADER"
psql -d "$db_name" -c "ALTER TABLE \"Dump_schema\".\"Tags\" ENABLE TRIGGER ALL"

# загружаем Users
psql -d "$db_name" -c "ALTER TABLE \"Dump_schema\".\"Users\" DISABLE TRIGGER ALL"
psql -d "$db_name" -c "\
\COPY \"Dump_schema\".\"Users\"(\"AboutMe\", \"AccountId\", \"CreationDate\", \"DisplayName\", \"DownVotes\", \"Id\", \"LastAccessDate\", \"Location\", \"Reputation\", \"UpVotes\", \"Views\", \"WebsiteUrl\") 
FROM '$csv_dir_path/Users.csv' 
WITH CSV HEADER"
psql -d "$db_name" -c "ALTER TABLE \"Dump_schema\".\"Badges\" ENABLE TRIGGER ALL"

# загружаем Votes
psql -d "$db_name" -c "ALTER TABLE \"Dump_schema\".\"Votes\" DISABLE TRIGGER ALL"
psql -d "$db_name" -c "\
\COPY \"Dump_schema\".\"Votes\"(\"BountyAmount\", \"CreationDate\", \"Id\", \"PostId\", \"UserId\", \"VoteTypeId\") 
FROM '$csv_dir_path/Votes.csv' 
WITH CSV HEADER"
psql -d "$db_name" -c "ALTER TABLE \"Dump_schema\".\"Votes\" ENABLE TRIGGER ALL"



