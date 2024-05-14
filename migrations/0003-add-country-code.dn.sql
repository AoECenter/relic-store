BEGIN TRANSACTION;
CREATE TABLE players_new (
    id TEXT PRIMARY KEY,
    profile_id INT UNIQUE,
    name TEXT UNIQUE,
    steam_id TEXT UNIQUE,
    xbox_id TEXT
);
INSERT INTO players_new (id, profile_id, name, steam_id, xbox_id)
SELECT id, profile_id, name, steam_id, xbox_id FROM players;
DROP TABLE players;
ALTER TABLE players_new RENAME TO players;
COMMIT;
