CREATE TABLE IF NOT EXISTS users
(
    id         TEXT      PRIMARY KEY NOT NULL,
    username   TEXT      NOT NULL UNIQUE,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP,
    deleted_at TIMESTAMP
);
