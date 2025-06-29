--
-- PostgreSQL database dump
--

-- Dumped from database version 15.13
-- Dumped by pg_dump version 15.13

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA public;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_stat_statements IS 'track planning and execution statistics of all SQL statements executed';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: challenge_type; Type: TYPE; Schema: public; Owner: algebrini_user
--

CREATE TYPE public.challenge_type AS ENUM (
    'daily',
    'weekly',
    'special'
);


ALTER TYPE public.challenge_type OWNER TO algebrini_user;

--
-- Name: difficulty_level; Type: TYPE; Schema: public; Owner: algebrini_user
--

CREATE TYPE public.difficulty_level AS ENUM (
    'easy',
    'medium',
    'hard',
    'expert',
    'master'
);


ALTER TYPE public.difficulty_level OWNER TO algebrini_user;

--
-- Name: user_role; Type: TYPE; Schema: public; Owner: algebrini_user
--

CREATE TYPE public.user_role AS ENUM (
    'student',
    'teacher',
    'admin'
);


ALTER TYPE public.user_role OWNER TO algebrini_user;

--
-- Name: get_user_progress(uuid); Type: FUNCTION; Schema: public; Owner: algebrini_user
--

CREATE FUNCTION public.get_user_progress(user_uuid uuid) RETURNS TABLE(game_id character varying, game_name character varying, levels_completed integer, total_levels integer, avg_score numeric, total_time_seconds integer)
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.get_user_progress(user_uuid uuid) OWNER TO algebrini_user;

--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: algebrini_user
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_updated_at_column() OWNER TO algebrini_user;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: achievements; Type: TABLE; Schema: public; Owner: algebrini_user
--

CREATE TABLE public.achievements (
    id character varying(50) NOT NULL,
    title character varying(100) NOT NULL,
    description text,
    icon character varying(50),
    color character varying(20),
    requirements jsonb,
    points integer DEFAULT 0,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.achievements OWNER TO algebrini_user;

--
-- Name: analytics_events; Type: TABLE; Schema: public; Owner: algebrini_user
--

CREATE TABLE public.analytics_events (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid,
    event_type character varying(100) NOT NULL,
    event_data jsonb,
    session_id character varying(100),
    ip_address inet,
    user_agent text,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.analytics_events OWNER TO algebrini_user;

--
-- Name: avatars; Type: TABLE; Schema: public; Owner: algebrini_user
--

CREATE TABLE public.avatars (
    id character varying(50) NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    icon character varying(200),
    unlock_requirements jsonb,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.avatars OWNER TO algebrini_user;

--
-- Name: challenge_types; Type: TABLE; Schema: public; Owner: algebrini_user
--

CREATE TABLE public.challenge_types (
    id character varying(50) NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    type public.challenge_type NOT NULL,
    requirements jsonb,
    rewards jsonb,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.challenge_types OWNER TO algebrini_user;

--
-- Name: challenges; Type: TABLE; Schema: public; Owner: algebrini_user
--

CREATE TABLE public.challenges (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    level_id uuid NOT NULL,
    question text NOT NULL,
    answer text NOT NULL,
    hint text,
    explanation text,
    metadata jsonb,
    difficulty_score integer,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT challenges_difficulty_score_check CHECK (((difficulty_score >= 1) AND (difficulty_score <= 10)))
);


ALTER TABLE public.challenges OWNER TO algebrini_user;

--
-- Name: chapters; Type: TABLE; Schema: public; Owner: algebrini_user
--

CREATE TABLE public.chapters (
    id character varying(50) NOT NULL,
    title character varying(200) NOT NULL,
    subtitle character varying(200),
    description text,
    requirements jsonb,
    realm_id character varying(50),
    games jsonb,
    levels jsonb,
    story_cutscene_id character varying(50),
    rewards jsonb,
    order_index integer NOT NULL,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.chapters OWNER TO algebrini_user;

--
-- Name: cutscenes; Type: TABLE; Schema: public; Owner: algebrini_user
--

CREATE TABLE public.cutscenes (
    id character varying(50) NOT NULL,
    title character varying(200) NOT NULL,
    content jsonb NOT NULL,
    "character" character varying(50),
    background character varying(50),
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.cutscenes OWNER TO algebrini_user;

--
-- Name: games; Type: TABLE; Schema: public; Owner: algebrini_user
--

CREATE TABLE public.games (
    id character varying(50) NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    icon character varying(100),
    difficulty_levels integer DEFAULT 5,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.games OWNER TO algebrini_user;

--
-- Name: levels; Type: TABLE; Schema: public; Owner: algebrini_user
--

CREATE TABLE public.levels (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    game_id character varying(50) NOT NULL,
    level_number integer NOT NULL,
    difficulty public.difficulty_level NOT NULL,
    requirements jsonb,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.levels OWNER TO algebrini_user;

--
-- Name: user_progress; Type: TABLE; Schema: public; Owner: algebrini_user
--

CREATE TABLE public.user_progress (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    game_id character varying(50) NOT NULL,
    level_id uuid NOT NULL,
    score integer DEFAULT 0,
    completed boolean DEFAULT false,
    time_seconds integer,
    attempts integer DEFAULT 0,
    completed_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.user_progress OWNER TO algebrini_user;

--
-- Name: game_statistics; Type: VIEW; Schema: public; Owner: algebrini_user
--

CREATE VIEW public.game_statistics AS
 SELECT g.id AS game_id,
    g.name AS game_name,
    count(l.id) AS total_levels,
    count(c.id) AS total_challenges,
    avg(c.difficulty_score) AS avg_difficulty,
    count(up.id) AS total_attempts,
    count(
        CASE
            WHEN (up.completed = true) THEN 1
            ELSE NULL::integer
        END) AS total_completions,
    avg(up.score) AS avg_score
   FROM (((public.games g
     LEFT JOIN public.levels l ON (((g.id)::text = (l.game_id)::text)))
     LEFT JOIN public.challenges c ON ((l.id = c.level_id)))
     LEFT JOIN public.user_progress up ON ((l.id = up.level_id)))
  WHERE (g.is_active = true)
  GROUP BY g.id, g.name;


ALTER TABLE public.game_statistics OWNER TO algebrini_user;

--
-- Name: realms; Type: TABLE; Schema: public; Owner: algebrini_user
--

CREATE TABLE public.realms (
    id character varying(50) NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    color character varying(20),
    icon character varying(50),
    background character varying(200),
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.realms OWNER TO algebrini_user;

--
-- Name: user_achievements; Type: TABLE; Schema: public; Owner: algebrini_user
--

CREATE TABLE public.user_achievements (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    achievement_id character varying(50) NOT NULL,
    earned_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.user_achievements OWNER TO algebrini_user;

--
-- Name: users; Type: TABLE; Schema: public; Owner: algebrini_user
--

CREATE TABLE public.users (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    username character varying(50) NOT NULL,
    email character varying(255) NOT NULL,
    password_hash character varying(255),
    role public.user_role DEFAULT 'student'::public.user_role,
    avatar_id character varying(50),
    preferences jsonb DEFAULT '{}'::jsonb,
    is_active boolean DEFAULT true,
    last_login timestamp with time zone,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.users OWNER TO algebrini_user;

--
-- Name: user_progress_summary; Type: VIEW; Schema: public; Owner: algebrini_user
--

CREATE VIEW public.user_progress_summary AS
 SELECT u.id AS user_id,
    u.username,
    count(up.id) AS levels_attempted,
    count(
        CASE
            WHEN (up.completed = true) THEN 1
            ELSE NULL::integer
        END) AS levels_completed,
    avg(up.score) AS avg_score,
    sum(up.time_seconds) AS total_time_seconds,
    count(ua.id) AS achievements_earned
   FROM ((public.users u
     LEFT JOIN public.user_progress up ON ((u.id = up.user_id)))
     LEFT JOIN public.user_achievements ua ON ((u.id = ua.user_id)))
  GROUP BY u.id, u.username;


ALTER TABLE public.user_progress_summary OWNER TO algebrini_user;

--
-- Name: user_rewards; Type: TABLE; Schema: public; Owner: algebrini_user
--

CREATE TABLE public.user_rewards (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    type character varying(50) NOT NULL,
    amount integer DEFAULT 0,
    badge_id character varying(50),
    source character varying(100),
    source_id character varying(100),
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.user_rewards OWNER TO algebrini_user;

--
-- Name: user_story_progress; Type: TABLE; Schema: public; Owner: algebrini_user
--

CREATE TABLE public.user_story_progress (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    current_chapter character varying(50),
    unlocked_chapters jsonb DEFAULT '[]'::jsonb,
    story_progress jsonb DEFAULT '{}'::jsonb,
    character_progress jsonb DEFAULT '{}'::jsonb,
    world_map_unlocks jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.user_story_progress OWNER TO algebrini_user;

--
-- Data for Name: achievements; Type: TABLE DATA; Schema: public; Owner: algebrini_user
--

COPY public.achievements (id, title, description, icon, color, requirements, points, is_active, created_at, updated_at) FROM stdin;
first_level	First Steps	Complete your first level	star	green	{"type": "level_completion", "count": 1}	10	t	2025-06-28 21:34:38.327628+00	2025-06-28 21:34:38.327628+00
perfect_score	Perfect Score	Get a perfect score on any level	trophy	gold	{"type": "perfect_score", "count": 1}	50	t	2025-06-28 21:34:38.327628+00	2025-06-28 21:34:38.327628+00
level_master	Level Master	Complete all levels in a game	crown	purple	{"game": "any", "type": "all_levels_completion"}	100	t	2025-06-28 21:34:38.327628+00	2025-06-28 21:34:38.327628+00
streak_master	Streak Master	Get 10 correct answers in a row	fire	orange	{"type": "streak", "count": 10}	75	t	2025-06-28 21:34:38.327628+00	2025-06-28 21:34:38.327628+00
speed_demon	Speed Demon	Complete a level in under 30 seconds	bolt	yellow	{"type": "speed", "time_seconds": 30}	25	t	2025-06-28 21:34:38.327628+00	2025-06-28 21:34:38.327628+00
\.


--
-- Data for Name: analytics_events; Type: TABLE DATA; Schema: public; Owner: algebrini_user
--

COPY public.analytics_events (id, user_id, event_type, event_data, session_id, ip_address, user_agent, created_at) FROM stdin;
\.


--
-- Data for Name: avatars; Type: TABLE DATA; Schema: public; Owner: algebrini_user
--

COPY public.avatars (id, name, description, icon, unlock_requirements, is_active, created_at, updated_at) FROM stdin;
wizard	Math Wizard	A wise wizard who understands the secrets of numbers	assets/avatars/wizard.png	{"type": "none"}	t	2025-06-28 21:34:38.331374+00	2025-06-28 21:34:38.331374+00
knight	Number Knight	A brave knight who defends mathematical truth	assets/avatars/knight.png	{"type": "achievement", "achievement": "first_level"}	t	2025-06-28 21:34:38.331374+00	2025-06-28 21:34:38.331374+00
scientist	Pattern Scientist	A curious scientist who studies mathematical patterns	assets/avatars/scientist.png	{"type": "achievement", "achievement": "level_master"}	t	2025-06-28 21:34:38.331374+00	2025-06-28 21:34:38.331374+00
dragon	Equation Dragon	A powerful dragon who breathes mathematical fire	assets/avatars/dragon.png	{"type": "achievement", "achievement": "perfect_score"}	t	2025-06-28 21:34:38.331374+00	2025-06-28 21:34:38.331374+00
\.


--
-- Data for Name: challenge_types; Type: TABLE DATA; Schema: public; Owner: algebrini_user
--

COPY public.challenge_types (id, name, description, type, requirements, rewards, is_active, created_at, updated_at) FROM stdin;
daily_sequence	Daily Sequence	Complete 3 recursive sequence problems	daily	{"game": "recursive-sequences", "count": 3}	{"coins": 50, "stars": 5}	t	2025-06-28 21:34:38.329692+00	2025-06-28 21:34:38.329692+00
daily_equation	Daily Equation	Solve 2 simple equations	daily	{"game": "simple-equations", "count": 2}	{"coins": 50, "stars": 5}	t	2025-06-28 21:34:38.329692+00	2025-06-28 21:34:38.329692+00
daily_factorization	Daily Factorization	Factor 4 numbers correctly	daily	{"game": "factorization-fun", "count": 4}	{"coins": 50, "stars": 5}	t	2025-06-28 21:34:38.329692+00	2025-06-28 21:34:38.329692+00
weekly_master	Weekly Master	Complete all daily challenges in a week	weekly	{"daily_challenges": 7}	{"badge": "weekly_master", "coins": 200, "stars": 20}	t	2025-06-28 21:34:38.329692+00	2025-06-28 21:34:38.329692+00
weekly_perfect	Weekly Perfect	Get perfect scores on 5 levels	weekly	{"perfect_scores": 5}	{"badge": "perfectionist", "coins": 300, "stars": 30}	t	2025-06-28 21:34:38.329692+00	2025-06-28 21:34:38.329692+00
\.


--
-- Data for Name: challenges; Type: TABLE DATA; Schema: public; Owner: algebrini_user
--

COPY public.challenges (id, level_id, question, answer, hint, explanation, metadata, difficulty_score, is_active, created_at, updated_at) FROM stdin;
d13ed760-de8d-42aa-b417-ac375a56e6ac	62dce395-147f-4fda-8192-36f4c0231ac4	What comes next in the sequence: 2, 4, 6, 8, ?	10	Look at the difference between consecutive numbers.	This is an arithmetic sequence where each number increases by 2.	{"type": "arithmetic", "sequence": [2, 4, 6, 8, 10], "difference": 2}	2	t	2025-06-28 21:34:38.339019+00	2025-06-28 21:34:38.339019+00
ab3c8138-cdbd-4b43-9012-f77c4fd95ec4	62dce395-147f-4fda-8192-36f4c0231ac4	What comes next in the sequence: 1, 3, 5, 7, ?	9	Each number is 2 more than the previous one.	This is an arithmetic sequence with a common difference of 2.	{"type": "arithmetic", "sequence": [1, 3, 5, 7, 9], "difference": 2}	2	t	2025-06-28 21:34:38.343807+00	2025-06-28 21:34:38.343807+00
4d69194c-0877-4aeb-bfe3-344205859286	62dce395-147f-4fda-8192-36f4c0231ac4	What comes next in the sequence: 3, 6, 9, 12, ?	15	How much do you add each time?	This sequence increases by 3 each time.	{"type": "arithmetic", "sequence": [3, 6, 9, 12, 15], "difference": 3}	2	t	2025-06-28 21:34:38.345157+00	2025-06-28 21:34:38.345157+00
ab362461-ef0e-4c7e-af38-6f26d9191e2d	858f06b3-f6bf-4591-a316-a704ba2d5fa9	Solve for x: x + 3 = 7	4	What number plus 3 equals 7?	Subtract 3 from both sides: x = 7 - 3 = 4	{"type": "addition", "equation": "x + 3 = 7", "solution": 4}	2	t	2025-06-28 21:34:38.346486+00	2025-06-28 21:34:38.346486+00
cc75aa25-45b2-4abd-a5ec-8246d1641b0a	858f06b3-f6bf-4591-a316-a704ba2d5fa9	Solve for x: x - 2 = 5	7	What number minus 2 equals 5?	Add 2 to both sides: x = 5 + 2 = 7	{"type": "subtraction", "equation": "x - 2 = 5", "solution": 7}	2	t	2025-06-28 21:34:38.347509+00	2025-06-28 21:34:38.347509+00
55a0af95-5ac3-4c59-950f-c65619bcb41f	858f06b3-f6bf-4591-a316-a704ba2d5fa9	Solve for x: 2x = 8	4	What number times 2 equals 8?	Divide both sides by 2: x = 8 ÷ 2 = 4	{"type": "multiplication", "equation": "2x = 8", "solution": 4}	3	t	2025-06-28 21:34:38.348646+00	2025-06-28 21:34:38.348646+00
5ea9e64a-05d4-477d-80d2-d57980c3ee10	2e4ec551-2858-4cea-8943-534497720eac	What are all the factors of 6?	1,2,3,6	A factor is a number that divides evenly into another number.	6 can be divided by 1, 2, 3, and 6, so these are its factors.	{"type": "Small Composite", "number": 6, "factors": [1, 2, 3, 6]}	2	t	2025-06-28 21:34:38.349723+00	2025-06-28 21:34:38.349723+00
675ad922-334c-4604-b924-49b83cd2aa34	2e4ec551-2858-4cea-8943-534497720eac	What are all the factors of 8?	1,2,4,8	Think about what numbers divide 8 evenly.	8 can be divided by 1, 2, 4, and 8, so these are its factors.	{"type": "Power of 2", "number": 8, "factors": [1, 2, 4, 8]}	2	t	2025-06-28 21:34:38.350822+00	2025-06-28 21:34:38.350822+00
1b2a250f-d041-4a7f-9e43-2a3de6399411	2e4ec551-2858-4cea-8943-534497720eac	What are all the factors of 10?	1,2,5,10	What numbers can you multiply to get 10?	10 can be divided by 1, 2, 5, and 10, so these are its factors.	{"type": "Small Composite", "number": 10, "factors": [1, 2, 5, 10]}	2	t	2025-06-28 21:34:38.351785+00	2025-06-28 21:34:38.351785+00
\.


--
-- Data for Name: chapters; Type: TABLE DATA; Schema: public; Owner: algebrini_user
--

COPY public.chapters (id, title, subtitle, description, requirements, realm_id, games, levels, story_cutscene_id, rewards, order_index, is_active, created_at, updated_at) FROM stdin;
chapter_1	The Awakening	Discovering the Magic of Numbers	Welcome to Algebrini! Your journey begins in the mystical realm where numbers come alive.	{"type": "none"}	crystal_forest	["recursive-sequences"]	[1, 2]	chapter_1_intro	{"badge": "first_steps", "stars": 10}	1	t	2025-06-28 21:34:38.32475+00	2025-06-28 21:34:38.32475+00
chapter_2	The Pattern Seekers	Unlocking the Secrets of Sequences	Deep in the Crystal Forest, ancient patterns reveal themselves to those who look carefully.	{"type": "chapter_completion", "chapter": "chapter_1"}	crystal_forest	["recursive-sequences"]	[3, 4, 5]	chapter_2_intro	{"badge": "pattern_master", "stars": 15}	2	t	2025-06-28 21:34:38.32475+00	2025-06-28 21:34:38.32475+00
chapter_3	The Equation Valley	Solving the Mysteries of Variables	Beyond the forest lies the Equation Valley, where unknown values hide in plain sight.	{"game": "recursive-sequences", "type": "game_completion", "levels": 3}	equation_valley	["simple-equations"]	[1, 2, 3]	chapter_3_intro	{"badge": "equation_solver", "stars": 20}	3	t	2025-06-28 21:34:38.32475+00	2025-06-28 21:34:38.32475+00
chapter_4	The Factorization Caves	Breaking Down the Building Blocks	In the depths of the Factorization Caves, numbers break apart to reveal their secrets.	{"game": "simple-equations", "type": "game_completion", "levels": 2}	factorization_caves	["factorization-fun"]	[1, 2, 3]	chapter_4_intro	{"badge": "factor_finder", "stars": 25}	4	t	2025-06-28 21:34:38.32475+00	2025-06-28 21:34:38.32475+00
chapter_5	The Grand Convergence	Mastering All Mathematical Arts	At the heart of Algebrini, all mathematical paths converge in the ultimate challenge.	{"type": "all_games_completion", "games": ["recursive-sequences", "simple-equations", "factorization-fun"]}	convergence_tower	["recursive-sequences", "simple-equations", "factorization-fun"]	[4, 5]	chapter_5_intro	{"badge": "algebrini_master", "stars": 50}	5	t	2025-06-28 21:34:38.32475+00	2025-06-28 21:34:38.32475+00
\.


--
-- Data for Name: cutscenes; Type: TABLE DATA; Schema: public; Owner: algebrini_user
--

COPY public.cutscenes (id, title, content, "character", background, is_active, created_at, updated_at) FROM stdin;
chapter_1_intro	Welcome to Algebrini	["Welcome, young mathematician! You have been chosen to explore the magical world of Algebrini.", "Here, numbers are not just symbols on a page - they are living, breathing entities with stories to tell.", "Your journey begins in the Crystal Forest, where patterns emerge from the very air around you.", "Are you ready to discover the secrets that lie within?"]	narrator	crystal_forest	t	2025-06-28 21:34:38.322997+00	2025-06-28 21:34:38.322997+00
chapter_2_intro	The Pattern Seekers	["You have proven yourself worthy of the Crystal Forest's secrets!", "But there is more to discover. The ancient patterns grow more complex, revealing deeper mathematical truths.", "Each sequence you solve unlocks a piece of the forest's ancient wisdom.", "Continue your quest, pattern seeker!"]	narrator	crystal_forest	t	2025-06-28 21:34:38.322997+00	2025-06-28 21:34:38.322997+00
chapter_3_intro	Beyond the Forest	["Your mastery of patterns has opened the path to the Equation Valley!", "Here, unknown values hide in plain sight, waiting to be discovered.", "Variables are not just letters - they are the keys to unlocking mathematical mysteries.", "Prepare to solve equations that have puzzled scholars for generations!"]	narrator	equation_valley	t	2025-06-28 21:34:38.322997+00	2025-06-28 21:34:38.322997+00
chapter_4_intro	The Factorization Caves	["Your journey leads you to the Factorization Caves, where numbers reveal their true nature.", "Every number is made up of smaller building blocks - prime factors.", "By breaking numbers apart, you will understand how they are constructed.", "Enter the caves and discover the building blocks of mathematics!"]	narrator	factorization_caves	t	2025-06-28 21:34:38.322997+00	2025-06-28 21:34:38.322997+00
chapter_5_intro	The Grand Convergence	["You have mastered the individual arts of mathematics!", "Now, at the Convergence Tower, all your knowledge will be tested.", "Patterns, equations, and factorization - they all work together.", "This is your final challenge. Are you ready to become a true master of Algebrini?"]	narrator	convergence_tower	t	2025-06-28 21:34:38.322997+00	2025-06-28 21:34:38.322997+00
\.


--
-- Data for Name: games; Type: TABLE DATA; Schema: public; Owner: algebrini_user
--

COPY public.games (id, name, description, icon, difficulty_levels, is_active, created_at, updated_at) FROM stdin;
recursive-sequences	Recursive Sequences	Discover patterns in number sequences and predict the next terms.	sequence	5	t	2025-06-28 21:34:38.317141+00	2025-06-28 21:34:38.317141+00
simple-equations	Simple Equations	Solve equations with one variable to unlock mathematical mysteries.	equation	5	t	2025-06-28 21:34:38.317141+00	2025-06-28 21:34:38.317141+00
factorization-fun	Factorization Fun	Break down numbers into their prime factors and understand number structure.	factorization	5	t	2025-06-28 21:34:38.317141+00	2025-06-28 21:34:38.317141+00
\.


--
-- Data for Name: levels; Type: TABLE DATA; Schema: public; Owner: algebrini_user
--

COPY public.levels (id, game_id, level_number, difficulty, requirements, is_active, created_at, updated_at) FROM stdin;
62dce395-147f-4fda-8192-36f4c0231ac4	recursive-sequences	1	easy	{"type": "always"}	t	2025-06-28 21:34:38.332967+00	2025-06-28 21:34:38.332967+00
f9ff5e77-78b7-41b3-8fbd-f26712a3011d	recursive-sequences	2	easy	{"game": "recursive-sequences", "type": "score", "level": 1, "requirement": 3}	t	2025-06-28 21:34:38.332967+00	2025-06-28 21:34:38.332967+00
32e8c4b1-0cd9-4070-96f1-7c0028d6cccf	recursive-sequences	3	medium	{"game": "recursive-sequences", "type": "score", "level": 2, "requirement": 4}	t	2025-06-28 21:34:38.332967+00	2025-06-28 21:34:38.332967+00
60dadded-c3a0-4d10-8c6e-95e62c0e7b53	recursive-sequences	4	hard	{"game": "recursive-sequences", "type": "completion", "requirement": 2}	t	2025-06-28 21:34:38.332967+00	2025-06-28 21:34:38.332967+00
92ad79b8-3885-41f4-b453-5ef15844d481	recursive-sequences	5	expert	{"game": "recursive-sequences", "type": "streak", "requirement": 5}	t	2025-06-28 21:34:38.332967+00	2025-06-28 21:34:38.332967+00
858f06b3-f6bf-4591-a316-a704ba2d5fa9	simple-equations	1	easy	{"type": "always"}	t	2025-06-28 21:34:38.336874+00	2025-06-28 21:34:38.336874+00
8eb179e5-3214-40e6-b3bb-af767a01e971	simple-equations	2	easy	{"game": "simple-equations", "type": "score", "level": 1, "requirement": 3}	t	2025-06-28 21:34:38.336874+00	2025-06-28 21:34:38.336874+00
6d3457bf-21e9-4f98-bb21-5c2bc0ecaeaf	simple-equations	3	medium	{"game": "simple-equations", "type": "score", "level": 2, "requirement": 4}	t	2025-06-28 21:34:38.336874+00	2025-06-28 21:34:38.336874+00
73619f45-7567-4832-ac95-0cb759defae2	simple-equations	4	hard	{"game": "simple-equations", "type": "completion", "requirement": 2}	t	2025-06-28 21:34:38.336874+00	2025-06-28 21:34:38.336874+00
e45d9c4c-2edd-4868-ab2a-e2a70b47442a	simple-equations	5	expert	{"game": "simple-equations", "type": "streak", "requirement": 5}	t	2025-06-28 21:34:38.336874+00	2025-06-28 21:34:38.336874+00
2e4ec551-2858-4cea-8943-534497720eac	factorization-fun	1	easy	{"type": "always"}	t	2025-06-28 21:34:38.337975+00	2025-06-28 21:34:38.337975+00
b5e26c7e-4b9d-4157-a8a6-d1def0e1e24e	factorization-fun	2	easy	{"game": "factorization-fun", "type": "score", "level": 1, "requirement": 3}	t	2025-06-28 21:34:38.337975+00	2025-06-28 21:34:38.337975+00
ec59b1d7-0cbf-4594-8f97-d095b7401dc2	factorization-fun	3	medium	{"game": "factorization-fun", "type": "score", "level": 2, "requirement": 4}	t	2025-06-28 21:34:38.337975+00	2025-06-28 21:34:38.337975+00
192636f8-320b-44d7-b931-4d63317e486e	factorization-fun	4	hard	{"game": "factorization-fun", "type": "completion", "requirement": 2}	t	2025-06-28 21:34:38.337975+00	2025-06-28 21:34:38.337975+00
f21d63ce-d754-43fb-ac15-7c3915617cb2	factorization-fun	5	expert	{"game": "factorization-fun", "type": "streak", "requirement": 5}	t	2025-06-28 21:34:38.337975+00	2025-06-28 21:34:38.337975+00
\.


--
-- Data for Name: realms; Type: TABLE DATA; Schema: public; Owner: algebrini_user
--

COPY public.realms (id, name, description, color, icon, background, is_active, created_at, updated_at) FROM stdin;
crystal_forest	Crystal Forest	A mystical forest where crystal formations follow mathematical patterns	green	forest	assets/backgrounds/crystal_forest.png	t	2025-06-28 21:34:38.32134+00	2025-06-28 21:34:38.32134+00
equation_valley	Equation Valley	A valley where equations float in the air like ancient runes	blue	valley	assets/backgrounds/equation_valley.png	t	2025-06-28 21:34:38.32134+00	2025-06-28 21:34:38.32134+00
factorization_caves	Factorization Caves	Deep caves where numbers break apart into their prime factors	purple	cave	assets/backgrounds/factorization_caves.png	t	2025-06-28 21:34:38.32134+00	2025-06-28 21:34:38.32134+00
convergence_tower	Convergence Tower	A towering structure where all mathematical knowledge converges	gold	tower	assets/backgrounds/convergence_tower.png	t	2025-06-28 21:34:38.32134+00	2025-06-28 21:34:38.32134+00
\.


--
-- Data for Name: user_achievements; Type: TABLE DATA; Schema: public; Owner: algebrini_user
--

COPY public.user_achievements (id, user_id, achievement_id, earned_at) FROM stdin;
\.


--
-- Data for Name: user_progress; Type: TABLE DATA; Schema: public; Owner: algebrini_user
--

COPY public.user_progress (id, user_id, game_id, level_id, score, completed, time_seconds, attempts, completed_at, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: user_rewards; Type: TABLE DATA; Schema: public; Owner: algebrini_user
--

COPY public.user_rewards (id, user_id, type, amount, badge_id, source, source_id, created_at) FROM stdin;
\.


--
-- Data for Name: user_story_progress; Type: TABLE DATA; Schema: public; Owner: algebrini_user
--

COPY public.user_story_progress (id, user_id, current_chapter, unlocked_chapters, story_progress, character_progress, world_map_unlocks, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: algebrini_user
--

COPY public.users (id, username, email, password_hash, role, avatar_id, preferences, is_active, last_login, created_at, updated_at) FROM stdin;
\.


--
-- Name: achievements achievements_pkey; Type: CONSTRAINT; Schema: public; Owner: algebrini_user
--

ALTER TABLE ONLY public.achievements
    ADD CONSTRAINT achievements_pkey PRIMARY KEY (id);


--
-- Name: analytics_events analytics_events_pkey; Type: CONSTRAINT; Schema: public; Owner: algebrini_user
--

ALTER TABLE ONLY public.analytics_events
    ADD CONSTRAINT analytics_events_pkey PRIMARY KEY (id);


--
-- Name: avatars avatars_pkey; Type: CONSTRAINT; Schema: public; Owner: algebrini_user
--

ALTER TABLE ONLY public.avatars
    ADD CONSTRAINT avatars_pkey PRIMARY KEY (id);


--
-- Name: challenge_types challenge_types_pkey; Type: CONSTRAINT; Schema: public; Owner: algebrini_user
--

ALTER TABLE ONLY public.challenge_types
    ADD CONSTRAINT challenge_types_pkey PRIMARY KEY (id);


--
-- Name: challenges challenges_pkey; Type: CONSTRAINT; Schema: public; Owner: algebrini_user
--

ALTER TABLE ONLY public.challenges
    ADD CONSTRAINT challenges_pkey PRIMARY KEY (id);


--
-- Name: chapters chapters_pkey; Type: CONSTRAINT; Schema: public; Owner: algebrini_user
--

ALTER TABLE ONLY public.chapters
    ADD CONSTRAINT chapters_pkey PRIMARY KEY (id);


--
-- Name: cutscenes cutscenes_pkey; Type: CONSTRAINT; Schema: public; Owner: algebrini_user
--

ALTER TABLE ONLY public.cutscenes
    ADD CONSTRAINT cutscenes_pkey PRIMARY KEY (id);


--
-- Name: games games_pkey; Type: CONSTRAINT; Schema: public; Owner: algebrini_user
--

ALTER TABLE ONLY public.games
    ADD CONSTRAINT games_pkey PRIMARY KEY (id);


--
-- Name: levels levels_game_id_level_number_key; Type: CONSTRAINT; Schema: public; Owner: algebrini_user
--

ALTER TABLE ONLY public.levels
    ADD CONSTRAINT levels_game_id_level_number_key UNIQUE (game_id, level_number);


--
-- Name: levels levels_pkey; Type: CONSTRAINT; Schema: public; Owner: algebrini_user
--

ALTER TABLE ONLY public.levels
    ADD CONSTRAINT levels_pkey PRIMARY KEY (id);


--
-- Name: realms realms_pkey; Type: CONSTRAINT; Schema: public; Owner: algebrini_user
--

ALTER TABLE ONLY public.realms
    ADD CONSTRAINT realms_pkey PRIMARY KEY (id);


--
-- Name: user_achievements user_achievements_pkey; Type: CONSTRAINT; Schema: public; Owner: algebrini_user
--

ALTER TABLE ONLY public.user_achievements
    ADD CONSTRAINT user_achievements_pkey PRIMARY KEY (id);


--
-- Name: user_achievements user_achievements_user_id_achievement_id_key; Type: CONSTRAINT; Schema: public; Owner: algebrini_user
--

ALTER TABLE ONLY public.user_achievements
    ADD CONSTRAINT user_achievements_user_id_achievement_id_key UNIQUE (user_id, achievement_id);


--
-- Name: user_progress user_progress_pkey; Type: CONSTRAINT; Schema: public; Owner: algebrini_user
--

ALTER TABLE ONLY public.user_progress
    ADD CONSTRAINT user_progress_pkey PRIMARY KEY (id);


--
-- Name: user_progress user_progress_user_id_level_id_key; Type: CONSTRAINT; Schema: public; Owner: algebrini_user
--

ALTER TABLE ONLY public.user_progress
    ADD CONSTRAINT user_progress_user_id_level_id_key UNIQUE (user_id, level_id);


--
-- Name: user_rewards user_rewards_pkey; Type: CONSTRAINT; Schema: public; Owner: algebrini_user
--

ALTER TABLE ONLY public.user_rewards
    ADD CONSTRAINT user_rewards_pkey PRIMARY KEY (id);


--
-- Name: user_story_progress user_story_progress_pkey; Type: CONSTRAINT; Schema: public; Owner: algebrini_user
--

ALTER TABLE ONLY public.user_story_progress
    ADD CONSTRAINT user_story_progress_pkey PRIMARY KEY (id);


--
-- Name: user_story_progress user_story_progress_user_id_key; Type: CONSTRAINT; Schema: public; Owner: algebrini_user
--

ALTER TABLE ONLY public.user_story_progress
    ADD CONSTRAINT user_story_progress_user_id_key UNIQUE (user_id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: algebrini_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: algebrini_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: algebrini_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: idx_achievements_requirements_gin; Type: INDEX; Schema: public; Owner: algebrini_user
--

CREATE INDEX idx_achievements_requirements_gin ON public.achievements USING gin (requirements);


--
-- Name: idx_achievements_title_fts; Type: INDEX; Schema: public; Owner: algebrini_user
--

CREATE INDEX idx_achievements_title_fts ON public.achievements USING gin (to_tsvector('english'::regconfig, (title)::text));


--
-- Name: idx_analytics_events_created_at; Type: INDEX; Schema: public; Owner: algebrini_user
--

CREATE INDEX idx_analytics_events_created_at ON public.analytics_events USING btree (created_at);


--
-- Name: idx_analytics_events_data_gin; Type: INDEX; Schema: public; Owner: algebrini_user
--

CREATE INDEX idx_analytics_events_data_gin ON public.analytics_events USING gin (event_data);


--
-- Name: idx_analytics_events_event_type; Type: INDEX; Schema: public; Owner: algebrini_user
--

CREATE INDEX idx_analytics_events_event_type ON public.analytics_events USING btree (event_type);


--
-- Name: idx_analytics_events_user_id; Type: INDEX; Schema: public; Owner: algebrini_user
--

CREATE INDEX idx_analytics_events_user_id ON public.analytics_events USING btree (user_id);


--
-- Name: idx_challenges_difficulty_score; Type: INDEX; Schema: public; Owner: algebrini_user
--

CREATE INDEX idx_challenges_difficulty_score ON public.challenges USING btree (difficulty_score);


--
-- Name: idx_challenges_level_id; Type: INDEX; Schema: public; Owner: algebrini_user
--

CREATE INDEX idx_challenges_level_id ON public.challenges USING btree (level_id);


--
-- Name: idx_challenges_metadata_gin; Type: INDEX; Schema: public; Owner: algebrini_user
--

CREATE INDEX idx_challenges_metadata_gin ON public.challenges USING gin (metadata);


--
-- Name: idx_challenges_question_fts; Type: INDEX; Schema: public; Owner: algebrini_user
--

CREATE INDEX idx_challenges_question_fts ON public.challenges USING gin (to_tsvector('english'::regconfig, question));


--
-- Name: idx_chapters_order_index; Type: INDEX; Schema: public; Owner: algebrini_user
--

CREATE INDEX idx_chapters_order_index ON public.chapters USING btree (order_index);


--
-- Name: idx_chapters_realm_id; Type: INDEX; Schema: public; Owner: algebrini_user
--

CREATE INDEX idx_chapters_realm_id ON public.chapters USING btree (realm_id);


--
-- Name: idx_chapters_requirements_gin; Type: INDEX; Schema: public; Owner: algebrini_user
--

CREATE INDEX idx_chapters_requirements_gin ON public.chapters USING gin (requirements);


--
-- Name: idx_chapters_rewards_gin; Type: INDEX; Schema: public; Owner: algebrini_user
--

CREATE INDEX idx_chapters_rewards_gin ON public.chapters USING gin (rewards);


--
-- Name: idx_chapters_title_fts; Type: INDEX; Schema: public; Owner: algebrini_user
--

CREATE INDEX idx_chapters_title_fts ON public.chapters USING gin (to_tsvector('english'::regconfig, (title)::text));


--
-- Name: idx_games_name_fts; Type: INDEX; Schema: public; Owner: algebrini_user
--

CREATE INDEX idx_games_name_fts ON public.games USING gin (to_tsvector('english'::regconfig, (name)::text));


--
-- Name: idx_levels_difficulty; Type: INDEX; Schema: public; Owner: algebrini_user
--

CREATE INDEX idx_levels_difficulty ON public.levels USING btree (difficulty);


--
-- Name: idx_levels_game_id; Type: INDEX; Schema: public; Owner: algebrini_user
--

CREATE INDEX idx_levels_game_id ON public.levels USING btree (game_id);


--
-- Name: idx_levels_requirements_gin; Type: INDEX; Schema: public; Owner: algebrini_user
--

CREATE INDEX idx_levels_requirements_gin ON public.levels USING gin (requirements);


--
-- Name: idx_user_achievements_user_id; Type: INDEX; Schema: public; Owner: algebrini_user
--

CREATE INDEX idx_user_achievements_user_id ON public.user_achievements USING btree (user_id);


--
-- Name: idx_user_progress_completed; Type: INDEX; Schema: public; Owner: algebrini_user
--

CREATE INDEX idx_user_progress_completed ON public.user_progress USING btree (completed);


--
-- Name: idx_user_progress_game_id; Type: INDEX; Schema: public; Owner: algebrini_user
--

CREATE INDEX idx_user_progress_game_id ON public.user_progress USING btree (game_id);


--
-- Name: idx_user_progress_user_id; Type: INDEX; Schema: public; Owner: algebrini_user
--

CREATE INDEX idx_user_progress_user_id ON public.user_progress USING btree (user_id);


--
-- Name: achievements update_achievements_updated_at; Type: TRIGGER; Schema: public; Owner: algebrini_user
--

CREATE TRIGGER update_achievements_updated_at BEFORE UPDATE ON public.achievements FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: avatars update_avatars_updated_at; Type: TRIGGER; Schema: public; Owner: algebrini_user
--

CREATE TRIGGER update_avatars_updated_at BEFORE UPDATE ON public.avatars FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: challenge_types update_challenge_types_updated_at; Type: TRIGGER; Schema: public; Owner: algebrini_user
--

CREATE TRIGGER update_challenge_types_updated_at BEFORE UPDATE ON public.challenge_types FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: challenges update_challenges_updated_at; Type: TRIGGER; Schema: public; Owner: algebrini_user
--

CREATE TRIGGER update_challenges_updated_at BEFORE UPDATE ON public.challenges FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: chapters update_chapters_updated_at; Type: TRIGGER; Schema: public; Owner: algebrini_user
--

CREATE TRIGGER update_chapters_updated_at BEFORE UPDATE ON public.chapters FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: cutscenes update_cutscenes_updated_at; Type: TRIGGER; Schema: public; Owner: algebrini_user
--

CREATE TRIGGER update_cutscenes_updated_at BEFORE UPDATE ON public.cutscenes FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: games update_games_updated_at; Type: TRIGGER; Schema: public; Owner: algebrini_user
--

CREATE TRIGGER update_games_updated_at BEFORE UPDATE ON public.games FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: levels update_levels_updated_at; Type: TRIGGER; Schema: public; Owner: algebrini_user
--

CREATE TRIGGER update_levels_updated_at BEFORE UPDATE ON public.levels FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: realms update_realms_updated_at; Type: TRIGGER; Schema: public; Owner: algebrini_user
--

CREATE TRIGGER update_realms_updated_at BEFORE UPDATE ON public.realms FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: user_progress update_user_progress_updated_at; Type: TRIGGER; Schema: public; Owner: algebrini_user
--

CREATE TRIGGER update_user_progress_updated_at BEFORE UPDATE ON public.user_progress FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: user_story_progress update_user_story_progress_updated_at; Type: TRIGGER; Schema: public; Owner: algebrini_user
--

CREATE TRIGGER update_user_story_progress_updated_at BEFORE UPDATE ON public.user_story_progress FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: users update_users_updated_at; Type: TRIGGER; Schema: public; Owner: algebrini_user
--

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: analytics_events analytics_events_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: algebrini_user
--

ALTER TABLE ONLY public.analytics_events
    ADD CONSTRAINT analytics_events_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: challenges challenges_level_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: algebrini_user
--

ALTER TABLE ONLY public.challenges
    ADD CONSTRAINT challenges_level_id_fkey FOREIGN KEY (level_id) REFERENCES public.levels(id) ON DELETE CASCADE;


--
-- Name: levels levels_game_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: algebrini_user
--

ALTER TABLE ONLY public.levels
    ADD CONSTRAINT levels_game_id_fkey FOREIGN KEY (game_id) REFERENCES public.games(id) ON DELETE CASCADE;


--
-- Name: user_achievements user_achievements_achievement_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: algebrini_user
--

ALTER TABLE ONLY public.user_achievements
    ADD CONSTRAINT user_achievements_achievement_id_fkey FOREIGN KEY (achievement_id) REFERENCES public.achievements(id) ON DELETE CASCADE;


--
-- Name: user_achievements user_achievements_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: algebrini_user
--

ALTER TABLE ONLY public.user_achievements
    ADD CONSTRAINT user_achievements_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_progress user_progress_game_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: algebrini_user
--

ALTER TABLE ONLY public.user_progress
    ADD CONSTRAINT user_progress_game_id_fkey FOREIGN KEY (game_id) REFERENCES public.games(id) ON DELETE CASCADE;


--
-- Name: user_progress user_progress_level_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: algebrini_user
--

ALTER TABLE ONLY public.user_progress
    ADD CONSTRAINT user_progress_level_id_fkey FOREIGN KEY (level_id) REFERENCES public.levels(id) ON DELETE CASCADE;


--
-- Name: user_progress user_progress_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: algebrini_user
--

ALTER TABLE ONLY public.user_progress
    ADD CONSTRAINT user_progress_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_rewards user_rewards_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: algebrini_user
--

ALTER TABLE ONLY public.user_rewards
    ADD CONSTRAINT user_rewards_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_story_progress user_story_progress_current_chapter_fkey; Type: FK CONSTRAINT; Schema: public; Owner: algebrini_user
--

ALTER TABLE ONLY public.user_story_progress
    ADD CONSTRAINT user_story_progress_current_chapter_fkey FOREIGN KEY (current_chapter) REFERENCES public.chapters(id) ON DELETE CASCADE;


--
-- Name: user_story_progress user_story_progress_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: algebrini_user
--

ALTER TABLE ONLY public.user_story_progress
    ADD CONSTRAINT user_story_progress_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: users users_avatar_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: algebrini_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_avatar_id_fkey FOREIGN KEY (avatar_id) REFERENCES public.avatars(id);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT USAGE ON SCHEMA public TO algebrini_user;


--
-- PostgreSQL database dump complete
--

