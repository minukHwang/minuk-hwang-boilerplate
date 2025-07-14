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
- **commitlint** with gitmoji support
- **React Query** for server state management
- **Auto-emoji commits** with gitmoji integration

## Getting Started

### For New Projects

#### Method 1: Automated Setup (Recommended)

1. **Create a new directory and initialize git:**

   ```bash
   mkdir my-new-project
   cd my-new-project
   git init
   ```

2. **Download and run the setup script:**

   ```bash
   # Download the setup script
   curl -O https://raw.githubusercontent.com/your-username/minuk-hwang-boilerplate/main/scripts/setup-new-project.sh
   chmod +x setup-new-project.sh

   # Run the setup script
   ./setup-new-project.sh
   ```

3. **Follow the prompts and complete setup:**
   - Enter the boilerplate repository URL
   - Update package.json with required scripts and dependencies
   - Install dependencies
   - Test the setup

#### Method 2: Manual Setup

1. **Clone this repository as a template:**

   ```bash
   git clone <boilerplate-repo-url> my-new-project
   cd my-new-project
   rm -rf .git
   git init
   ```

2. **Customize the project:**

   ```bash
   # Update package.json name and description
   # Remove boilerplate-specific files
   # Add your own source code
   ```

3. **Install dependencies:**
   ```bash
   pnpm install
   ```

#### Method 3: GitHub Template

1. **Use this repository as a GitHub template**
2. **Click "Use this template" on GitHub**
3. **Create a new repository from the template**

### For Existing Projects

```bash
# Clone the repository
git clone <repository-url>
cd minuk-hwang-boilerplate

# Install dependencies
pnpm install

# Start development server
pnpm dev
```

## Boilerplate Synchronization

This boilerplate is designed to be easily synchronized with new projects. Here are several approaches:

### Method 1: Git Submodule (Recommended)

1. **Add as submodule to your project:**

   ```bash
   git submodule add <boilerplate-repo-url> boilerplate
   ```

2. **Update boilerplate in your project:**

   ```bash
   git submodule update --remote boilerplate
   ```

3. **Apply changes to your project:**
   ```bash
   # Copy updated files from boilerplate
   cp -r boilerplate/. .
   # Review and commit changes
   git add .
   git commit -m "feat: sync with latest boilerplate"
   ```

### Method 2: Template Repository

1. **Use this as a GitHub template repository**
2. **Create new projects from template**
3. **Manual sync when needed**

### Method 3: Automated Sync Script

Create a sync script that automatically pulls and applies boilerplate updates:

```bash
#!/bin/bash
# sync-boilerplate.sh

echo "🔄 Syncing with boilerplate..."

# Pull latest changes
git submodule update --remote boilerplate

# Copy configuration files
cp boilerplate/commitlint.config.cjs .
cp boilerplate/.husky/* .husky/
cp boilerplate/.eslintrc.json .
cp boilerplate/.prettierrc .
cp boilerplate/tsconfig.json .

# Update package.json scripts and devDependencies
# (Manual review required)

echo "✅ Boilerplate sync completed!"
echo "⚠️  Please review changes before committing"
```

### Method 4: GitHub Actions for Auto-Sync

Create a GitHub Action that automatically syncs when boilerplate is updated:

```yaml
# .github/workflows/sync-boilerplate.yml
name: Sync Boilerplate

on:
  schedule:
    - cron: '0 0 * * 0' # Weekly
  workflow_dispatch: # Manual trigger

jobs:
  sync:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          submodules: true

      - name: Update submodule
        run: |
          git submodule update --remote boilerplate
          git config --global user.name 'GitHub Action'
          git config --global user.email 'action@github.com'
          git add boilerplate
          git commit -m "feat: update boilerplate submodule" || exit 0
          git push
```

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

## Project Structure

```
├── src/
│   └── app/           # Next.js App Router
├── .husky/            # Git hooks
├── commitlint.config.cjs  # Commit message rules
├── .eslintrc.json     # ESLint configuration
├── .prettierrc        # Prettier configuration
├── tsconfig.json      # TypeScript configuration
├── scripts/           # Utility scripts
│   ├── setup-new-project.sh
│   └── sync-boilerplate.sh
└── .github/           # GitHub Actions
    └── workflows/
        └── sync-boilerplate.yml
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Commit with gitmoji
5. Submit a pull request

## License

MIT License
