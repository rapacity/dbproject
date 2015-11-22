




CREATE OR REPLACE FUNCTION get_tag_id(tag text) RETURNS int AS $$
  WITH maybe_insert
    AS (INSERT INTO tags (tag_name)
        SELECT $1
         WHERE NOT EXISTS (SELECT *
                             FROM tags
                            WHERE tag_name = $1)
         RETURNING tag_id)
    SELECT tag_id FROM maybe_insert
  UNION
    SELECT tag_id FROM tags WHERE tag_name = $1;
$$ LANGUAGE SQL;




CREATE OR REPLACE FUNCTION get_user_photo_count(userid int) RETURNS bigint AS $$
  SELECT COALESCE(
   (SELECT COUNT(photo_id)
      FROM photos
      JOIN albums USING (album_id)
     WHERE user_id = $1
     GROUP BY user_id), 0);
$$ LANGUAGE SQL;


CREATE OR REPLACE FUNCTION get_user_comment_count(userid int) RETURNS bigint AS $$
  SELECT COALESCE(
   (SELECT COUNT(comment_id)
      FROM comments
     WHERE user_id = $1
     GROUP BY user_id), 0);
$$ LANGUAGE SQL;


CREATE OR REPLACE FUNCTION get_user_activity(userid int) RETURNS bigint AS $$
  SELECT (get_user_comment_count($1) + get_user_photo_count($1)); 
$$ LANGUAGE SQL;




CREATE OR REPLACE FUNCTION user_untag_photo(userid int, photoid int, tagid int) RETURNS void AS $$
  DELETE FROM photo_tags
   WHERE photo_id = $2
     AND tag_id = $3 
     AND EXISTS (SELECT 1
                   FROM users
                   JOIN albums USING (user_id)
                   JOIN photos USING (album_id)
                  WHERE user_id = $1
                    AND photo_id = $2);
$$ LANGUAGE SQL;
                              

 


CREATE OR REPLACE FUNCTION user_tag_photo(userid int, photoid int, tagname text) RETURNS void AS $$
  INSERT INTO photo_tags (photo_id,tag_id)
  SELECT photo_id, get_tag_id($3)
    FROM photos
    JOIN albums USING (album_id)
    JOIN users USING (user_id)
   WHERE user_id = $1
     AND photo_id = $2;
$$ LANGUAGE SQL;



CREATE OR REPLACE FUNCTION get_album_photo_codelist(albumid int, count int) RETURNS text AS $$
  SELECT COALESCE(
   (WITH album_photos
      AS (SELECT album_id, photo_code,
                 RANK() OVER (PARTITION BY album_id ORDER BY photo_id DESC)
                 AS ranking
            FROM photos)
    SELECT string_agg(photo_code, ',') as photo_codelist
      FROM album_photos
     WHERE album_id = $1
       AND ranking <= $2), '')
$$ LANGUAGE SQL;




CREATE OR REPLACE FUNCTION get_photo_taglist(photoid int) RETURNS text AS $$
  SELECT COALESCE(
   (SELECT string_agg(tag_name, ',') as photo_taglist
      FROM photo_tags
      JOIN tags USING (tag_id)
     WHERE photo_id = $1
     GROUP BY photo_id), '')
$$ LANGUAGE SQL;




CREATE OR REPLACE FUNCTION get_photo_comment_count(photoid int) RETURNS bigint AS $$
  SELECT COALESCE(
   (SELECT COUNT(*) AS photo_comment_count
      FROM comments
     WHERE photo_id = $1
     GROUP BY photo_id), 0);
$$ LANGUAGE SQL;



CREATE OR REPLACE FUNCTION get_album_photo_count(albumid int) RETURNS bigint AS $$
  SELECT COALESCE(
   (SELECT COUNT(*) AS photo_count
      FROM photos
     WHERE album_id = $1
     GROUP BY album_id), 0);
$$ LANGUAGE SQL;







CREATE OR REPLACE FUNCTION get_photo_like_count(photoid int) RETURNS bigint AS $$
  SELECT COALESCE(
   (SELECT COUNT(*) AS photo_like_count
      FROM photo_likes
     WHERE photo_id = $1
     GROUP BY photo_id), 0);
$$ LANGUAGE SQL;



CREATE OR REPLACE FUNCTION untag_photo(photoid INT, tag text) RETURNS void AS $$
  DELETE FROM photo_tags
   WHERE photo_id = $1
     AND tag_id = get_tag_id($2)
$$ LANGUAGE SQL;



CREATE OR REPLACE FUNCTION tag_photo(photoid INT, tag text) RETURNS void AS $$
  INSERT INTO photo_tags (photo_id, tag_id)
  SELECT $1, get_tag_id($2);
$$ LANGUAGE SQL;


DROP VIEW IF EXISTS album_basic;
CREATE OR REPLACE VIEW album_basic AS
  SELECT user_id, album_id, album_name, album_creation
    FROM albums;


DROP VIEW IF EXISTS photo_basic;
CREATE OR REPLACE VIEW photo_basic AS
  SELECT album_id, photo_id, photo_caption, photo_code, photo_creation
    FROM photos;


DROP VIEW IF EXISTS user_basic;
CREATE OR REPLACE VIEW user_basic AS
  SELECT user_id, ARRAY_TO_STRING(ARRAY[user_firstname, user_lastname], ' ') as user_name,
         user_avatar, user_hometown
    FROM users;


DROP VIEW IF EXISTS user_full;
CREATE OR REPLACE VIEW user_full AS
  SELECT user_id, ARRAY_TO_STRING(ARRAY[user_firstname, user_lastname], ' ') as user_name,
         user_avatar, user_gender, user_hometown, user_birthday, user_firstname, user_lastname
    FROM users;


DROP VIEW IF EXISTS user_detail;
CREATE OR REPLACE VIEW user_detail AS
   SELECT user_full.*, get_user_activity(user_id) as user_activity
    FROM user_full;


DROP VIEW IF EXISTS album_full;
CREATE OR REPLACE VIEW album_full AS
  SELECT user_id, user_name, user_avatar, user_hometown,
         album_id, album_name, album_creation,
         get_album_photo_count(album_id) as photo_count
    FROM album_basic
    JOIN user_basic USING (user_id);



DROP VIEW IF EXISTS album_detail;
CREATE OR REPLACE VIEW album_detail AS
  SELECT user_id, user_name, user_avatar, user_hometown,
         album_id, album_name, album_creation,
         get_album_photo_codelist(album_id, 4) as photo_codelist,
         get_album_photo_count(album_id) as photo_count
    FROM album_basic
    JOIN user_basic USING (user_id);




DROP VIEW IF EXISTS photo_full;
CREATE OR REPLACE VIEW photo_full AS
  SELECT user_id, user_name, user_avatar, user_hometown,
         album_id, album_name, album_creation,
         photo_id, photo_caption, photo_code, photo_creation
    FROM photo_basic
    JOIN album_basic USING (album_id)
    JOIN user_basic USING (user_id);



DROP VIEW IF EXISTS photo_detail;
CREATE OR REPLACE VIEW photo_detail AS
  SELECT user_id, user_name, user_avatar, user_hometown,
         album_id, album_name, album_creation,
         photo_id, photo_caption, photo_code, photo_creation,
         get_photo_taglist(photo_id) AS photo_taglist,
         get_photo_like_count(photo_id) AS photo_like_count,
         get_photo_comment_count(photo_id) AS photo_comment_count
    FROM photo_basic
    JOIN album_basic USING (album_id)
    JOIN user_basic USING (user_id);



CREATE OR REPLACE FUNCTION photo_likers(photoid int) RETURNS SETOF user_basic AS $$
  SELECT user_basic.*
    FROM photo_likes
    JOIN user_basic USING (user_id)
   WHERE photo_id = $1;
$$ LANGUAGE SQL;



CREATE OR REPLACE FUNCTION get_user_friends(userid int) RETURNS SETOF user_full AS $$
  WITH user_friends
    AS (SELECT (CASE $1::int WHEN user_ids THEN user_idg ELSE user_ids END)
            AS friend_id
          FROM friends
         WHERE user_ids = $1::int OR user_idg = $1::int)
  SELECT user_full.*
    FROM user_full
    JOIN user_friends
      ON friend_id = user_id
$$ LANGUAGE SQL;



CREATE OR REPLACE FUNCTION get_tag_count(tagid int) RETURNS bigint AS $$
  SELECT COALESCE(
   (SELECT COUNT(photo_id) AS tag_count
      FROM photo_tags
     WHERE tag_id = $1
     GROUP BY tag_id), 0);
$$ LANGUAGE SQL;


-- gets the latest photo id used which used the tag 
CREATE OR REPLACE FUNCTION get_tag_photo_id_and_code(tagid int) RETURNS text AS $$
  SELECT COALESCE(
   (SELECT ARRAY_TO_STRING(ARRAY[photo_id::text, photo_code::text], ' ') AS photo_id_and_code
      FROM photo_tags
      JOIN photos USING (photo_id)
     WHERE tag_id = $1
     ORDER BY photo_id DESC
     LIMIT 1), '');
$$ LANGUAGE SQL;




DROP VIEW IF EXISTS top10_active_users;
CREATE OR REPLACE VIEW top10_active_users AS
  SELECT user_full.*, get_user_activity(user_id) as user_activity
    FROM user_full
   WHERE user_id > 0
   ORDER BY user_activity DESC
   LIMIT 10;




DROP VIEW IF EXISTS tag_detail;
CREATE OR REPLACE VIEW tag_detail AS
  SELECT tag_id, tag_name, get_tag_count(tag_id) as tag_count, get_tag_photo_id_and_code(tag_id) AS photo_id_and_code
    FROM tags;



CREATE OR REPLACE FUNCTION get_user_photos(userid int) RETURNS SETOF int AS $$
  SELECT photo_id
    FROM photos
    JOIN albums USING (album_id)
   WHERE user_id = $1;
$$ LANGUAGE SQL;



