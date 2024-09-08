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
    solution    TEXT,
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
    is_subscribed BOOLEAN DEFAULT FALSE,
    unsubscribed_at TIMESTAMP,
    is_anonymized BOOLEAN DEFAULT FALSE,
    anonymized_at TIMESTAMP,
    unsubscribe_token VARCHAR(255),
    unsubscribe_token_expires_at TIMESTAMP,
    is_processing BOOLEAN DEFAULT FALSE, -- For processing user data in a distributed system
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create the user_subscriptions table to log subscription events
CREATE TABLE user_subscriptions
(
    id              SERIAL PRIMARY KEY,
    user_id         INTEGER REFERENCES users (id) ON DELETE CASCADE, -- Cascade on delete
    study_plan_id   INTEGER REFERENCES leetcode.study_plans (id),
    subscribed_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (user_id, study_plan_id)
);

-- Create the user_study_plans table
CREATE TABLE user_study_plans
(
    user_id      INTEGER REFERENCES users (id) ON DELETE CASCADE, -- Cascade on delete
    study_plan_id INTEGER REFERENCES leetcode.study_plans (id),
    started_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    finished_at  TIMESTAMP,
    PRIMARY KEY (user_id, study_plan_id)
);

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

-- Create the user_seen_problems table
CREATE TABLE user_seen_problems (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id BIGINT NOT NULL,
    problem_id BIGINT NOT NULL,
    problem_sent_at TIMESTAMP, -- Timestamp for when the problem was sent
    solution_sent_at TIMESTAMP, -- Timestamp for when the solution was sent (for premium users)
    status VARCHAR(20) NOT NULL, -- Tracks if only problem or problem + solution was sent ('PROBLEM_SENT', 'SOLUTION_SENT')

    CONSTRAINT fk_user_seen_problems_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_user_seen_problems_problem FOREIGN KEY (problem_id) REFERENCES leetcode.problems(id) ON DELETE CASCADE
);

-- Create the CRON Job table
CREATE TABLE cron_jobs
(
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(255),
    description TEXT,
    schedule    VARCHAR(255),
    enabled     BOOLEAN DEFAULT TRUE,
    last_run_at TIMESTAMP,
    next_run_at TIMESTAMP
);

INSERT INTO cron_jobs (name, description, schedule, last_run_at, next_run_at)
VALUES ('Send Daily Coding Problems', 'Send daily coding problem to all subscribed users', '0 0 0 * * ?', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO cron_jobs (name, description, schedule, last_run_at, next_run_at)
VALUES ('Handle Expired Tokens', 'Handle expired unsubscribe tokens', '0 0 0 * * ?', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO cron_jobs (name, description, schedule, last_run_at, next_run_at)
VALUES ('Anonymize User Data Clean Up', 'Clean up anonymized user data after a given retention period', '0 0 0 * * ?', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Indexes for faster lookups on frequently queried columns
CREATE INDEX idx_problems_question_id ON leetcode.problems (question_id);
CREATE INDEX idx_study_plans_slug ON leetcode.study_plans (slug);
CREATE INDEX idx_study_plan_problems_study_plan_id ON leetcode.study_plan_problems (study_plan_id);
CREATE INDEX idx_study_plan_problems_problem_id ON leetcode.study_plan_problems (problem_id);
CREATE INDEX idx_users_email ON users (email);
CREATE INDEX idx_user_subscriptions_user_id ON user_subscriptions (user_id);
CREATE INDEX idx_user_subscriptions_study_plan_id ON user_subscriptions (study_plan_id);
CREATE INDEX idx_user_study_plans_user_id ON user_study_plans (user_id);
CREATE INDEX idx_user_study_plans_study_plan_id ON user_study_plans (study_plan_id);
CREATE INDEX idx_user_study_plan_problems_user_id ON user_study_plan_problems (user_id);
CREATE INDEX idx_user_study_plan_problems_study_plan_id ON user_study_plan_problems (study_plan_id);
CREATE INDEX idx_user_study_plan_problems_problem_id ON user_study_plan_problems (problem_id);
CREATE INDEX idx_user_seen_problems_user_id ON user_seen_problems (user_id);
CREATE INDEX idx_user_seen_problems_problem_id ON user_seen_problems (problem_id);
CREATE INDEX idx_cron_jobs_name ON cron_jobs (name);

-- Enable Row Level Security on all tables
ALTER TABLE leetcode.problems ENABLE ROW LEVEL SECURITY;
ALTER TABLE leetcode.study_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE leetcode.study_plan_problems ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_study_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_study_plan_problems ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_seen_problems ENABLE ROW LEVEL SECURITY;
ALTER TABLE cron_jobs ENABLE ROW LEVEL SECURITY;

-- Add policies for Row Level Security

-- Add policies for Select
CREATE POLICY select_problems ON leetcode.problems FOR SELECT USING (TRUE);
CREATE POLICY select_study_plans ON leetcode.study_plans FOR SELECT USING (TRUE);
CREATE POLICY select_study_plan_problems ON leetcode.study_plan_problems FOR SELECT USING (TRUE);
CREATE POLICY select_users ON users FOR SELECT USING (TRUE);
CREATE POLICY select_user_subscriptions ON user_subscriptions FOR SELECT USING (TRUE);
CREATE POLICY select_user_study_plans ON user_study_plans FOR SELECT USING (TRUE);
CREATE POLICY select_user_study_plan_problems ON user_study_plan_problems FOR SELECT USING (TRUE);
CREATE POLICY select_user_seen_problems ON user_seen_problems FOR SELECT USING (TRUE);
CREATE POLICY select_cron_jobs ON cron_jobs FOR SELECT USING (TRUE);
CREATE POLICY select_all_problem_companies ON public.problem_companies FOR SELECT USING (true);
CREATE POLICY select_all_problem_topics ON public.problem_topics FOR SELECT USING (true);
CREATE POLICY select_all_problem_hints ON public.problem_hints FOR SELECT USING (true);

-- Add policies for Insert
CREATE POLICY insert_problems ON leetcode.problems FOR INSERT WITH CHECK (TRUE);
CREATE POLICY insert_study_plans ON leetcode.study_plans FOR INSERT WITH CHECK (TRUE);
CREATE POLICY insert_study_plan_problems ON leetcode.study_plan_problems FOR INSERT WITH CHECK (TRUE);
CREATE POLICY insert_users ON users FOR INSERT WITH CHECK (TRUE);
CREATE POLICY insert_user_subscriptions ON user_subscriptions FOR INSERT WITH CHECK (TRUE);
CREATE POLICY insert_user_study_plans ON user_study_plans FOR INSERT WITH CHECK (TRUE);
CREATE POLICY insert_user_study_plan_problems ON user_study_plan_problems FOR INSERT WITH CHECK (TRUE);
CREATE POLICY insert_user_seen_problems ON user_seen_problems FOR INSERT WITH CHECK (TRUE);
CREATE POLICY insert_cron_jobs ON cron_jobs FOR INSERT WITH CHECK (TRUE);
CREATE POLICY insert_all_problem_companies ON public.problem_companies FOR INSERT WITH CHECK (true);
CREATE POLICY insert_all_problem_topics ON public.problem_topics FOR INSERT WITH CHECK (true);
CREATE POLICY insert_all_problem_hints ON public.problem_hints FOR INSERT WITH CHECK (true);
