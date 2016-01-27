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
    edit_time     TIMESTAMP,
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
    type VARCHAR(20) NOT NULL,
    status VARCHAR(20) NOT NULL,
    time_reported TIMESTAMP,
    confirmed BOOLEAN NOT NULL DEFAULT TRUE, -- assume that when submits  their report they can confirm its behaviour
    CONSTRAINT report_type CHECK (type in ('Fix', 'PartialFix', 'Report')),
    CONSTRAINT status_value CHECK 
        ((type = 'Report' 
            AND status IN ('Fixed', 'Broken', 'Working', 'PartiallyWorking')) 
        OR ((type = 'Fix' OR type = 'PartialFix') 
            AND status IN ('Works', 'NoWork')))
);

CREATE TABLE issue_report_comments (
    id SERIAL PRIMARY KEY,
    issue_report INTEGER NOT NULL REFERENCES issue_reports(id),
    text VARCHAR(512) NOT NULL,
    time_created TIMESTAMP NOT NULL DEFAULT NOW(),
    edit_time TIMESTAMP,
    commenter INTEGER NOT NULL REFERENCES users(id),
    parent_comment INTEGER REFERENCES issue_report_comments(id)
);

CREATE TABLE issue_comments (
    id SERIAL PRIMARY KEY,
    issue INTEGER NOT NULL REFERENCES issue(id),
    text VARCHAR(512) NOT NULL,
    time_created TIMESTAMP NOT NULL DEFAULT NOW(),
    edit_time TIMESTAMP,
    commenter INTEGER NOT NULL REFERENCES users(id),
    parent_comment INTEGER REFERENCES issue_comments(id)
);
