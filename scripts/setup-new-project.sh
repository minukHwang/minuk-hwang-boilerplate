#!/bin/bash

# New Project Setup Script
# This script helps set up a new project using this boilerplate

set -e

echo "🚀 Setting up new project with Minuk Hwang Boilerplate..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo -e "${RED}❌ Not in a git repository!${NC}"
    echo -e "${YELLOW}💡 Please initialize git first:${NC}"
    echo "   git init"
    exit 1
fi

# Get boilerplate repository URL
read -p "Enter boilerplate repository URL: " BOILERPLATE_URL

if [ -z "$BOILERPLATE_URL" ]; then
    echo -e "${RED}❌ Boilerplate URL is required!${NC}"
    exit 1
fi

# Add boilerplate as submodule
echo -e "${BLUE}📥 Adding boilerplate as submodule...${NC}"
git submodule add "$BOILERPLATE_URL" boilerplate

# Copy configuration files
echo -e "${BLUE}📋 Copying configuration files...${NC}"

# List of files to copy
config_files=(
    "commitlint.config.cjs"
    ".eslintrc.json"
    ".prettierrc"
    ".prettierignore"
    ".eslintignore"
    "tsconfig.json"
    "next.config.mjs"
    ".gitignore"
)

# Copy each file
for file in "${config_files[@]}"; do
    if [ -f "boilerplate/$file" ]; then
        echo -e "${GREEN}📄 Copying $file...${NC}"
        cp "boilerplate/$file" .
    fi
done

# Copy husky hooks
if [ -d "boilerplate/.husky" ]; then
    echo -e "${GREEN}📄 Copying .husky hooks...${NC}"
    cp -r boilerplate/.husky .
    chmod +x .husky/*
fi

# Copy sync script
if [ -f "boilerplate/scripts/sync-boilerplate.sh" ]; then
    echo -e "${GREEN}📄 Copying sync script...${NC}"
    mkdir -p scripts
    cp boilerplate/scripts/sync-boilerplate.sh scripts/
    chmod +x scripts/sync-boilerplate.sh
fi

# Copy GitHub Actions
if [ -d "boilerplate/.github" ]; then
    echo -e "${GREEN}📄 Copying GitHub Actions...${NC}"
    cp -r boilerplate/.github .
fi

# Update package.json
echo -e "${YELLOW}⚠️  Updating package.json...${NC}"
echo -e "${BLUE}📄 Please manually update your package.json with:${NC}"
echo "   - Scripts from boilerplate/package.json"
echo "   - DevDependencies from boilerplate/package.json"
echo "   - Add 'sync:boilerplate' script"

# Show package.json differences
if [ -f "boilerplate/package.json" ]; then
    echo -e "\n${BLUE}📊 Package.json differences:${NC}"
    echo "=== SCRIPTS ==="
    grep -A 20 '"scripts"' boilerplate/package.json | head -20
    echo -e "\n=== DEV DEPENDENCIES ==="
    grep -A 30 '"devDependencies"' boilerplate/package.json | head -30
fi

# Install dependencies
echo -e "${BLUE}📦 Installing dependencies...${NC}"
if command -v pnpm &> /dev/null; then
    pnpm install
elif command -v npm &> /dev/null; then
    npm install
elif command -v yarn &> /dev/null; then
    yarn install
else
    echo -e "${RED}❌ No package manager found!${NC}"
    echo -e "${YELLOW}💡 Please install pnpm, npm, or yarn${NC}"
fi

# Initialize husky
echo -e "${BLUE}🔧 Initializing Husky...${NC}"
if command -v pnpm &> /dev/null; then
    pnpm prepare
elif command -v npm &> /dev/null; then
    npm run prepare
elif command -v yarn &> /dev/null; then
    yarn prepare
fi

echo -e "\n${GREEN}✅ Project setup completed!${NC}"
echo -e "${BLUE}💡 Next steps:${NC}"
echo "   1. Update package.json with boilerplate scripts and devDependencies"
echo "   2. Install dependencies: pnpm install"
echo "   3. Test the setup: pnpm dev"
echo "   4. Make your first commit: git add . && git commit -m 'init: setup project with boilerplate'"
echo "   5. To sync with boilerplate updates: pnpm sync:boilerplate"

# Show git status
echo -e "\n${BLUE}📊 Current git status:${NC}"
git status --porcelain || true 