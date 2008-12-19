DROP INDEX users_name;
DROP INDEX users_screen_name;

CREATE TABLE statuses (
   'id'                         INTEGER,
    'type'                      INTEGER,
    'user_id'                   INTEGER,
    'text'                      TEXT,
    'created_at'                INTEGER,
    'source'                    TEXT,
    'favorited'                 INTEGER,
    'truncated'                 INTEGER,
    'in_reply_to_status_id'     INTEGER,
    'in_reply_to_user_id'       INTEGER,
    'in_reply_to_screen_name'   TEXT,
PRIMARY KEY(type, id)
);
CREATE INDEX statuses_in_reply_to_status_id on statuses(in_reply_to_status_id);

CREATE TABLE direct_messages (
    'id'                     INTEGER,
    'sender_id'              INTEGER,
    'recipient_id'           INTEGER,
    'text'                   TEXT,
    'created_at'             INTEGER,
    'sender_screen_name'     TEXT,
    'recipient_screen_name'  TEXT,
PRIMARY KEY(id)
);
CREATE INDEX direct_messages_sender_id on direct_messages(sender_id);
CREATE INDEX direct_messages_recipient_id on direct_messages(recipient_id);

CREATE TABLE users (
    'user_id'                INTEGER PRIMARY KEY,
    'name'                   TEXT,
    'screen_name'            TEXT,
    'location'               TEXT,
    'description'            TEXT,
    'url'                    TEXT,
    'followers_count'        INTEGER,
    'profile_image_url'      TEXT,
    'protected'              INTEGER
);
CREATE INDEX users_name on users(name);
CREATE INDEX users_screen_name on users(screen_name);

CREATE INDEX followees_name on followees(name);
CREATE INDEX followees_screen_name on followees(screen_name);

BEGIN;
INSERT INTO users (user_id, name, screen_name, profile_image_url) SELECT * FROM followees;
UPDATE users SET location = '', description = '', url = '';
REPLACE INTO users SELECT user_id, name, screen_name, location, descripton, url, followers_count, profile_image_url, protected FROM messages ORDER BY id;
INSERT INTO statuses (id, type, user_id, text, created_at, source, favorited) SELECT id, type, user_id, text, created_at, source, favorited FROM messages WHERE messages.type != 2;
UPDATE statuses SET in_reply_to_screen_name = '';
COMMIT;

DROP TABLE messages;

REINDEX statuses;
REINDEX users;
REINDEX images;
ANALYZE statuses;
ANALYZE images;
ANALYZE users;
VACUUM;