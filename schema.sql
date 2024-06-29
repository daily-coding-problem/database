-- Drop tables if they exist
DROP TABLE IF EXISTS study_plan_problems;
DROP TABLE IF EXISTS problems;
DROP TABLE IF EXISTS study_plans;

-- Create the problems table
CREATE TABLE problems (
    id SERIAL PRIMARY KEY,
    question_id INTEGER UNIQUE,
    title VARCHAR(255),
    content TEXT,
    difficulty VARCHAR(50),
    topics TEXT[],  -- Array of strings
    companies TEXT[],  -- Array of strings
    hints TEXT[]  -- Array of strings
);

-- Create the study_plans table
CREATE TABLE study_plans (
    id SERIAL PRIMARY KEY,
    slug VARCHAR(255) UNIQUE,
    name VARCHAR(255),
    description TEXT
);

-- Create the study_plan_problems table
CREATE TABLE study_plan_problems (
    study_plan_id INTEGER REFERENCES study_plans(id),
    problem_id INTEGER REFERENCES problems(id),
    category_name VARCHAR(255),
    PRIMARY KEY (study_plan_id, problem_id)
);
