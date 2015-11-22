

DROP TYPE IF EXISTS gender CASCADE;
DROP TABLE IF EXISTS users, friends, albums, tags, photos, photo_tags, photo_likes, comments CASCADE;


CREATE TYPE gender
    AS ENUM ('M', 'F', 'N');


CREATE TABLE users (
  user_id        serial  NOT NULL PRIMARY KEY,
  user_firstname text    NOT NULL,
  user_lastname  text    NOT NULL,
  user_email     text    NOT NULL UNIQUE,
  user_birthday  date    NOT NULL,
  user_hometown  text    NOT NULL,
  user_gender    gender  NOT NULL,
  user_password  text    NOT NULL,
  user_avatar    text    NOT NULL,
  user_session   text
 );


CREATE TABLE friends (
  user_ids      integer NOT NULL REFERENCES users (user_id)
                        ON DELETE CASCADE
                        ON UPDATE CASCADE,
  user_idg      integer NOT NULL REFERENCES users (user_id)
                        ON DELETE CASCADE
                        ON UPDATE CASCADE,
  CONSTRAINT cannot_friend_self CHECK (user_ids <> user_idg),
  CONSTRAINT ids_lt_idg         CHECK (user_ids < user_idg),
  PRIMARY KEY (user_ids, user_idg)
);


CREATE TABLE albums (
  album_id       serial  NOT NULL PRIMARY KEY,
  user_id        integer NOT NULL REFERENCES users (user_id)
                         ON DELETE CASCADE
                         ON UPDATE CASCADE, 
  album_name     text    NOT NULL,
  album_creation timestamp DEFAULT current_timestamp NOT NULL,
  CONSTRAINT unique_user_album_name UNIQUE (user_id, album_name),
  CONSTRAINT valid_album_name CHECK (album_name <> '')
);


CREATE TABLE photos (
  photo_id      serial  NOT NULL PRIMARY KEY,
  album_id      integer NOT NULL REFERENCES albums (album_id)
                        ON DELETE CASCADE
                        ON UPDATE CASCADE, 
  photo_caption text    NOT NULL,
  photo_code    text   NOT NULL,
  photo_creation timestamp DEFAULT current_timestamp NOT NULL
);


CREATE TABLE tags (
  tag_id        serial  NOT NULL PRIMARY KEY,
  tag_name      text    NOT NULL UNIQUE
);


CREATE TABLE photo_tags (
  photo_id      integer NOT NULL REFERENCES photos (photo_id)
                        ON DELETE CASCADE
                        ON UPDATE CASCADE, 
  tag_id        integer NOT NULL REFERENCES tags (tag_id)
                        ON DELETE CASCADE
                        ON UPDATE CASCADE,
  PRIMARY KEY (photo_id, tag_id)
);


CREATE TABLE photo_likes (
  photo_id      integer NOT NULL REFERENCES photos (photo_id)
                        ON DELETE CASCADE
                        ON UPDATE CASCADE, 
  user_id       integer NOT NULL REFERENCES users (user_id)
                        ON DELETE CASCADE
                        ON UPDATE CASCADE,
  like_creation timestamp DEFAULT current_timestamp NOT NULL,
  PRIMARY KEY (photo_id, user_id)
);


CREATE TABLE comments (
  comment_id            serial  NOT NULL PRIMARY KEY,
  photo_id              integer NOT NULL REFERENCES photos (photo_id)
                                ON DELETE CASCADE
                                ON UPDATE CASCADE, 
  user_id               integer REFERENCES users (user_id)
                                ON DELETE SET NULL
                                ON UPDATE CASCADE, 
  comment_creation      timestamp DEFAULT current_timestamp NOT NULL,
  comment_body          text    NOT NULL
);


