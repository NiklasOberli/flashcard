# Development Workflow

## Branch Strategy

- **`main`** - Production-ready code, auto-deploys to Vercel
- **`develop`** - Active development branch

## Workflow

1. **Create a new branch** for each task: `git checkout -b feature/task-name`
2. Work on the task in your feature branch
3. Merge back to `develop` when complete
4. Merge `develop` to `main` when ready for production
