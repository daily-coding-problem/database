-- Create schema if it doesn't exist
CREATE SCHEMA IF NOT EXISTS leetcode;

-- Drop tables if they exist
DROP TABLE IF EXISTS leetcode.study_plan_problems;
DROP TABLE IF EXISTS leetcode.problems;
DROP TABLE IF EXISTS leetcode.study_plans;
DROP TABLE IF EXISTS users;

-- Create the problems table
CREATE TABLE leetcode.problems (
    id SERIAL PRIMARY KEY,
    question_id INTEGER UNIQUE,
    title VARCHAR(255),
    slug VARCHAR(255),
    content TEXT,
    difficulty VARCHAR(50),
    topics TEXT[],
    companies TEXT[],
    hints TEXT[],
    link TEXT
);

-- Create the study_plans table
CREATE TABLE leetcode.study_plans (
    id SERIAL PRIMARY KEY,
    slug VARCHAR(255) UNIQUE,
    name VARCHAR(255),
    description TEXT
);

-- Create the study_plan_problems table
CREATE TABLE leetcode.study_plan_problems (
    study_plan_id INTEGER REFERENCES leetcode.study_plans(id),
    problem_id INTEGER REFERENCES leetcode.problems(id),
    category_name VARCHAR(255),
    PRIMARY KEY (study_plan_id, problem_id)
);

-- Create the users table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE,
    is_premium BOOLEAN DEFAULT FALSE,
    timezone VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
