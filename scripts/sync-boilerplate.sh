#!/bin/bash

# Boilerplate Synchronization Script
# This script helps sync your project with the latest boilerplate changes

set -e

echo "🔄 Starting boilerplate synchronization..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if boilerplate submodule exists
if [ ! -d "boilerplate" ]; then
    echo -e "${RED}❌ Boilerplate submodule not found!${NC}"
    echo -e "${YELLOW}💡 To add boilerplate as submodule, run:${NC}"
    echo "   git submodule add <boilerplate-repo-url> boilerplate"
    exit 1
fi

# Update boilerplate submodule
echo -e "${BLUE}📥 Updating boilerplate submodule...${NC}"
git submodule update --remote boilerplate

# Check if there are any changes
if git diff --quiet boilerplate; then
    echo -e "${GREEN}✅ Boilerplate is already up to date!${NC}"
    exit 0
fi

echo -e "${YELLOW}⚠️  Changes detected in boilerplate.${NC}"
echo -e "${BLUE}📋 Files that will be updated:${NC}"

# List files that will be copied
echo "Configuration files:"
ls -la boilerplate/ | grep -E '\.(json|cjs|rc|ignore)$' || true

echo -e "\n${YELLOW}🔧 Copying configuration files...${NC}"

# Copy configuration files (with backup)
backup_dir=".boilerplate-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$backup_dir"

# List of files to sync
config_files=(
    "commitlint.config.cjs"
    ".eslintrc.json"
    ".prettierrc"
    ".prettierignore"
    ".eslintignore"
    "tsconfig.json"
    "next.config.mjs"
)

# Copy each file with backup
for file in "${config_files[@]}"; do
    if [ -f "boilerplate/$file" ]; then
        if [ -f "$file" ]; then
            echo -e "${BLUE}📄 Backing up $file...${NC}"
            cp "$file" "$backup_dir/"
        fi
        echo -e "${GREEN}📋 Copying $file...${NC}"
        cp "boilerplate/$file" .
    fi
done

# Copy husky hooks
if [ -d "boilerplate/.husky" ]; then
    echo -e "${BLUE}📄 Backing up .husky directory...${NC}"
    if [ -d ".husky" ]; then
        cp -r .husky "$backup_dir/"
    fi
    echo -e "${GREEN}📋 Copying .husky hooks...${NC}"
    cp -r boilerplate/.husky .

    # Make hooks executable
    chmod +x .husky/*
fi

# Copy package.json scripts and devDependencies (manual review required)
echo -e "${YELLOW}⚠️  Package.json changes require manual review:${NC}"
echo -e "${BLUE}📄 Compare boilerplate/package.json with your package.json${NC}"
echo -e "${BLUE}📄 Update scripts and devDependencies as needed${NC}"

# Show differences in package.json
if [ -f "boilerplate/package.json" ]; then
    echo -e "\n${BLUE}📊 Package.json differences:${NC}"
    diff package.json boilerplate/package.json || true
fi

echo -e "\n${GREEN}✅ Boilerplate synchronization completed!${NC}"
echo -e "${YELLOW}📁 Backup created in: $backup_dir${NC}"
echo -e "${YELLOW}⚠️  Please review changes before committing${NC}"
echo -e "${BLUE}💡 Next steps:${NC}"
echo "   1. Review the copied files"
echo "   2. Update package.json if needed"
echo "   3. Test your application"
echo "   4. Commit changes: git add . && git commit -m 'feat: sync with latest boilerplate'"

# Optional: Show git status
echo -e "\n${BLUE}📊 Current git status:${NC}"
git status --porcelain || true 