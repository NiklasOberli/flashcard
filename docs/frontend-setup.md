# Frontend Setup

## Tech Stack
- React 18
- TypeScript
- Vite
- Chakra UI (planned)
- React Router (planned)

## Quick Start

### Prerequisites
- Node.js v18 or higher

### Installation

1. **Install dependencies:**
   ```powershell
   cd frontend
   npm install
   ```

2. **Configure environment:**
   ```powershell
   # Copy environment template
   Copy-Item .env.example .env
   ```

3. **Start development server:**
   ```powershell
   npm run dev
   ```
   Application runs at http://localhost:5173

**Important:** Make sure the backend server is running before starting the frontend.

## Environment Variables

Create `frontend/.env` with these variables:

```bash
# Backend API URL
VITE_API_URL=http://localhost:3001

# Application Name
VITE_APP_NAME=Flashcard App
```

## Available Scripts

| Command | Description |
|---------|-------------|
| `npm run dev` | Start development server with hot reload |
| `npm run build` | Build for production |
| `npm run preview` | Preview production build locally |
| `npm run lint` | Run ESLint |

## Project Structure

```
frontend/
├── src/
│   ├── main.tsx              # Application entry point
│   ├── App.tsx               # Root component
│   ├── components/           # Reusable components
│   ├── pages/                # Page components
│   ├── services/             # API services
│   ├── hooks/                # Custom React hooks
│   ├── types/                # TypeScript type definitions
│   └── styles/               # Global styles
├── public/                   # Static assets
├── index.html                # HTML template
├── vite.config.ts            # Vite configuration
├── tsconfig.json             # TypeScript configuration
└── package.json
```

## Development Workflow

1. **Start backend server** (required):
   ```powershell
   cd backend
   npm run dev
   ```

2. **Start frontend server** (in another terminal):
   ```powershell
   cd frontend
   npm run dev
   ```

3. **Open browser** at http://localhost:5173

4. **Make changes** - Hot reload enabled, changes appear instantly

## API Integration

### Creating API Service
Example API service for authentication:

```typescript
// src/services/api.ts
const API_URL = import.meta.env.VITE_API_URL;

export const authService = {
  register: async (email: string, password: string) => {
    const response = await fetch(`${API_URL}/api/auth/register`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password }),
    });
    return response.json();
  },
  
  login: async (email: string, password: string) => {
    const response = await fetch(`${API_URL}/api/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password }),
    });
    return response.json();
  },
};
```

### Authenticated Requests
```typescript
// src/services/api.ts
const getAuthHeaders = () => {
  const token = localStorage.getItem('token');
  return {
    'Content-Type': 'application/json',
    ...(token && { 'Authorization': `Bearer ${token}` }),
  };
};

export const flashcardService = {
  getAll: async () => {
    const response = await fetch(`${API_URL}/api/flashcards`, {
      headers: getAuthHeaders(),
    });
    return response.json();
  },
};
```

## PWA Configuration (Planned)

The application will be configured as a Progressive Web App:

1. **Service Worker** - Offline support and caching
2. **Manifest** - Install as app on mobile/desktop
3. **Icons** - App icons for different platforms

See [Architecture Documentation](./architecture.md) for PWA implementation details.

## Common Issues

**Port 5173 already in use:**
```powershell
# Find and kill process
Get-Process -Name node | Where-Object { $_.ProcessName -eq 'node' } | Stop-Process -Force

# Or change port in vite.config.ts:
# server: { port: 3000 }
```

**Cannot connect to backend:**
- Verify backend is running on port 3001
- Check `VITE_API_URL` in `.env`
- Check browser console for CORS errors
- Verify backend CORS configuration includes frontend URL

**Type errors after API changes:**
```powershell
# Restart TypeScript server in VS Code
# Ctrl+Shift+P → "TypeScript: Restart TS Server"
```

**Hot reload not working:**
```powershell
# Restart dev server
# Ctrl+C (stop)
npm run dev
```

## Building for Production

```powershell
# Build production bundle
npm run build

# Preview production build locally
npm run preview
```

Build output goes to `frontend/dist/` directory.

## Code Style

The project uses ESLint for code quality:

```powershell
# Check for linting errors
npm run lint

# Auto-fix fixable issues
npm run lint -- --fix
```

## Testing (Planned)

Future testing setup will include:
- **Vitest** - Unit and component tests
- **React Testing Library** - Component testing
- **Playwright** - E2E tests

## Integration with Backend

### Authentication Flow
1. **Registration:**
   - User submits email + password
   - Show password requirements
   - Display success message with verification instructions
   - Provide "Resend verification email" link

2. **Email Verification:**
   - Create `/verify-email` route
   - Extract token from URL query: `?token=XXX`
   - Call backend verification endpoint
   - Redirect to login on success

3. **Login:**
   - User submits credentials
   - Store JWT token in localStorage
   - Handle errors (unverified email, wrong password)
   - Redirect to dashboard on success

4. **Protected Routes:**
   - Check for token before rendering
   - Add Authorization header to API requests
   - Redirect to login if 401/403 error
   - Clear token on logout

### Token Management
```typescript
// src/utils/auth.ts
export const auth = {
  setToken: (token: string) => localStorage.setItem('token', token),
  getToken: () => localStorage.getItem('token'),
  clearToken: () => localStorage.removeItem('token'),
  isAuthenticated: () => !!localStorage.getItem('token'),
};
```

## Next Steps

1. ✅ Basic React + TypeScript setup complete
2. ⏭️ Implement authentication UI components
3. ⏭️ Add React Router for navigation
4. ⏭️ Implement flashcard CRUD interfaces
5. ⏭️ Add Chakra UI styling
6. ⏭️ Configure PWA features
7. ⏭️ Add error handling and validation
8. ⏭️ Write component tests

See [Project Tasks](./project-tasks.md) for complete development roadmap.
