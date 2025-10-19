# Backend - Flashcard Application API

Node.js + Express + TypeScript API server for the Flashcard application.

## Tech Stack
- Node.js
- Express
- TypeScript
- PostgreSQL
- Prisma ORM
- JWT Authentication

## Setup

### Prerequisites
- Node.js (v18 or higher)
- Docker and Docker Compose (for PostgreSQL)

### Installation Steps

1. **Start PostgreSQL with Docker**
   ```bash
   # From the project root directory
   docker-compose up -d
   ```
   This will start a PostgreSQL container on port 5432.

2. **Configure Environment Variables**
   ```bash
   # Copy the example environment file
   cp .env.example .env
   ```
   The default values in `.env.example` are configured to work with the Docker PostgreSQL setup.

3. **Install Dependencies**
   ```bash
   npm install
   ```

4. **Run in Development Mode**
   ```bash
   npm run dev
   ```
   The server will start on `http://localhost:3001`

### Environment Variables

- `PORT` - Server port (default: 3001)
- `NODE_ENV` - Environment (development/production)
- `DATABASE_URL` - PostgreSQL connection string
- `JWT_SECRET` - Secret key for JWT token generation
- `JWT_EXPIRES_IN` - JWT token expiration time
- `CORS_ORIGIN` - Allowed CORS origin (frontend URL)

## Scripts

- `npm run dev` - Start development server with hot reload
- `npm run build` - Build TypeScript to JavaScript
- `npm start` - Run production build
