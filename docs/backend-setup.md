# Backend Setup

## Tech Stack
- Node.js + Express
- TypeScript
- PostgreSQL (via Docker)
- Prisma ORM
- JWT Authentication

## Quick Start

### Prerequisites
- Node.js v18 or higher
- Docker and Docker Compose (for PostgreSQL)

### Installation

1. **Start PostgreSQL database:**
   ```powershell
   # From project root
   docker-compose up -d
   ```
   PostgreSQL will run on port 5432.

2. **Install dependencies:**
   ```powershell
   cd backend
   npm install
   ```

3. **Configure environment:**
   ```powershell
   # Copy environment template
   Copy-Item .env.example .env
   
   # Edit .env and set at minimum:
   # - JWT_SECRET (use a strong random string)
   # - SMTP credentials (for email functionality)
   ```

4. **Initialize database:**
   ```powershell
   # Generate Prisma client
   npm run db:generate
   
   # Push schema to database
   npm run db:push
   ```

5. **Start development server:**
   ```powershell
   npm run dev
   ```
   Server runs at http://localhost:3001

## Environment Variables

Create `backend/.env` with these variables:

```bash
# Server Configuration
PORT=3001
NODE_ENV=development
CORS_ORIGIN=http://localhost:5173

# Database
DATABASE_URL="postgresql://flashcard_user:flashcard_password@localhost:5432/flashcard_db?schema=public"

# JWT Authentication
JWT_SECRET=your-super-secret-jwt-key-change-in-production
JWT_EXPIRY=7d

# Frontend URL (for email links)
FRONTEND_URL=http://localhost:5173

# Email Service (Ethereal for development)
SMTP_HOST=smtp.ethereal.email
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=your-ethereal-username
SMTP_PASS=your-ethereal-password
EMAIL_FROM=Flashcard App <noreply@flashcard.app>
```

**Getting Ethereal Email credentials:**
1. Visit https://ethereal.email/
2. Click "Create Ethereal Account"
3. Copy the SMTP credentials to your `.env`

## Available Scripts

| Command | Description |
|---------|-------------|
| `npm run dev` | Start development server with hot reload |
| `npm run build` | Compile TypeScript to JavaScript |
| `npm start` | Run production build |
| `npm run db:generate` | Generate Prisma client |
| `npm run db:push` | Push schema to database |
| `npm run db:studio` | Open Prisma Studio (database GUI) |

## Project Structure

```
backend/
├── src/
│   ├── index.ts              # Express app setup & entry point
│   ├── routes/
│   │   └── auth.ts           # Authentication endpoints
│   ├── middleware/
│   │   └── auth.ts           # JWT authentication middleware
│   └── utils/
│       ├── emailService.ts   # Email sending
│       ├── passwordValidation.ts
│       └── tokenGenerator.ts
├── prisma/
│   ├── schema.prisma         # Database schema
│   └── migrations/           # Database migrations
├── .env                      # Environment variables (not committed)
├── .env.example              # Environment template
├── package.json
└── tsconfig.json
```

## Database Management

### Prisma Studio
Open a GUI to view/edit database records:
```powershell
npm run db:studio
```
Access at http://localhost:5555

### Direct PostgreSQL Access
```powershell
# Connect to PostgreSQL container
docker exec -it flashcard-postgres psql -U flashcard_user -d flashcard_db

# Useful commands:
# \dt          - List tables
# \d users     - Describe users table
# SELECT * FROM "User";
# \q           - Quit
```

### Reset Database
```powershell
# Stop and remove containers (data will be lost)
docker-compose down -v

# Start fresh
docker-compose up -d
cd backend
npm run db:push
```

## API Endpoints

See [API Endpoints Documentation](./api-endpoints.md) for complete API reference.

**Authentication endpoints:** `/api/auth/*`
- Register, login, email verification, password reset
- See [Authentication Documentation](./authentication.md) for details

## Development Workflow

1. **Make code changes** - TypeScript files in `src/`
2. **Server auto-restarts** - Nodemon watches for file changes
3. **Test endpoints** - Use test-auth.ps1 script or Postman
4. **Check database** - Use Prisma Studio to inspect data

## Common Issues

**Port 3001 already in use:**
```powershell
Get-Process -Name node | Stop-Process -Force
```

**Database connection error:**
```powershell
# Check if Docker container is running
docker ps

# View database logs
docker-compose logs -f

# Restart database
docker-compose restart
```

**Prisma client out of sync:**
```powershell
npm run db:generate
```

**TypeScript compilation errors:**
```powershell
# Check for errors
npm run build

# Or check in VS Code Problems panel
```

## Testing

Run the authentication test suite:
```powershell
# From project root
.\test-auth.ps1
```

See [Testing Documentation](./testing.md) for comprehensive testing guide.

## Production Considerations

Before deploying to production:

1. **Environment Variables:**
   - Use strong, unique `JWT_SECRET`
   - Configure production SMTP service (SendGrid, AWS SES, etc.)
   - Update `FRONTEND_URL` to production domain
   - Set `NODE_ENV=production`

2. **Database:**
   - Use managed PostgreSQL (e.g., Vercel Postgres, AWS RDS)
   - Update `DATABASE_URL` to production database
   - Run migrations: `npx prisma migrate deploy`

3. **Security:**
   - Enable rate limiting
   - Configure CORS for production domain only
   - Use HTTPS
   - Set up monitoring and logging

4. **Build:**
   ```powershell
   npm run build
   npm start
   ```

See [Deployment Documentation](./deployment.md) for detailed deployment instructions.
