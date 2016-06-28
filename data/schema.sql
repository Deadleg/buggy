--CREATE USER buggy;
--GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO buggy;
--GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public to buggy;

CREATE TABLE programs (
    id SERIAL PRIMARY KEY,
    image     VARCHAR(50) NOT NULL,
    name      VARCHAR(30) NOT NULL
);

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(64) UNIQUE,
    username  VARCHAR(10) NOT NULL UNIQUE,
    login_type  VARCHAR(10) NOT NULL,
    auto_issue_subscription BOOLEAN DEFAULT FALSE,
    steam_id VARCHAR(64),
    CONSTRAINT login_types CHECK (login_type in ('Google', 'Steam')),
    CONSTRAINT steam_id CHECK (login_type='Steam' AND steam_id IS NOT NULL),
);

CREATE TABLE issues (
    id            SERIAL PRIMARY KEY,
    issue_number  INTEGER NOT NULL, -- program/1/issues/{issue_number}
    program       INTEGER NOT NULL REFERENCES programs(id),
    issue_type    VARCHAR(32) NOT NULL,
    reporter      INTEGER NOT NULL REFERENCES users(id),
    status        VARCHAR(32) NOT NULL,
    type          VARCHAR(32) NOT NULL,
    title         VARCHAR(80) NOT NULL,
    description   TEXT NOT NULL,
    time_reported TIMESTAMP NOT NULL,
    time_fixed    TIMESTAMP,
    edit_time     TIMESTAMP,
    upvotes       INTEGER NOT NULL DEFAULT 0,
    CONSTRAINT status
        CHECK (status in ('Open', 'Closed', 'Fixed', 'Reproducible', 'NotEnoughInformation')),
    CONSTRAINT type
        CHECK (type in ('Bug', 'QualityOfLife', 'Feature'))
);

CREATE TABLE issue_watchers (
    id SERIAL PRIMARY KEY,
    issue INTEGER NOT NULL REFERENCES issues(id),
    buser INTEGER NOT NULL REFERENCES users(id)
    UNIQUE (issue, buser)
);

CREATE TABLE issue_subscriptions (
    user              INTEGER NOT NULL REFERENCES users(id),
    issue             INTEGER NOT NULL REFERENCES issues(id),
    notification_sent BOOLEAN NOT NULL DEFAULT FALSE,
    time_subscribed   TIMESTAMP NOT NULL DEFAULT NOW(),
    time_sent         TIMESTAMP
);

CREATE TABLE reproduction_steps (
    id SERIAL   PRIMARY KEY,
    issue       INTEGER REFERENCES issues(id) NOT NULL,
    step_number INTEGER NOT NULL,
    instruction VARCHAR(200) NOT NULL
);

CREATE TABLE issue_reports (
    id SERIAL      PRIMARY KEY,
    report_number  INTEGER NOT NULL, -- issues/1/reports/{report_number}
    issue          INTEGER NOT NULL REFERENCES issues(id),
    description    TEXT NOT NULL,
    reporter       INTEGER NOT NULL REFERENCES users(id),
    computer_info  TEXT,
    type           VARCHAR(20) NOT NULL,
    status         VARCHAR(20) NOT NULL,
    time_reported  TIMESTAMP,
    confirmed      BOOLEAN NOT NULL DEFAULT TRUE, -- assume that when submits their report they can confirm its behaviour
    upvotes        INTEGER NOT NULL DEFAULT 0,
    CONSTRAINT report_type  CHECK (type in ('Fix', 'PartialFix', 'Report')),
    CONSTRAINT status_value CHECK 
        ((type = 'Report' 
            AND status IN ('Fixed', 'Broken', 'Working', 'PartiallyWorking')) 
        OR ((type = 'Fix' OR type = 'PartialFix') 
            AND status IN ('Works', 'NoWork')))
);

CREATE TABLE issue_report_comments (
    id SERIAL      PRIMARY KEY,
    issue_report   INTEGER NOT NULL REFERENCES issue_reports(id),
    text           VARCHAR(512) NOT NULL,
    time_created   TIMESTAMP NOT NULL DEFAULT NOW(),
    edit_time      TIMESTAMP,
    commenter      INTEGER NOT NULL REFERENCES users(id),
    parent_comment INTEGER REFERENCES issue_report_comments(id),
    upvotes        INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE issue_comments (
    id SERIAL      PRIMARY KEY,
    issue          INTEGER NOT NULL REFERENCES issue(id),
    text           VARCHAR(512) NOT NULL,
    time_created   TIMESTAMP NOT NULL DEFAULT NOW(),
    edit_time      TIMESTAMP,
    commenter      INTEGER NOT NULL REFERENCES users(id),
    parent_comment INTEGER REFERENCES issue_comments(id),
    upvotes        INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE issue_comment_reports (
    id SERIAL              PRIMARY KEY,
    reporter               INTEGER NOT NULL REFERENCES users(id),
    comment                INTEGER NOT NULL REFERENCES issue_comments(id),
    time_reported          INTEGER NOT NULL DEFAULT NOW(),
    reportee_notified_time TIMESTAMP
);

CREATE TABLE issue_report_comment_reports (
    id SERIAL              PRIMARY KEY,
    reporter               INTEGER NOT NULL REFERENCES users(id),
    comment                INTEGER NOT NULL REFERENCES issue_report_comments(id),
    time_reported          INTEGER NOT NULL DEFAULT NOW(),
    reportee_notified_time TIMESTAMP
);

CREATE TABLE program_popularity (
    program INTEGER NOT NULL REFERENCES programs(id) UNIQUE,
    score INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE issue_popularity (
    issue INTEGER NOT NULL REFERENCES issues(id) UNIQUE,
    score INTEGER NOT NULL DEFAULT 0
);
