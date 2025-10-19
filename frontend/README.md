# Frontend - Flashcard Application

React + TypeScript + Vite web application for creating and studying flashcards.

## Tech Stack
- React
- TypeScript
- Vite
- Chakra UI
- React Router

## Setup

### Prerequisites
- Node.js (v18 or higher)

### Installation Steps

1. **Configure Environment Variables**
   ```bash
   # Copy the example environment file
   cp .env.example .env
   ```
   The default values in `.env.example` point to the local backend server.

2. **Install Dependencies**
   ```bash
   npm install
   ```

3. **Run in Development Mode**
   ```bash
   npm run dev
   ```
   The application will start on `http://localhost:5173`

### Environment Variables

- `VITE_API_URL` - Backend API URL (default: http://localhost:3001)
- `VITE_APP_NAME` - Application name

## Scripts

- `npm run dev` - Start development server with hot reload
- `npm run build` - Build for production
- `npm run preview` - Preview production build locally
- `npm run lint` - Run ESLint

## Development

Make sure the backend server is running before starting the frontend development server.
import reactDom from 'eslint-plugin-react-dom'

export default defineConfig([
  globalIgnores(['dist']),
  {
    files: ['**/*.{ts,tsx}'],
    extends: [
      // Other configs...
      // Enable lint rules for React
      reactX.configs['recommended-typescript'],
      // Enable lint rules for React DOM
      reactDom.configs.recommended,
    ],
    languageOptions: {
      parserOptions: {
        project: ['./tsconfig.node.json', './tsconfig.app.json'],
        tsconfigRootDir: import.meta.dirname,
      },
      // other options...
    },
  },
])
```
