const express = require('express');
const { Pool } = require('pg');
const cors = require('cors');

const app = express();
const port = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Database connection
const pool = new Pool({
  host: 'localhost',
  port: 5432,
  database: 'algebrini_dev',
  user: 'algebrini_user',
  password: 'algebrini_dev_password',
});

// Test database connection
pool.query('SELECT NOW()', (err, res) => {
  if (err) {
    console.error('Database connection error:', err);
  } else {
    console.log('Database connected successfully');
  }
});

// ===== GAMES ENDPOINTS =====

// Get all games
app.get('/api/games', async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT id, name, description, icon, difficulty_levels, created_at, updated_at, is_active FROM games WHERE is_active = true ORDER BY name'
    );
    res.json(result.rows);
  } catch (err) {
    console.error('Error fetching games:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get game by ID
app.get('/api/games/:id', async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT id, name, description, icon, difficulty_levels, created_at, updated_at, is_active FROM games WHERE id = $1 AND is_active = true',
      [req.params.id]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Game not found' });
    }
    
    res.json(result.rows[0]);
  } catch (err) {
    console.error('Error fetching game:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get levels for a game
app.get('/api/games/:id/levels', async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT id, game_id, level_number, difficulty, requirements, created_at, updated_at, is_active FROM levels WHERE game_id = $1 AND is_active = true ORDER BY level_number',
      [req.params.id]
    );
    res.json(result.rows);
  } catch (err) {
    console.error('Error fetching levels:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// ===== LEVELS ENDPOINTS =====

// Get challenges for a level
app.get('/api/levels/:id/challenges', async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT id, level_id, question, answer, hint, explanation, metadata, difficulty_score, created_at, updated_at, is_active FROM challenges WHERE level_id = $1 AND is_active = true ORDER BY difficulty_score',
      [req.params.id]
    );
    res.json(result.rows);
  } catch (err) {
    console.error('Error fetching challenges:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// ===== CHAPTERS ENDPOINTS =====

// Get all chapters
app.get('/api/chapters', async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT id, title, subtitle, description, requirements, realm_id, games, levels, story_cutscene_id, rewards, order_index, created_at, updated_at, is_active FROM chapters WHERE is_active = true ORDER BY order_index'
    );
    res.json(result.rows);
  } catch (err) {
    console.error('Error fetching chapters:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get chapter by ID
app.get('/api/chapters/:id', async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT id, title, subtitle, description, requirements, realm_id, games, levels, story_cutscene_id, rewards, order_index, created_at, updated_at, is_active FROM chapters WHERE id = $1 AND is_active = true',
      [req.params.id]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Chapter not found' });
    }
    
    res.json(result.rows[0]);
  } catch (err) {
    console.error('Error fetching chapter:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// ===== REALMS ENDPOINTS =====

// Get all realms
app.get('/api/realms', async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT id, name, description, color, icon, background, created_at, updated_at, is_active FROM realms WHERE is_active = true ORDER BY name'
    );
    res.json(result.rows);
  } catch (err) {
    console.error('Error fetching realms:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get realm by ID
app.get('/api/realms/:id', async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT id, name, description, color, icon, background, created_at, updated_at, is_active FROM realms WHERE id = $1 AND is_active = true',
      [req.params.id]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Realm not found' });
    }
    
    res.json(result.rows[0]);
  } catch (err) {
    console.error('Error fetching realm:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// ===== ACHIEVEMENTS ENDPOINTS =====

// Get all achievements
app.get('/api/achievements', async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT id, title, description, icon, color, requirements, points, created_at, updated_at, is_active FROM achievements WHERE is_active = true ORDER BY points DESC'
    );
    res.json(result.rows);
  } catch (err) {
    console.error('Error fetching achievements:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get achievement by ID
app.get('/api/achievements/:id', async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT id, title, description, icon, color, requirements, points, created_at, updated_at, is_active FROM achievements WHERE id = $1 AND is_active = true',
      [req.params.id]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Achievement not found' });
    }
    
    res.json(result.rows[0]);
  } catch (err) {
    console.error('Error fetching achievement:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// ===== USER PROGRESS ENDPOINTS =====

// Get user progress
app.get('/api/users/:userId/progress', async (req, res) => {
  try {
    const { gameId } = req.query;
    let query = 'SELECT id, user_id, game_id, level_id, score, completed, time_seconds, attempts, completed_at, created_at, updated_at, is_active FROM user_progress WHERE user_id = $1 AND is_active = true';
    let params = [req.params.userId];
    
    if (gameId) {
      query += ' AND game_id = $2';
      params.push(gameId);
    }
    
    query += ' ORDER BY created_at DESC';
    
    const result = await pool.query(query, params);
    res.json(result.rows);
  } catch (err) {
    console.error('Error fetching user progress:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Save user progress
app.post('/api/users/:userId/progress', async (req, res) => {
  try {
    const { id, gameId, levelId, score, completed, timeSeconds, attempts, completedAt } = req.body;
    
    const result = await pool.query(
      `
      INSERT INTO user_progress (id, user_id, game_id, level_id, score, completed, time_seconds, attempts, completed_at, created_at, updated_at, is_active)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, NOW(), NOW(), true)
      ON CONFLICT (user_id, level_id) DO UPDATE SET
        score = EXCLUDED.score,
        completed = EXCLUDED.completed,
        time_seconds = EXCLUDED.time_seconds,
        attempts = EXCLUDED.attempts,
        completed_at = EXCLUDED.completed_at,
        updated_at = NOW()
      RETURNING *
      `,
      [id, req.params.userId, gameId, levelId, score, completed, timeSeconds, attempts, completedAt]
    );
    
    res.json(result.rows[0]);
  } catch (err) {
    console.error('Error saving user progress:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// ===== HEALTH CHECK =====

app.get('/api/health', async (req, res) => {
  try {
    await pool.query('SELECT 1');
    res.json({ status: 'healthy', database: 'connected' });
  } catch (err) {
    res.status(500).json({ status: 'unhealthy', database: 'disconnected', error: err.message });
  }
});

// ===== ERROR HANDLING =====

app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Something broke!' });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: 'Not found' });
});

// Start server
app.listen(port, () => {
  console.log(`API server running on port ${port}`);
});

// Graceful shutdown
process.on('SIGINT', async () => {
  console.log('Shutting down server...');
  await pool.end();
  process.exit(0);
}); 