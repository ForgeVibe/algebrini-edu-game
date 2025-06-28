-- Algebrini Educational Game Database Schema
-- Production-ready setup with optimizations

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements";

-- Create custom types for better data integrity
CREATE TYPE difficulty_level AS ENUM ('easy', 'medium', 'hard', 'expert', 'master');
CREATE TYPE challenge_type AS ENUM ('daily', 'weekly', 'special');
CREATE TYPE user_role AS ENUM ('student', 'teacher', 'admin');

-- Games table
CREATE TABLE games (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    icon VARCHAR(100),
    difficulty_levels INTEGER DEFAULT 5,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Levels table
CREATE TABLE levels (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    game_id VARCHAR(50) NOT NULL REFERENCES games(id) ON DELETE CASCADE,
    level_number INTEGER NOT NULL,
    difficulty difficulty_level NOT NULL,
    requirements JSONB,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(game_id, level_number)
);

-- Challenges table
CREATE TABLE challenges (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    level_id UUID NOT NULL REFERENCES levels(id) ON DELETE CASCADE,
    question TEXT NOT NULL,
    answer TEXT NOT NULL,
    hint TEXT,
    explanation TEXT,
    metadata JSONB,
    difficulty_score INTEGER CHECK (difficulty_score BETWEEN 1 AND 10),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Story chapters table
CREATE TABLE chapters (
    id VARCHAR(50) PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    subtitle VARCHAR(200),
    description TEXT,
    requirements JSONB,
    realm_id VARCHAR(50),
    games JSONB,
    levels JSONB,
    story_cutscene_id VARCHAR(50),
    rewards JSONB,
    order_index INTEGER NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Realms table (story worlds)
CREATE TABLE realms (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    color VARCHAR(20),
    icon VARCHAR(50),
    background VARCHAR(200),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Cutscenes table
CREATE TABLE cutscenes (
    id VARCHAR(50) PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    content JSONB NOT NULL,
    character VARCHAR(50),
    background VARCHAR(50),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Achievements table
CREATE TABLE achievements (
    id VARCHAR(50) PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    icon VARCHAR(50),
    color VARCHAR(20),
    requirements JSONB,
    points INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Challenge types table
CREATE TABLE challenge_types (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    type challenge_type NOT NULL,
    requirements JSONB,
    rewards JSONB,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Avatars table
CREATE TABLE avatars (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    icon VARCHAR(200),
    unlock_requirements JSONB,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Users table (for future authentication)
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255),
    role user_role DEFAULT 'student',
    avatar_id VARCHAR(50) REFERENCES avatars(id),
    preferences JSONB DEFAULT '{}',
    is_active BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User progress table
CREATE TABLE user_progress (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    game_id VARCHAR(50) NOT NULL REFERENCES games(id) ON DELETE CASCADE,
    level_id UUID NOT NULL REFERENCES levels(id) ON DELETE CASCADE,
    score INTEGER DEFAULT 0,
    completed BOOLEAN DEFAULT FALSE,
    time_seconds INTEGER,
    attempts INTEGER DEFAULT 0,
    completed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, level_id)
);

-- User achievements table
CREATE TABLE user_achievements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    achievement_id VARCHAR(50) NOT NULL REFERENCES achievements(id) ON DELETE CASCADE,
    earned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, achievement_id)
);

-- User story progress table
CREATE TABLE user_story_progress (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    current_chapter VARCHAR(50) REFERENCES chapters(id) ON DELETE CASCADE,
    unlocked_chapters JSONB DEFAULT '[]',
    story_progress JSONB DEFAULT '{}',
    character_progress JSONB DEFAULT '{}',
    world_map_unlocks JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id)
);

-- User rewards table
CREATE TABLE user_rewards (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL, -- 'coins', 'stars', 'badge'
    amount INTEGER DEFAULT 0,
    badge_id VARCHAR(50),
    source VARCHAR(100), -- 'level_completion', 'achievement', 'challenge'
    source_id VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Analytics events table for tracking user behavior
CREATE TABLE analytics_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    event_type VARCHAR(100) NOT NULL,
    event_data JSONB,
    session_id VARCHAR(100),
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Performance indexes
CREATE INDEX idx_levels_game_id ON levels(game_id);
CREATE INDEX idx_levels_difficulty ON levels(difficulty);
CREATE INDEX idx_challenges_level_id ON challenges(level_id);
CREATE INDEX idx_challenges_difficulty_score ON challenges(difficulty_score);
CREATE INDEX idx_user_progress_user_id ON user_progress(user_id);
CREATE INDEX idx_user_progress_game_id ON user_progress(game_id);
CREATE INDEX idx_user_progress_completed ON user_progress(completed);
CREATE INDEX idx_user_achievements_user_id ON user_achievements(user_id);
CREATE INDEX idx_chapters_order_index ON chapters(order_index);
CREATE INDEX idx_chapters_realm_id ON chapters(realm_id);
CREATE INDEX idx_analytics_events_user_id ON analytics_events(user_id);
CREATE INDEX idx_analytics_events_event_type ON analytics_events(event_type);
CREATE INDEX idx_analytics_events_created_at ON analytics_events(created_at);

-- Full-text search indexes
CREATE INDEX idx_games_name_fts ON games USING gin(to_tsvector('english', name));
CREATE INDEX idx_chapters_title_fts ON chapters USING gin(to_tsvector('english', title));
CREATE INDEX idx_challenges_question_fts ON challenges USING gin(to_tsvector('english', question));
CREATE INDEX idx_achievements_title_fts ON achievements USING gin(to_tsvector('english', title));

-- JSONB indexes for better query performance
CREATE INDEX idx_levels_requirements_gin ON levels USING gin(requirements);
CREATE INDEX idx_challenges_metadata_gin ON challenges USING gin(metadata);
CREATE INDEX idx_chapters_requirements_gin ON chapters USING gin(requirements);
CREATE INDEX idx_chapters_rewards_gin ON chapters USING gin(rewards);
CREATE INDEX idx_achievements_requirements_gin ON achievements USING gin(requirements);
CREATE INDEX idx_analytics_events_data_gin ON analytics_events USING gin(event_data);

-- Triggers for updated_at timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply triggers to all tables
CREATE TRIGGER update_games_updated_at BEFORE UPDATE ON games FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_levels_updated_at BEFORE UPDATE ON levels FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_challenges_updated_at BEFORE UPDATE ON challenges FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_chapters_updated_at BEFORE UPDATE ON chapters FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_realms_updated_at BEFORE UPDATE ON realms FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_cutscenes_updated_at BEFORE UPDATE ON cutscenes FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_achievements_updated_at BEFORE UPDATE ON achievements FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_challenge_types_updated_at BEFORE UPDATE ON challenge_types FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_avatars_updated_at BEFORE UPDATE ON avatars FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_user_progress_updated_at BEFORE UPDATE ON user_progress FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_user_story_progress_updated_at BEFORE UPDATE ON user_story_progress FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Views for common queries
CREATE VIEW game_statistics AS
SELECT 
    g.id as game_id,
    g.name as game_name,
    COUNT(l.id) as total_levels,
    COUNT(c.id) as total_challenges,
    AVG(c.difficulty_score) as avg_difficulty,
    COUNT(up.id) as total_attempts,
    COUNT(CASE WHEN up.completed = true THEN 1 END) as total_completions,
    AVG(up.score) as avg_score
FROM games g
LEFT JOIN levels l ON g.id = l.game_id
LEFT JOIN challenges c ON l.id = c.level_id
LEFT JOIN user_progress up ON l.id = up.level_id
WHERE g.is_active = true
GROUP BY g.id, g.name;

CREATE VIEW user_progress_summary AS
SELECT 
    u.id as user_id,
    u.username,
    COUNT(up.id) as levels_attempted,
    COUNT(CASE WHEN up.completed = true THEN 1 END) as levels_completed,
    AVG(up.score) as avg_score,
    SUM(up.time_seconds) as total_time_seconds,
    COUNT(ua.id) as achievements_earned
FROM users u
LEFT JOIN user_progress up ON u.id = up.user_id
LEFT JOIN user_achievements ua ON u.id = ua.user_id
GROUP BY u.id, u.username;

-- Functions for common operations
CREATE OR REPLACE FUNCTION get_user_progress(user_uuid UUID)
RETURNS TABLE(
    game_id VARCHAR(50),
    game_name VARCHAR(100),
    levels_completed INTEGER,
    total_levels INTEGER,
    avg_score NUMERIC,
    total_time_seconds INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        g.id,
        g.name,
        COUNT(CASE WHEN up.completed = true THEN 1 END)::INTEGER,
        COUNT(l.id)::INTEGER,
        AVG(up.score),
        SUM(up.time_seconds)::INTEGER
    FROM games g
    LEFT JOIN levels l ON g.id = l.game_id
    LEFT JOIN user_progress up ON l.id = up.level_id AND up.user_id = user_uuid
    WHERE g.is_active = true
    GROUP BY g.id, g.name;
END;
$$ LANGUAGE plpgsql;

-- Grant permissions
GRANT USAGE ON SCHEMA public TO algebrini_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO algebrini_user;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO algebrini_user;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO algebrini_user; 