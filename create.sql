CREATE TABLE messages (
       'id'                     INTEGER,
       'type'                   INTEGER,

       'text'                   TEXT,
       'created_at'             INTEGER,
       'source'                 TEXT,
       'favorited'              INTEGER,
       'cell_height'            INTEGER,

       'user_id'                INTEGER,
       'name'                   TEXT,
       'screen_name'            TEXT,
       'location'               TEXT,
       'descripton'             TEXT,
       'url'                    TEXT,
       'followers_count'        INTEGER,
       'profile_image_url'      TEXT,
       'protected'              INTEGER,
PRIMARY KEY(type, id)
);

CREATE TABLE followees (
       'user_id'                INTEGER PRIMARY KEY,
       'name'                   TEXT,
       'screen_name'            TEXT,
       'profile_image_url'      TEXT
);

CREATE INDEX users_name on followees(name);
CREATE INDEX users_screen_name on followees(screen_name);

CREATE TABLE images (
       'url'                    TEXT PRIMARY KEY,
       'image'                  BLOB,
       'updated_at'             DATETIME
);

CREATE TABLE queries (
       'query'                  TEXT PRIMARY KEY
);
