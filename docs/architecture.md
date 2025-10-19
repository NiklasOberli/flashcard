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
