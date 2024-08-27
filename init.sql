-- Create schema if it doesn't exist
CREATE SCHEMA IF NOT EXISTS leetcode;

-- Drop tables if they exist
DROP TABLE IF EXISTS leetcode.study_plan_problems;
DROP TABLE IF EXISTS leetcode.problems;
DROP TABLE IF EXISTS leetcode.study_plans;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS user_subscriptions;
DROP TABLE IF EXISTS user_study_plans;
DROP TABLE IF EXISTS user_study_plan_problems;

-- Create the problems table
CREATE TABLE leetcode.problems
(
    id          SERIAL PRIMARY KEY,
    question_id INTEGER UNIQUE,
    title       VARCHAR(255),
    slug        VARCHAR(255),
    content     TEXT,
    difficulty  VARCHAR(50),
    topics      TEXT[],
    companies   TEXT[],
    hints       TEXT[],
    link        TEXT
);

-- Create the study_plans table
CREATE TABLE leetcode.study_plans
(
    id          SERIAL PRIMARY KEY,
    slug        VARCHAR(255) UNIQUE,
    name        VARCHAR(255),
    expected_number_of_problems INTEGER,
    description TEXT
);

-- Create the study_plan_problems table
CREATE TABLE leetcode.study_plan_problems
(
    study_plan_id INTEGER REFERENCES leetcode.study_plans (id),
    problem_id    INTEGER REFERENCES leetcode.problems (id),
    category_name VARCHAR(255),
    PRIMARY KEY (study_plan_id, problem_id)
);

-- Create the users table
CREATE TABLE users
(
    id         SERIAL PRIMARY KEY,
    email      VARCHAR(255) UNIQUE,
    is_premium BOOLEAN   DEFAULT FALSE,
    timezone   VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Create the user_subscriptions table to log subscription events
CREATE TABLE user_subscriptions
(
    id              SERIAL PRIMARY KEY,
    user_id         INTEGER REFERENCES users (id) ON DELETE CASCADE, -- Cascade on delete
    study_plan_id   INTEGER REFERENCES leetcode.study_plans (id),
    subscribed_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (user_id, study_plan_id)
);

ALTER TABLE user_subscriptions ENABLE ROW LEVEL SECURITY;

-- Create the user_study_plans table
CREATE TABLE user_study_plans
(
    user_id      INTEGER REFERENCES users (id) ON DELETE CASCADE, -- Cascade on delete
    study_plan_id INTEGER REFERENCES leetcode.study_plans (id),
    started_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    finished_at  TIMESTAMP,
    PRIMARY KEY (user_id, study_plan_id)
);

ALTER TABLE user_study_plans ENABLE ROW LEVEL SECURITY;

-- Create the user_study_plan_problems table
CREATE TABLE user_study_plan_problems
(
    user_id      INTEGER REFERENCES users (id) ON DELETE CASCADE, -- Cascade on delete
    study_plan_id INTEGER REFERENCES leetcode.study_plans (id),
    problem_id    INTEGER REFERENCES leetcode.problems (id),
    started_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    finished_at  TIMESTAMP,
    PRIMARY KEY (user_id, study_plan_id, problem_id)
);

ALTER TABLE user_study_plan_problems ENABLE ROW LEVEL SECURITY;
