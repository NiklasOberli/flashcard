# Development Workflow

## Branch Strategy

- **`main`** - Production-ready code, auto-deploys to Vercel
- **`develop`** - Active development branch

## Workflow

Work on `develop`, merge to `main` when ready for production:

```powershell
# Daily work (on develop)
git add .
git commit -m "Description"
git push origin develop

# Deploy to production (when ready)
git checkout main
git merge develop
git push origin main
```
