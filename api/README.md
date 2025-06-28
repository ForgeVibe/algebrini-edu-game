# Algebrini API Server

A simple Express.js API server that provides database access for the Algebrini educational game.

## Features

- RESTful API endpoints for games, levels, challenges, chapters, realms, and achievements
- User progress tracking and management
- PostgreSQL database integration
- CORS enabled for cross-origin requests
- Health check endpoint

## Prerequisites

- Node.js (v16 or higher)
- PostgreSQL database running (see main project's database setup)
- Database must be seeded with initial data

## Installation

1. Install dependencies:
```bash
npm install
```

2. Ensure the database is running:
```bash
# From project root
task db:start
```

3. Start the API server:
```bash
npm start
```

For development with auto-restart:
```bash
npm run dev
```

## API Endpoints

### Games
- `GET /api/games` - Get all games
- `GET /api/games/:id` - Get game by ID
- `GET /api/games/:id/levels` - Get levels for a game

### Levels
- `GET /api/levels/:id/challenges` - Get challenges for a level

### Chapters
- `GET /api/chapters` - Get all chapters
- `GET /api/chapters/:id` - Get chapter by ID

### Realms
- `GET /api/realms` - Get all realms
- `GET /api/realms/:id` - Get realm by ID

### Achievements
- `GET /api/achievements` - Get all achievements
- `GET /api/achievements/:id` - Get achievement by ID

### User Progress
- `GET /api/users/:userId/progress` - Get user progress (optional gameId query param)
- `POST /api/users/:userId/progress` - Save user progress

### Health Check
- `GET /api/health` - Check API and database health

## Configuration

The API server connects to the PostgreSQL database using these default settings:

- Host: localhost
- Port: 5432
- Database: algebrini_dev
- User: algebrini_user
- Password: algebrini_dev_password

To change these settings, modify the Pool configuration in `server.js`.

## Usage with Flutter

The Flutter app can connect to this API server using the `DatabaseService` class, which provides both direct database connection and HTTP API fallback methods.

## Development

The server runs on port 3000 by default. You can change this by setting the `PORT` environment variable.

## Error Handling

All endpoints include proper error handling and will return appropriate HTTP status codes and error messages. 