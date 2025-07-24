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
- All config and tool files/directories can always be kept up-to-date with the boilerplate.

---

### 1-2. Add Boilerplate to Existing Project

If you want to apply this boilerplate to an existing project:

#### Add boilerplate as submodule

```bash
git submodule add https://github.com/minukHwang/minuk-hwang-boilerplate.git boilerplate
```

---

### 2. Manual Sync/Update Command

> **Note:**
> If you see a `Permission denied` error when running the sync scripts, make them executable first:
>
> ```bash
> chmod +x ./scripts/sync-boilerplate.sh
> chmod +x ./scripts/sync-to-boilerplate.sh
> ```

<br/>

```bash
pnpm sync:boilerplate
# or
./scripts/sync-boilerplate.sh
```

- All config files and tool directories (like `.husky`, `scripts`, etc.) are interactively compared and merged using git diff/merge.
- For each file, you will see a diff and can choose to merge, skip, or copy new files.
- No files or directories are overwritten without your explicit confirmation.
- The list of directories to sync is managed in `scripts/boilerplate-sync-dirs.txt` (one per line).
- You can add more directories (e.g. `.github`, `.vscode`) to this file to enable syncing them as well.

#### Example: Add a new directory to sync

Edit `scripts/boilerplate-sync-dirs.txt` and add the directory name (do not include `scripts`):

```
.husky
.github
.vscode
```

> **Note:**
> The `scripts/` directory is always checked and merged first before syncing other directories. If any changes are merged or copied, you will be asked to re-run the sync script. Do not include `scripts` in `boilerplate-sync-dirs.txt`.

---

### 3. Reverse Sync (Project → Boilerplate)

You can also sync your local changes back to the boilerplate submodule:

```bash
pnpm sync:to-boilerplate
# or
./scripts/sync-to-boilerplate.sh
```

- This will compare your project files and directories to the boilerplate submodule and let you merge/copy changes back.
- Reverse sync is always interactive: for every file, you will be prompted to merge or copy (no --all-merge option, for safety).
- Supports the following option:
  - `--file <filename>`: Only sync/merge the specified file or directory
- At the end, you will be prompted whether to commit and push the changes in the boilerplate submodule. If you answer yes, the script will print the recommended git commands for you to run.

#### Example: Reverse sync only a specific file

```bash
pnpm sync:to-boilerplate --file .eslintrc.json
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
│   ├── sync-to-boilerplate.sh
│   ├── boilerplate-sync-dirs.txt
│   └── ...
└── boilerplate/   # submodule
```

---

## FAQ

- **Q. How are config/tool files and directories synced?**  
  A. The sync scripts interactively compare each file using git diff/merge. You can choose to merge, skip, or copy new files. No files are overwritten without your confirmation.

- **Q. How do I add a new directory to sync?**  
  A. Add the directory name to `scripts/boilerplate-sync-dirs.txt` (one per line, except `scripts`).

- **Q. Why is scripts/ not in sync-dirs?**  
  A. The `scripts/` directory is always pre-synced for safety and should not be listed in sync-dirs.

- **Q. How do I exclude directories from sync?**  
  A. Add the directory name to `scripts/boilerplate-ignore-dirs.txt` (one per line).

- **Q. What if package.json merging causes issues?**  
  A. You will see a diff and can choose to merge or skip. If you merge and there are issues, you can always restore from git history.

- **Q. How do I commit and push changes after sync?**  
  A. At the end of each sync script, you will be prompted whether to commit and push the changes. If you answer yes, the script will print the recommended git commands for you to run.

- **Q. How do I restore from backup?**  
  A. (If you use a backup system, describe it here. Otherwise, use git to restore previous versions.)

---
