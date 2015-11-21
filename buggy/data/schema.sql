--CREATE USER buggy;
--GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO buggy;
--GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public to buggy;

CREATE TABLE programs (
    id SERIAL PRIMARY KEY,
    name VARCHAR(30) NOT NULL
);

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(10) NOT NULL
);

CREATE TABLE issues (
    id            SERIAL PRIMARY KEY,
    program       INTEGER NOT NULL REFERENCES programs(id),
    issue_type    VARCHAR(32) NOT NULL,
    reporter      INTEGER NOT NULL REFERENCES users(id),
    status        VARCHAR(32) NOT NULL,
    type          VARCHAR(32) NOT NULL,
    title         VARCHAR(80) NOT NULL,
    description   TEXT NOT NULL,
    time_reported TIMESTAMP NOT NULL,
    CONSTRAINT status CHECK (status in ('Open', 'Closed', 'Fixed', 'Reproducible', 'NotEnoughInformation')),
    CONSTRAINT type CHECK (type in ('Bug', 'QualityOfLife', 'Feature'))
);

CREATE TABLE reproduction_steps (
    id SERIAL PRIMARY KEY,
    issue INTEGER REFERENCES issues(id) NOT NULL,
    step_number INTEGER NOT NULL,
    instruction VARCHAR(200) NOT NULL
);

CREATE TABLE issue_reports (
    id SERIAL PRIMARY KEY,
    issue INTEGER NOT NULL REFERENCES issues(id),
    description TEXT NOT NULL,
    reporter INTEGER NOT NULL REFERENCES users(id),
    computer_info TEXT,
    time_reported TIMESTAMP
);

CREATE TABLE issue_report_labels (
    issue_report INTEGER REFERENCES issue_reports(id) NOT NULL,
    label VARCHAR(16),
    CONSTRAINT label_value CHECK (label in ('PendingFeedBack', 'Fix', 'PartialFix', 'Unconfirmed', 'Confirmed', 'PartiallyWorking', 'Report'))
);
