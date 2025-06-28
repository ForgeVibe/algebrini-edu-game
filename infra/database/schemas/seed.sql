-- Algebrini Educational Game Seed Data
-- Populate database with initial content

-- Insert games
INSERT INTO games (id, name, description, icon, difficulty_levels) VALUES
('recursive-sequences', 'Recursive Sequences', 'Discover patterns in number sequences and predict the next terms.', 'sequence', 5),
('simple-equations', 'Simple Equations', 'Solve equations with one variable to unlock mathematical mysteries.', 'equation', 5),
('factorization-fun', 'Factorization Fun', 'Break down numbers into their prime factors and understand number structure.', 'factorization', 5);

-- Insert realms
INSERT INTO realms (id, name, description, color, icon, background) VALUES
('crystal_forest', 'Crystal Forest', 'A mystical forest where crystal formations follow mathematical patterns', 'green', 'forest', 'assets/backgrounds/crystal_forest.png'),
('equation_valley', 'Equation Valley', 'A valley where equations float in the air like ancient runes', 'blue', 'valley', 'assets/backgrounds/equation_valley.png'),
('factorization_caves', 'Factorization Caves', 'Deep caves where numbers break apart into their prime factors', 'purple', 'cave', 'assets/backgrounds/factorization_caves.png'),
('convergence_tower', 'Convergence Tower', 'A towering structure where all mathematical knowledge converges', 'gold', 'tower', 'assets/backgrounds/convergence_tower.png');

-- Insert cutscenes
INSERT INTO cutscenes (id, title, content, character, background) VALUES
('chapter_1_intro', 'Welcome to Algebrini', 
 '["Welcome, young mathematician! You have been chosen to explore the magical world of Algebrini.", "Here, numbers are not just symbols on a page - they are living, breathing entities with stories to tell.", "Your journey begins in the Crystal Forest, where patterns emerge from the very air around you.", "Are you ready to discover the secrets that lie within?"]', 
 'narrator', 'crystal_forest'),
('chapter_2_intro', 'The Pattern Seekers', 
 '["You have proven yourself worthy of the Crystal Forest''s secrets!", "But there is more to discover. The ancient patterns grow more complex, revealing deeper mathematical truths.", "Each sequence you solve unlocks a piece of the forest''s ancient wisdom.", "Continue your quest, pattern seeker!"]', 
 'narrator', 'crystal_forest'),
('chapter_3_intro', 'Beyond the Forest', 
 '["Your mastery of patterns has opened the path to the Equation Valley!", "Here, unknown values hide in plain sight, waiting to be discovered.", "Variables are not just letters - they are the keys to unlocking mathematical mysteries.", "Prepare to solve equations that have puzzled scholars for generations!"]', 
 'narrator', 'equation_valley'),
('chapter_4_intro', 'The Factorization Caves', 
 '["Your journey leads you to the Factorization Caves, where numbers reveal their true nature.", "Every number is made up of smaller building blocks - prime factors.", "By breaking numbers apart, you will understand how they are constructed.", "Enter the caves and discover the building blocks of mathematics!"]', 
 'narrator', 'factorization_caves'),
('chapter_5_intro', 'The Grand Convergence', 
 '["You have mastered the individual arts of mathematics!", "Now, at the Convergence Tower, all your knowledge will be tested.", "Patterns, equations, and factorization - they all work together.", "This is your final challenge. Are you ready to become a true master of Algebrini?"]', 
 'narrator', 'convergence_tower');

-- Insert chapters
INSERT INTO chapters (id, title, subtitle, description, requirements, realm_id, games, levels, story_cutscene_id, rewards, order_index) VALUES
('chapter_1', 'The Awakening', 'Discovering the Magic of Numbers', 
 'Welcome to Algebrini! Your journey begins in the mystical realm where numbers come alive.',
 '{"type": "none"}',
 'crystal_forest',
 '["recursive-sequences"]',
 '[1, 2]',
 'chapter_1_intro',
 '{"stars": 10, "badge": "first_steps"}',
 1),
('chapter_2', 'The Pattern Seekers', 'Unlocking the Secrets of Sequences', 
 'Deep in the Crystal Forest, ancient patterns reveal themselves to those who look carefully.',
 '{"type": "chapter_completion", "chapter": "chapter_1"}',
 'crystal_forest',
 '["recursive-sequences"]',
 '[3, 4, 5]',
 'chapter_2_intro',
 '{"stars": 15, "badge": "pattern_master"}',
 2),
('chapter_3', 'The Equation Valley', 'Solving the Mysteries of Variables', 
 'Beyond the forest lies the Equation Valley, where unknown values hide in plain sight.',
 '{"type": "game_completion", "game": "recursive-sequences", "levels": 3}',
 'equation_valley',
 '["simple-equations"]',
 '[1, 2, 3]',
 'chapter_3_intro',
 '{"stars": 20, "badge": "equation_solver"}',
 3),
('chapter_4', 'The Factorization Caves', 'Breaking Down the Building Blocks', 
 'In the depths of the Factorization Caves, numbers break apart to reveal their secrets.',
 '{"type": "game_completion", "game": "simple-equations", "levels": 2}',
 'factorization_caves',
 '["factorization-fun"]',
 '[1, 2, 3]',
 'chapter_4_intro',
 '{"stars": 25, "badge": "factor_finder"}',
 4),
('chapter_5', 'The Grand Convergence', 'Mastering All Mathematical Arts', 
 'At the heart of Algebrini, all mathematical paths converge in the ultimate challenge.',
 '{"type": "all_games_completion", "games": ["recursive-sequences", "simple-equations", "factorization-fun"]}',
 'convergence_tower',
 '["recursive-sequences", "simple-equations", "factorization-fun"]',
 '[4, 5]',
 'chapter_5_intro',
 '{"stars": 50, "badge": "algebrini_master"}',
 5);

-- Insert achievements
INSERT INTO achievements (id, title, description, icon, color, requirements, points) VALUES
('first_level', 'First Steps', 'Complete your first level', 'star', 'green', '{"type": "level_completion", "count": 1}', 10),
('perfect_score', 'Perfect Score', 'Get a perfect score on any level', 'trophy', 'gold', '{"type": "perfect_score", "count": 1}', 50),
('level_master', 'Level Master', 'Complete all levels in a game', 'crown', 'purple', '{"type": "all_levels_completion", "game": "any"}', 100),
('streak_master', 'Streak Master', 'Get 10 correct answers in a row', 'fire', 'orange', '{"type": "streak", "count": 10}', 75),
('speed_demon', 'Speed Demon', 'Complete a level in under 30 seconds', 'bolt', 'yellow', '{"type": "speed", "time_seconds": 30}', 25);

-- Insert challenge types
INSERT INTO challenge_types (id, name, description, type, requirements, rewards) VALUES
('daily_sequence', 'Daily Sequence', 'Complete 3 recursive sequence problems', 'daily', '{"game": "recursive-sequences", "count": 3}', '{"coins": 50, "stars": 5}'),
('daily_equation', 'Daily Equation', 'Solve 2 simple equations', 'daily', '{"game": "simple-equations", "count": 2}', '{"coins": 50, "stars": 5}'),
('daily_factorization', 'Daily Factorization', 'Factor 4 numbers correctly', 'daily', '{"game": "factorization-fun", "count": 4}', '{"coins": 50, "stars": 5}'),
('weekly_master', 'Weekly Master', 'Complete all daily challenges in a week', 'weekly', '{"daily_challenges": 7}', '{"coins": 200, "stars": 20, "badge": "weekly_master"}'),
('weekly_perfect', 'Weekly Perfect', 'Get perfect scores on 5 levels', 'weekly', '{"perfect_scores": 5}', '{"coins": 300, "stars": 30, "badge": "perfectionist"}');

-- Insert avatars
INSERT INTO avatars (id, name, description, icon, unlock_requirements) VALUES
('wizard', 'Math Wizard', 'A wise wizard who understands the secrets of numbers', 'assets/avatars/wizard.png', '{"type": "none"}'),
('knight', 'Number Knight', 'A brave knight who defends mathematical truth', 'assets/avatars/knight.png', '{"type": "achievement", "achievement": "first_level"}'),
('scientist', 'Pattern Scientist', 'A curious scientist who studies mathematical patterns', 'assets/avatars/scientist.png', '{"type": "achievement", "achievement": "level_master"}'),
('dragon', 'Equation Dragon', 'A powerful dragon who breathes mathematical fire', 'assets/avatars/dragon.png', '{"type": "achievement", "achievement": "perfect_score"}');

-- Insert levels for recursive sequences
INSERT INTO levels (game_id, level_number, difficulty, requirements) VALUES
('recursive-sequences', 1, 'easy', '{"type": "always"}'),
('recursive-sequences', 2, 'easy', '{"type": "score", "requirement": 3, "game": "recursive-sequences", "level": 1}'),
('recursive-sequences', 3, 'medium', '{"type": "score", "requirement": 4, "game": "recursive-sequences", "level": 2}'),
('recursive-sequences', 4, 'hard', '{"type": "completion", "requirement": 2, "game": "recursive-sequences"}'),
('recursive-sequences', 5, 'expert', '{"type": "streak", "requirement": 5, "game": "recursive-sequences"}');

-- Insert levels for simple equations
INSERT INTO levels (game_id, level_number, difficulty, requirements) VALUES
('simple-equations', 1, 'easy', '{"type": "always"}'),
('simple-equations', 2, 'easy', '{"type": "score", "requirement": 3, "game": "simple-equations", "level": 1}'),
('simple-equations', 3, 'medium', '{"type": "score", "requirement": 4, "game": "simple-equations", "level": 2}'),
('simple-equations', 4, 'hard', '{"type": "completion", "requirement": 2, "game": "simple-equations"}'),
('simple-equations', 5, 'expert', '{"type": "streak", "requirement": 5, "game": "simple-equations"}');

-- Insert levels for factorization
INSERT INTO levels (game_id, level_number, difficulty, requirements) VALUES
('factorization-fun', 1, 'easy', '{"type": "always"}'),
('factorization-fun', 2, 'easy', '{"type": "score", "requirement": 3, "game": "factorization-fun", "level": 1}'),
('factorization-fun', 3, 'medium', '{"type": "score", "requirement": 4, "game": "factorization-fun", "level": 2}'),
('factorization-fun', 4, 'hard', '{"type": "completion", "requirement": 2, "game": "factorization-fun"}'),
('factorization-fun', 5, 'expert', '{"type": "streak", "requirement": 5, "game": "factorization-fun"}');

-- Insert challenges for recursive sequences (Level 1)
INSERT INTO challenges (level_id, question, answer, hint, explanation, metadata, difficulty_score) 
SELECT l.id, 
       'What comes next in the sequence: 2, 4, 6, 8, ?', 
       '10', 
       'Look at the difference between consecutive numbers.', 
       'This is an arithmetic sequence where each number increases by 2.',
       '{"sequence": [2, 4, 6, 8, 10], "type": "arithmetic", "difference": 2}',
       2
FROM levels l WHERE l.game_id = 'recursive-sequences' AND l.level_number = 1;

INSERT INTO challenges (level_id, question, answer, hint, explanation, metadata, difficulty_score) 
SELECT l.id, 
       'What comes next in the sequence: 1, 3, 5, 7, ?', 
       '9', 
       'Each number is 2 more than the previous one.', 
       'This is an arithmetic sequence with a common difference of 2.',
       '{"sequence": [1, 3, 5, 7, 9], "type": "arithmetic", "difference": 2}',
       2
FROM levels l WHERE l.game_id = 'recursive-sequences' AND l.level_number = 1;

INSERT INTO challenges (level_id, question, answer, hint, explanation, metadata, difficulty_score) 
SELECT l.id, 
       'What comes next in the sequence: 3, 6, 9, 12, ?', 
       '15', 
       'How much do you add each time?', 
       'This sequence increases by 3 each time.',
       '{"sequence": [3, 6, 9, 12, 15], "type": "arithmetic", "difference": 3}',
       2
FROM levels l WHERE l.game_id = 'recursive-sequences' AND l.level_number = 1;

-- Insert challenges for simple equations (Level 1)
INSERT INTO challenges (level_id, question, answer, hint, explanation, metadata, difficulty_score) 
SELECT l.id, 
       'Solve for x: x + 3 = 7', 
       '4', 
       'What number plus 3 equals 7?', 
       'Subtract 3 from both sides: x = 7 - 3 = 4',
       '{"equation": "x + 3 = 7", "solution": 4, "type": "addition"}',
       2
FROM levels l WHERE l.game_id = 'simple-equations' AND l.level_number = 1;

INSERT INTO challenges (level_id, question, answer, hint, explanation, metadata, difficulty_score) 
SELECT l.id, 
       'Solve for x: x - 2 = 5', 
       '7', 
       'What number minus 2 equals 5?', 
       'Add 2 to both sides: x = 5 + 2 = 7',
       '{"equation": "x - 2 = 5", "solution": 7, "type": "subtraction"}',
       2
FROM levels l WHERE l.game_id = 'simple-equations' AND l.level_number = 1;

INSERT INTO challenges (level_id, question, answer, hint, explanation, metadata, difficulty_score) 
SELECT l.id, 
       'Solve for x: 2x = 8', 
       '4', 
       'What number times 2 equals 8?', 
       'Divide both sides by 2: x = 8 ÷ 2 = 4',
       '{"equation": "2x = 8", "solution": 4, "type": "multiplication"}',
       3
FROM levels l WHERE l.game_id = 'simple-equations' AND l.level_number = 1;

-- Insert challenges for factorization (Level 1)
INSERT INTO challenges (level_id, question, answer, hint, explanation, metadata, difficulty_score) 
SELECT l.id, 
       'What are all the factors of 6?', 
       '1,2,3,6', 
       'A factor is a number that divides evenly into another number.', 
       '6 can be divided by 1, 2, 3, and 6, so these are its factors.',
       '{"number": 6, "factors": [1, 2, 3, 6], "type": "Small Composite"}',
       2
FROM levels l WHERE l.game_id = 'factorization-fun' AND l.level_number = 1;

INSERT INTO challenges (level_id, question, answer, hint, explanation, metadata, difficulty_score) 
SELECT l.id, 
       'What are all the factors of 8?', 
       '1,2,4,8', 
       'Think about what numbers divide 8 evenly.', 
       '8 can be divided by 1, 2, 4, and 8, so these are its factors.',
       '{"number": 8, "factors": [1, 2, 4, 8], "type": "Power of 2"}',
       2
FROM levels l WHERE l.game_id = 'factorization-fun' AND l.level_number = 1;

INSERT INTO challenges (level_id, question, answer, hint, explanation, metadata, difficulty_score) 
SELECT l.id, 
       'What are all the factors of 10?', 
       '1,2,5,10', 
       'What numbers can you multiply to get 10?', 
       '10 can be divided by 1, 2, 5, and 10, so these are its factors.',
       '{"number": 10, "factors": [1, 2, 5, 10], "type": "Small Composite"}',
       2
FROM levels l WHERE l.game_id = 'factorization-fun' AND l.level_number = 1; 