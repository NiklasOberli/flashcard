# Flashcard Web Application - Architecture Overview

## System Requirements Summary

- Web-only application (no mobile clients, only PWA)
- User authentication (email + password)
- Multi-user support (~10 users)
- User-specific flashcard collections
- Dynamic, customizable folders per user
- Basic CRUD operations (Create, Read, Update, Delete)
- Simple folder-based organization
- No spaced repetition or advanced scheduling

## High-Level Architecture

### 1. Three-Tier Architecture

**Recommended Stack for Your Use Case:**
```
React Frontend ←→ Node.js/Express API ←→ PostgreSQL Database
```

### 2. Component Breakdown

#### Frontend (Client-Side)
- **Purpose**: User interface and user experience
- **Responsibilities**:
  - User authentication forms
  - Flashcard management interface
  - Folder organization and management
  - Card creation, editing, and viewing
  - Session management
- **Design Requirements**:
  - **Mobile-first responsive design** (phone → tablet → desktop)
  - Clean, minimalist interface
  - Smooth, delightful animations
  - Dark/light mode support
  - Touch-friendly interactions
  - Fast, responsive performance
  - **Progressive Web App (PWA)** capabilities for installability and offline support

#### Backend API (Server-Side)
- **Purpose**: Business logic and data management
- **Responsibilities**:
  - User authentication and authorization
  - API endpoints for CRUD operations
  - Data validation and sanitization
  - Security implementation (JWT tokens, password hashing)
  - Database interactions

#### Database (Data Layer)
- **Purpose**: Data persistence and storage
- **Responsibilities**:
  - User account information
  - Flashcard content and metadata
  - Folder structure and organization
  - User sessions and authentication tokens

## Technology Stack

### JavaScript/TypeScript Full Stack
- **Frontend**: React with TypeScript
- **Backend**: Node.js with Express.js
- **Database**: PostgreSQL with Prisma ORM
- **Authentication**: JWT tokens + bcrypt for password hashing
- **UI Framework**: Chakra UI for accessible, responsive component library
- **Animations**: Built-in Chakra UI animations + Framer Motion for advanced interactions
- **PWA**: Service workers, manifest.json, and offline capabilities

## Database Schema Design

### Core Entities

```
Users
├── id (Primary Key)
├── email (Unique)
├── password_hash
├── created_at
└── updated_at

Folders
├── id (Primary Key)
├── user_id (Foreign Key → Users.id)
├── name (e.g., "Learning", "Backlog", "Remembered")
├── created_at
└── updated_at

Flashcards
├── id (Primary Key)
├── user_id (Foreign Key → Users.id)
├── folder_id (Foreign Key → Folders.id)
├── front_text
├── back_text
├── created_at
└── updated_at
```

### Relationships
- One User → Many Folders (1:N)
- One User → Many Flashcards (1:N)
- One Folder → Many Flashcards (1:N)

## API Endpoints Design

### Authentication
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `POST /api/auth/logout` - User logout
- `GET /api/auth/me` - Get current user info

### Folders
- `GET /api/folders` - Get user's folders
- `POST /api/folders` - Create new folder
- `PUT /api/folders/:id` - Update folder name
- `DELETE /api/folders/:id` - Delete folder

### Flashcards
- `GET /api/flashcards` - Get all user's flashcards
- `GET /api/flashcards?folder_id=:id` - Get flashcards by folder
- `POST /api/flashcards` - Create new flashcard
- `PUT /api/flashcards/:id` - Update flashcard
- `DELETE /api/flashcards/:id` - Delete flashcard
- `PATCH /api/flashcards/:id/move` - Move card to different folder

## Hosting Recommendation

### Vercel + Vercel Postgres
- **Frontend**: Vercel (automatic deployments from Git)
- **Backend**: Vercel Serverless Functions
- **Database**: Vercel Postgres (PostgreSQL with serverless connections)
- **Pros**: Easy setup, generous free tier, integrated CI/CD, consistent PostgreSQL everywhere
- **Cons**: Vendor lock-in

> **Alternative**: Railway or Render for full-stack PostgreSQL hosting with more control and flexibility.

## Security Considerations

### Authentication & Authorization
- Password hashing using bcrypt/scrypt
- JWT tokens with appropriate expiration times
- HTTPS enforcement
- Input validation and sanitization
- Rate limiting on auth endpoints

### Data Protection
- User data isolation (users can only access their own data)
- SQL injection prevention (using parameterized queries/ORM)
- XSS protection (proper output encoding)
- CORS configuration

## Development Workflow

### 1. Development Environment
- Local PostgreSQL database (Docker recommended)
- Environment variables for configuration
- Hot reload for both frontend and backend

### 2. Deployment Pipeline
- Git-based deployments
- Automated testing (unit tests for critical functions)
- Environment-specific configurations (dev/staging/prod)
- Database migrations

## Scalability Considerations

### For 10 Users (Current Scope)
- Single server/container deployment is sufficient
- Basic database without clustering
- Simple session management
- Minimal caching requirements

### Future Growth Path
- Database connection pooling
- Redis for session storage and caching
- CDN for static assets
- Horizontal scaling with load balancers
- Database read replicas

## Cost Estimation (Monthly)

### Small Scale (10 users)
- **Vercel + Vercel Postgres**: $0-20/month (free tier available)
- **Alternative (Railway/Render)**: $5-15/month

## Next Steps

✅ **Technology stack chosen**: React + Node.js/Express + PostgreSQL

### Development Phase
1. **Set up project structure** and initialize React + Express applications
2. **Configure development environment** (Docker PostgreSQL, environment variables)
3. **Set up Prisma ORM** and create database schema
4. **Implement authentication system** (registration, login, JWT)
5. **Build core API endpoints** for folders and flashcards CRUD
6. **Develop React components** for authentication and main interface
7. **Configure PWA** (service worker, manifest.json, offline support)
8. **Add error handling and input validation**
9. **Write basic tests** for critical functionality

### Deployment Phase
9. **Set up Vercel account** and connect GitHub repository
10. **Configure Vercel Postgres database** and run migrations
11. **Deploy and test** the application (including PWA installation)
12. **Invite test users** and gather feedback

## File Structure

```
flashcard-app/
├── frontend/                 # React application
│   ├── src/
│   │   ├── components/       # React components
│   │   ├── pages/           # Page components
│   │   ├── hooks/           # Custom React hooks
│   │   ├── services/        # API calls
│   │   ├── styles/          # Global styles & themes
│   │   └── types/           # TypeScript types
│   ├── public/
│   └── package.json
├── backend/                  # Express API server
│   ├── src/
│   │   ├── routes/          # API routes
│   │   ├── middleware/      # Auth & validation
│   │   ├── models/          # Database models
│   │   └── utils/           # Helper functions
│   ├── prisma/              # Prisma schema & migrations
│   └── package.json
├── docs/                     # Documentation
│   └── ui-design.md         # UI/UX specifications
├── docker-compose.yml        # Local PostgreSQL
└── README.md
```

This architecture provides a solid foundation for a simple, maintainable flashcard application that can grow with your needs.
