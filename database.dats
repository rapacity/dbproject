

//=============================================================================
//||                              S0                                         ||
//=============================================================================

fun get_session_user(db: !dbconn, sess: string): dbresult =
  db.query(
    "SELECT user_id
       FROM users
      WHERE user_session = ($1::text)", sess)


fun trending_tags(db: !dbconn): dbresult =
  db.query(
    "SELECT *
       FROM tag_detail
      WHERE tag_count > 0
      ORDER BY tag_count DESC;")


//=============================================================================
//||                              S1                                         ||
//=============================================================================


// Create a new user account, constraint on email ensures the command will
// error if there is a duplicate
fun make_user
  (db: !dbconn, fname: string, lname: string, email: string,
     birthday: string, hometown: string, gender: string, password: string,
      avatar: string): dbresult = 
  db.query(
    "INSERT INTO users (
       user_firstname,
       user_lastname,
       user_email,
       user_birthday,
       user_hometown,
       user_gender,
       user_password,
       user_avatar)
     VALUES ($1, $2, $3, $4, $5, $6, md5($7), $8)",
      fname, lname, email, birthday, hometown, gender, password, avatar)
 

// Login the user, return the session value on success
fun user_login(db: !dbconn, email: string, pass: string): dbresult =
  db.query(
    "UPDATE users
        SET user_session = uuid_in(md5(random()::text || now()::text)::cstring) 
      WHERE user_email = $1
        AND user_password = md5($2)
  RETURNING user_session", email, pass)


// Search the users by name similarity
fun find_users(db: !dbconn, name: string): dbresult =
  db.query(
    "SELECT *
       FROM user_full
      WHERE user_name ILIKE $1
        AND user_id > 0", name)

// Add friend ensuring the ordering constraint on user_ids is maintained
fun add_friend(db: !dbconn, user_id: string, friend_id: string): dbresult =
  db.query(
    "INSERT INTO friends (user_ids, user_idg)
     VALUES (LEAST($1::int, $2::int), GREATEST($1::int, $2::int));",
     user_id, friend_id)

// Delete friend taking into account the ordering of ids
fun delete_friend(db: !dbconn, user_id: string, friend_id: string): dbresult =
  db.query(
    "DELETE FROM friends
      WHERE user_ids = LEAST($1::int, $2::int)
        AND user_idg = GREATEST($1::int, $2::int)", user_id, friend_id)


// Get the "user_full" view info of all the user's friends
fun get_user_friends(db: !dbconn, user_id: string): dbresult =
  db.query(
    "SELECT *
       FROM get_user_friends($1);", user_id)

// Get the user along with details such as their activity points
fun get_user(db: !dbconn, user_id: string): dbresult =
  db.query(
    "SELECT *
       FROM user_detail
      WHERE user_id = $1;", user_id)

// Get top active users by activity points
fun top10_active_users(db: !dbconn): dbresult =
  db.query(
    "SELECT *
       FROM user_detail
      WHERE user_id > 0
      ORDER BY user_activity DESC
      LIMIT 10;")


//=============================================================================
//||                              S2                                         ||
//=============================================================================

// Get user albums by user_id
fun get_user_albums(db: !dbconn, user_id: string): dbresult =
  db.query(
    "SELECT * 
       FROM album_detail
      WHERE user_id = $1;", user_id)


// Get album by album_id
fun get_album(db: !dbconn, album_id: string): dbresult =
  db.query(
    "SELECT *
       FROM album_detail
      WHERE album_id = $1", album_id)


// Grab album photos with extra details such as like count, comment count
fun get_album_photos(db: !dbconn, album_id: string): dbresult =
  db.query(
    "SELECT *
       FROM photo_detail
      WHERE album_id = $1;", album_id)


// Grab the photo along with relevant info
fun get_photo(db: !dbconn, photo_id: string): dbresult = 
  db.query(
    "SELECT *
      FROM photo_full
     WHERE photo_id = $1;", photo_id)


// Create a new album and get back the new id, and creation time for it
fun make_album(db: !dbconn, user_id: string, name: string): dbresult =
  db.query(
    "INSERT INTO albums (user_id, album_name)
     VALUES ($1, $2)
  RETURNING album_id, album_creation;", user_id, name)


// Create a new photo iff the user owns the album
fun make_photo(db: !dbconn, user_id: string, album_id: string, photo_caption: string, photo_file: string): dbresult =
  db.query(
    "WITH user_owned_album
       AS (SELECT album_id
             FROM albums
            WHERE album_id = $2
              AND user_id = $1)
     INSERT INTO photos (album_id, photo_caption, photo_code)
          SELECT album_id, $3, $4
            FROM user_owned_album
       RETURNING photo_id;", user_id, album_id, photo_caption, photo_file)


// Delete photo iff user owns the photo
fun delete_photo(db: !dbconn, user_id: string, photo_id: string): dbresult =
  db.query(
    "DELETE FROM photos 
      WHERE photo_id = $2
        AND album_id IN (SELECT album_id
                           FROM albums
                          WHERE user_id = $1);", user_id, photo_id)

// Delete the user album, the query cascades deleting photos, comments,
// and likes within it
fun delete_album(db: !dbconn, user_id: string, album_id: string): dbresult =
  db.query(
    "DELETE FROM albums
      WHERE user_id = $1                              
        AND album_id = $2;", user_id, album_id)

//=============================================================================
//||                              S3                                         ||
//=============================================================================

// Allows search for photos via the following criteria:
// - Searches by user_id if user_id > 0
// - Searches by album_id if album_id > 0
// - Filter conjuctive tag queries
// - Exclusion of specified tags
fun find_photos(db: !dbconn, user_id: string, album_id: string, caption: string, filter: string, exclude: string): dbresult =
  db.query(
    "WITH filter_tags AS (SELECT unnest($4::text[]) as tag_name),
         exclude_tags AS (SELECT unnest($5::text[]) as tag_name),
       filter_tag_ids AS (SELECT tag_id
                            FROM tags
                            JOIN filter_tags USING (tag_name)),
      exclude_tag_ids AS (SELECT tag_id
                            FROM tags
                            JOIN exclude_tags USING (tag_name)),
       matches_by_tag AS (SELECT photo_id
                            FROM photos
                       LEFT JOIN photo_tags USING (photo_id)
                           GROUP BY photo_id
                          HAVING (SELECT COUNT(tag_name) FROM filter_tags)
                                   = SUM(CASE (tag_id IN (SELECT * FROM filter_tag_ids))
                                         WHEN TRUE
                                         THEN 1
                                         ELSE 0
                                         END)
                             AND 0 = SUM(CASE (tag_id IN (SELECT * FROM exclude_tag_ids))
                                         WHEN TRUE
                                         THEN 1
                                         ELSE 0
                                         END))
     SELECT photo_detail.*
       FROM matches_by_tag
       JOIN photo_detail USING (photo_id)
      WHERE ($1 = 0 OR $1 = user_id)
        AND ($2 = 0 or $2 = album_id)
        AND photo_caption ILIKE $3",
    user_id, album_id, caption, filter, exclude)

                
fun tag_photo(db: !dbconn, user_id: string, photo_id: string, tag: string): dbresult =
  db.query(
    "SELECT user_tag_photo($1::int, $2::int, $3::text);",
    user_id, photo_id, tag)

fun untag_photo(db: !dbconn, user_id: string, photo_id: string, tag: string): dbresult =
  db.query(
      "SELECT user_untag_photo($1::int, $2::int, $3::int)",
      user_id, photo_id, tag)

//=============================================================================
//||                              S4                                         ||
//=============================================================================


// Registered users can make comments
// The "user_owned_photo" subquery ensures that the user doesn't own the photo
// Anonymous users can make comments too
fun make_comment(db: !dbconn, user_id: string, photo_id: string, body: string): dbresult =
  db.query(
    "WITH user_owned_photo
              AS (SELECT 1
                    FROM photos
                    JOIN albums USING(album_id)
                   WHERE user_id = $1
                     AND photo_id = $2)
          INSERT INTO comments (user_id, photo_id, comment_body)
          SELECT $1, $2, $3
           WHERE NOT EXISTS (SELECT * FROM user_owned_photo)
       RETURNING comment_id", user_id, photo_id, body)

// Add a like to a photo
fun make_like(db: !dbconn, user_id: string, photo_id: string): dbresult =
  db.query(
    "INSERT INTO photo_likes (user_id, photo_id)
     VALUES ($1, $2)", user_id, photo_id)

// The number of rows is the number of likes
// Users who liked the photo first will appear first on the list
fun get_photo_likes(db: !dbconn, photo_id: string): dbresult =
  db.query(
    "SELECT user_basic.*
       FROM photo_likes
       JOIN user_basic USING (user_id)
      WHERE photo_id = $1
      ORDER BY like_creation ASC;", photo_id)


fun get_photo_comments(db: !dbconn, photo_id: string): dbresult =
  db.query(
    "SELECT user_full.*, comment_id, comment_body, comment_creation
       FROM comments
       JOIN user_full USING (user_id)
      WHERE photo_id = $1
      ORDER BY comment_creation DESC;", photo_id)


fun get_photo_tags(db: !dbconn, photo_id: string): dbresult =
  db.query(
    "SELECT tag_id, tag_name
       FROM photo_tags
       JOIN tags USING (tag_id)
      WHERE photo_id = $1;", photo_id)


//=============================================================================
//||                              S5                                         ||
//=============================================================================

// It is worth noting that my solutions aren't ansi-sql compliant because
// I did not select the columns which I use in my "ORDER BY" statements.
// - "favorite_5tags" counts the number of photos belonging to the user in each
//   tag_id group that they've used at least once, it then orders the row from
//   highest group row count to lowest, finally it only selects at most 5 row
//   "tag_id"s.
// - "photo_matches" counts the number of tags a photo has, and the
//   number of tags the photo has that are in the user's top 5 favorite.
//   I sometimes wonder why implementors do not support boolean to integer
//   casting, in any case a case statement had to be used.
// - I finally select the matching photos taking care to not recommend to
//   the user their own photos, and to sort the results in a manner satisfying
//   the requirements of higher match count on the top, and within each
//   match count group, it then lists from lowest tag count to most/
fun recommended_photos(db: !dbconn, user_id: string): dbresult =
  db.query(
    "WITH favorite_5tags AS
                 (SELECT tag_id
                    FROM photo_tags
                    JOIN photos USING (photo_id)
                    JOIN albums USING (album_id)
                   WHERE user_id = $1
                   GROUP BY tag_id
                   ORDER BY COUNT(photo_id) DESC
                   LIMIT 5),
                 photo_matches AS
                 (SELECT photo_id,
                         COUNT(tag_id)
                           AS photo_tag_count,
                         SUM(CASE (tag_id IN (SELECT * FROM favorite_5tags))
                             WHEN TRUE
                             THEN 1
                             ELSE 0
                             END)
                           AS photo_match_count
                    FROM photo_tags
                   GROUP BY photo_id)
          SELECT photo_detail.*
            FROM photo_detail
            JOIN photo_matches USING (photo_id)
           WHERE user_id <> $1
           ORDER BY photo_match_count DESC,
                    photo_tag_count ASC;", user_id)

// The query assumes a sufficiently smart query optimizer, it can also
// continue to provide suggestions even if the photo has more than two tags.
// Note: if the user has no tagged photos, this query will return the set of
// tagged photos as opposed to the entire set of photos.
// - "user_target_photo_tags" grabs the tag_ids of the user photo 
// - "photo_matches" grabs the user's photos that have all the tags
//    of our target photo, it works by only selecting rows that have
//    a tag_id in the "target" photo's tags, after grouping them by photo
//    it checks to ensure that the count of the rows in a photo group is
//    equivalent to the number of rows in the tags from "user_target_photo_tags"
// - finally we select the tag_id and tag_name of all photos not already used
//   on our target photo, we also have an extra condition that ensures that
//   our query only activates if the photo has at least 2 tags.
fun recommended_tags(db: !dbconn, user_id: string, photo_id: string): dbresult = 
  db.query(
    "WITH user_target_photo_tags AS                                     
          (SELECT tag_id                                                
             FROM photo_tags                                            
             JOIN photos USING (photo_id)                               
             JOIN albums USING (album_id)                               
            WHERE user_id = $1                                          
              AND photo_id = $2),                                       
          photo_matches AS                                              
          (SELECT photo_id                                              
             FROM photo_tags                                            
             JOIN photos USING (photo_id)                               
             JOIN albums USING (album_id)                               
            WHERE user_id = $1                                          
              AND tag_id IN (SELECT * FROM user_target_photo_tags)      
            GROUP BY photo_id                                           
           HAVING COUNT(tag_id) = (SELECT COUNT(*)                      
                                     FROM user_target_photo_tags))      
     SELECT tag_id, tag_name                                            
       FROM photo_matches                                               
       JOIN photo_tags USING (photo_id)                                 
       JOIN tags USING (tag_id)                                         
      WHERE tag_id NOT IN (SELECT * FROM user_target_photo_tags)        
        AND (SELECT COUNT(*) FROM user_target_photo_tags) >= 2          
      GROUP BY tag_id, tag_name                                         
      ORDER BY COUNT(photo_id) DESC;", user_id, photo_id)                



