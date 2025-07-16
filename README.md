# Minuk Hwang Boilerplate

A modern Next.js 14 boilerplate with React 18, TypeScript, Vanilla Extract, pnpm, and comprehensive development tools.

## Features

- **Next.js 14** with App Router
- **React 18** with latest features
- **TypeScript** for type safety
- **Vanilla Extract** for CSS-in-JS
- **pnpm** for fast package management
- **ESLint + Prettier** for code quality
- **Husky** for Git hooks
- **commitlint** for checking commit message rules
- **React Query** for server state management
- **Auto-emoji commits** with gitmoji integration

---

## Getting Started

### 1-1. Start a New Project

```bash
git clone https://github.com/minukHwang/minuk-hwang-boilerplate.git my-new-project
cd my-new-project
rm -rf .git
git init
pnpm install
```

- The `src/` directory is managed by you and never overwritten by sync.
- All config files can always be kept up-to-date with the boilerplate.

---

### 1-2. Add Boilerplate to Existing Project

If you want to apply this boilerplate to an existing project:

#### Add boilerplate as submodule

```bash
git submodule add https://github.com/minukHwang/minuk-hwang-boilerplate.git boilerplate
```

---

### 2. Manual Sync/Update Command

```bash
pnpm sync:boilerplate
# or
./scripts/sync-boilerplate.sh
```

- Config files are automatically copied/overwritten.
- For `package.json`, you will see a diff and can choose to merge automatically (no jq required).
- A backup of your previous `package.json` is always created before merging.

#### Sync Options

You can also choose what to sync:

```bash
# Full sync (config files + package.json) - default
./scripts/sync-boilerplate.sh

# Update configuration files only
./scripts/sync-boilerplate.sh --config-only

# Update package.json only
./scripts/sync-boilerplate.sh --package-only

# Show help
./scripts/sync-boilerplate.sh --help
```

---

## Development Workflow

### Committing Changes

This project uses gitmoji for commit messages. Commits are automatically formatted:

```bash
git commit -m "feat: add new feature"
# Automatically becomes: :sparkles: feat: add new feature
```

### Available Commit Types

- `feat` - New features
- `fix` - Bug fixes
- `docs` - Documentation changes
- `style` - Code style changes
- `refactor` - Code refactoring
- `perf` - Performance improvements
- `test` - Test additions/modifications
- `build` - Build system changes
- `ci` - CI/CD configuration changes
- `chore` - Routine maintenance tasks
- `revert` - Revert previous commits
- `init` - Initial setup

---

## Project Structure

```
├── src/
├── .husky/
├── commitlint.config.cjs
├── .eslintrc.json
├── .prettierrc
├── tsconfig.json
├── scripts/
│   ├── sync-boilerplate.sh
│   └── merge-package.js
└── boilerplate/   # submodule
```

---

## FAQ

- **Q. Why is `src/` never synced?**  
  A. Your business logic and code should be managed independently. The boilerplate only manages config and tooling.

- **Q. What if package.json merging causes issues?**  
  A. A backup is always created before merging, so you can easily restore your previous state.

- **Q. How do I restore from backup?**  
  A. Backups are stored in `.boilerplate-backup-YYYYMMDD-HHMMSS/` folders. To restore:

  ```bash
  # Restore all files from a specific backup
  cp .boilerplate-backup-20241201-143022/* .

  # Or restore specific files
  cp .boilerplate-backup-20241201-143022/package.json .
  cp .boilerplate-backup-20241201-143022/.eslintrc.json .
  ```

---
