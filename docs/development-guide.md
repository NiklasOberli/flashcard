# Development Guide

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
