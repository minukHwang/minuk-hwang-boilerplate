#!/bin/bash

# Boilerplate Synchronization Script
# This script helps sync your project with the latest boilerplate changes

set -e

# Parse command line options
CONFIG_ONLY=false
PACKAGE_ONLY=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --config-only)
      CONFIG_ONLY=true
      shift
      ;;
    --package-only)
      PACKAGE_ONLY=true
      shift
      ;;
    --help|-h)
      echo "Usage: $0 [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --config-only    Update configuration files only (no package.json merge)"
      echo "  --package-only   Update package.json only (no config files)"
      echo "  --help, -h       Show this help message"
      echo ""
      echo "Examples:"
      echo "  $0               # Full sync (config files + package.json)"
      echo "  $0 --config-only # Update config files only"
      echo "  $0 --package-only # Update package.json only"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo "Use --help for usage information"
      exit 1
      ;;
  esac
done

# Auto-add submodule
if [ ! -d "boilerplate" ]; then
    echo "Boilerplate submodule not found. Adding automatically."
    git submodule add https://github.com/minukHwang/minuk-hwang-boilerplate.git boilerplate
fi

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

echo -e "${YELLOW}🚧 Changes detected in boilerplate.${NC}"

# Update configuration files (only if not --package-only)
if [ "$PACKAGE_ONLY" = false ]; then
    echo -e "${BLUE}📋 Files that will be updated:${NC}"

    # List files that will be copied
    echo "Configuration files:"
    ls -la boilerplate/ | grep -E '\.(json|cjs|rc|ignore)$' || true

    echo -e "\n${YELLOW}🔧 Copying configuration files...${NC}"

    # Copy configuration files (with backup)
    backup_dir=".boilerplate-backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$backup_dir"

    # Pass backup directory path via environment variable
    export BOILERPLATE_BACKUP_DIR="$backup_dir"

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
fi

# Update package.json (only if not --config-only)
if [ "$CONFIG_ONLY" = false ]; then
    # Package.json merge guidance and Node.js script execution
    if [ -f "boilerplate/package.json" ] && [ -f "package.json" ]; then
        echo -e "\n${YELLOW}🚧 You can merge scripts, dependencies, devDependencies, and peerDependencies from boilerplate to package.json.${NC}"
        echo -e "${BLUE}📄 Enter 'n' to see diff only, or 'y' for automatic merge.${NC}"
        read -p "Auto merge (y/n)? " yn
        if [ "$yn" = "y" ]; then
            node ./scripts/merge-package.js
        else
            # Check diff package and execute
            if node -e "require('diff')" &> /dev/null; then
                echo -e "${BLUE}📊 package.json diff (scripts):${NC}"
                node -e "const a=require('./package.json').scripts,b=require('./boilerplate/package.json').scripts;console.log(require('diff').createTwoFilesPatch('package.json','boilerplate/package.json',JSON.stringify(a,null,2),JSON.stringify(b,null,2)));" || true
                echo -e "${BLUE}📊 package.json diff (dependencies):${NC}"
                node -e "const a=require('./package.json').dependencies,b=require('./boilerplate/package.json').dependencies;console.log(require('diff').createTwoFilesPatch('package.json','boilerplate/package.json',JSON.stringify(a,null,2),JSON.stringify(b,null,2)));" || true
                echo -e "${BLUE}📊 package.json diff (devDependencies):${NC}"
                node -e "const a=require('./package.json').devDependencies,b=require('./boilerplate/package.json').devDependencies;console.log(require('diff').createTwoFilesPatch('package.json','boilerplate/package.json',JSON.stringify(a,null,2),JSON.stringify(b,null,2)));" || true
                echo -e "${BLUE}📊 package.json diff (peerDependencies):${NC}"
                node -e "const a=require('./package.json').peerDependencies,b=require('./boilerplate/package.json').peerDependencies;console.log(require('diff').createTwoFilesPatch('package.json','boilerplate/package.json',JSON.stringify(a,null,2),JSON.stringify(b,null,2)));" || true
            else
                echo -e "${YELLOW}🚧 diff package not found. Please compare package.json manually.${NC}"
                echo -e "${BLUE}📄 Please compare boilerplate/package.json and package.json.${NC}"
                echo -e "${BLUE}📄 Or install diff package with 'pnpm add -D diff' and try again.${NC}"
            fi
        fi
    elif [ -f "boilerplate/package.json" ]; then
        echo -e "\n${YELLOW}🚧 package.json not found. Please create package.json first.${NC}"
    else
        echo -e "\n${YELLOW}🚧 boilerplate/package.json not found.${NC}"
    fi
fi

echo -e "\n${GREEN}✅ Boilerplate synchronization completed!${NC}"
if [ "$PACKAGE_ONLY" = false ]; then
    echo -e "${YELLOW}📁 Backup created in: $backup_dir${NC}"
fi
echo -e "${YELLOW}🚧 Please review changes before committing${NC}"
echo -e "${BLUE}💡 Next steps:${NC}"
echo "   1. Review the copied files"
echo "   2. Update package.json if needed"
echo "   3. Test your application"
echo "   4. Commit changes: git add . && git commit -m 'feat: sync with latest boilerplate'"

# Optional: Show git status
echo -e "\n${BLUE}📊 Current git status:${NC}"
git status --porcelain || true 