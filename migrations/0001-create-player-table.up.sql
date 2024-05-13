BEGIN TRANSACTION;
CREATE TABLE players (
    id TEXT PRIMARY KEY,
    profile_id INT UNIQUE,
    name TEXT UNIQUE,
    steam_id TEXT UNIQUE, xbox_id TEXT);
COMMIT;
