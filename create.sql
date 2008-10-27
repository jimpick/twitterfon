CREATE TABLE messages (
       'id'                     INTEGER,
       'type'                   INTEGER,

       'text'                   TEXT,
       'created_at'             INTEGER,
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
       'protected'              INTEGER,

       'cell_height'            INTEGER,

PRIMARY KEY(type, id)
);

CREATE TABLE images (
       'url'                    TEXT PRIMARY KEY,
       'image'                  BLOB,
       'updated_at'             DATETIME
);

CREATE TABLE queries (
       'query'                  TEXT PRIMARY KEY
);
