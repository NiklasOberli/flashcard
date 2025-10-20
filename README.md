# Flashcard Application

A simple, user-friendly web application for creating and studying flashcards with folder organization and multi-user support.

## Features

- Create and manage flashcards organized in folders
- Multi-user support with authentication
- Study mode for effective learning
- RESTful API architecture
- Modern web interface

## Documentation

### Getting Started
- **[Backend Setup](./docs/backend-setup.md)** - Backend installation, configuration, and development
- **[Frontend Setup](./docs/frontend-setup.md)** - Frontend installation, configuration, and development
- **[Testing Guide](./docs/testing.md)** - How to run tests and verify functionality

### System Documentation
- **[Architecture](./docs/architecture.md)** - System architecture, technology stack, and file structure
- **[Authentication](./docs/authentication.md)** - Authentication system implementation and usage
- **[Database Schema](./docs/database-schema.md)** - Database design and entity relationships
- **[API Endpoints](./docs/api-endpoints.md)** - API endpoint specifications

### Development & Deployment
- **[Development Workflow](./docs/development-workflow.md)** - Git branching strategy and development workflow
- **[Deployment](./docs/deployment.md)** - Hosting, security, scalability, and cost considerations
- **[Project Tasks](./docs/project-tasks.md)** - Project task checklist and roadmap

## Getting Started

### Prerequisites
- Node.js (v18 or higher)
- Docker and Docker Compose
- Git

### Quick Start

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd flashcard
   ```

2. **Start the PostgreSQL database**
   ```bash
   docker-compose up -d
   ```

3. **Set up the backend**
   ```bash
   cd backend
   cp .env.example .env
   npm install
   npm run dev
   ```

4. **Set up the frontend** (in a new terminal)
   ```bash
   cd frontend
   cp .env.example .env
   npm install
   npm run dev
   ```

5. **Access the application**
   - Frontend: http://localhost:5173
   - Backend API: http://localhost:3001

For detailed setup instructions:
- See **[Backend Setup](./docs/backend-setup.md)** for backend configuration details
- See **[Frontend Setup](./docs/frontend-setup.md)** for frontend configuration details
- See **[Authentication](./docs/authentication.md)** for authentication system documentation

### Stopping the Development Environment

- Stop the frontend/backend: `Ctrl+C` in their respective terminals
- Stop the database: `docker-compose down`
- Stop and remove database data: `docker-compose down -v`

For the project task checklist, see **[Project Tasks](./docs/project-tasks.md)**.
