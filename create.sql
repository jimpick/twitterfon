CREATE TABLE messages (
       'id'                     INTEGER,
       'type'                   INTEGER,

       'text'                   TEXT,
       'created_at'             DATETIME,
       'source'                 TEXT,
       'favorited'              INTEGER,

       'user_id'                INTEGER,
       'name'                   TEXT,
       'screen_name'            TEXT,
       'location'               TEXT,
       'descripton'             TEXT,
       'url'                    TEXT,
       'followers_count'        INTEGER,
       'profile_image_url'      TEXT,
PRIMARY KEY(id, type)
);

CREATE TABLE images (
       'user_id'                INTEGER PRIMARY KEY,
       'url'                    TEXT,
       'image'                  BLOB,
       'large_image'            BLOB,
       'updated_at'             DATETIME
);