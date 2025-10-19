# Development Workflow

## Branch Strategy

This project uses a simple Git branching model with two main branches:

### Main Branch (`main`)
- **Purpose**: Production-ready code
- **Protection**: Should always be stable and deployable
- **Updates**: Only receives merges from `develop` after testing
- **Deployments**: Automatically deploys to production (Vercel)

### Develop Branch (`develop`)
- **Purpose**: Integration branch for ongoing development
- **Usage**: All feature development and testing happens here
- **Status**: May contain work-in-progress features
- **Testing**: Features should be tested before merging to `main`

## Workflow

1. **Daily Development**: Work on the `develop` branch
   ```bash
   git checkout develop
   ```

2. **Making Changes**: Commit changes regularly
   ```bash
   git add .
   git commit -m "Description of changes"
   ```

3. **Pushing to Remote**: Push develop branch to remote
   ```bash
   git push origin develop
   ```

4. **Ready for Production**: When develop is stable and tested
   ```bash
   git checkout main
   git merge develop
   git push origin main
   ```

## Feature Development (Optional for Small Teams)

For larger features, you may optionally create feature branches:

```bash
# Create feature branch from develop
git checkout develop
git checkout -b feature/feature-name

# Work on feature...
git add .
git commit -m "Implement feature"

# Merge back to develop when complete
git checkout develop
git merge feature/feature-name
git branch -d feature/feature-name
```

## Best Practices

- ✅ Always work on `develop` for new features
- ✅ Test thoroughly before merging to `main`
- ✅ Write clear commit messages
- ✅ Keep commits focused and atomic
- ✅ Pull latest changes before starting work
- ❌ Never commit directly to `main` for untested code
- ❌ Don't merge broken code to `develop`

## Current Setup

The repository is currently configured with:
- `main` - Production branch
- `develop` - Development branch (newly created)

You are currently on the `develop` branch.
