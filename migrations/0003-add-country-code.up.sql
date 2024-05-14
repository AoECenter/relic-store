BEGIN TRANSACTION;
ALTER TABLE players ADD COLUMN country_code TEXT NULL;
CREATE TABLE players_new (
    id TEXT PRIMARY KEY,
    profile_id INT UNIQUE,
    name TEXT UNIQUE,
    steam_id TEXT UNIQUE,
    xbox_id TEXT,
    country_code TEXT NULL,
    FOREIGN KEY (country_code) REFERENCES countries(code)
);
INSERT INTO players_new (id, profile_id, name, steam_id, xbox_id, country_code)
SELECT id, profile_id, name, steam_id, xbox_id, country_code FROM players;
DROP TABLE players;
ALTER TABLE players_new RENAME TO players;
COMMIT;
