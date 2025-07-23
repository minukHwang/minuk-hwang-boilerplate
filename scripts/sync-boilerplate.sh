#!/bin/bash

# Boilerplate Synchronization Script (git diff/merge, auto file discovery, with options)
# Supports: --all-merge, --file <filename>, --help

set -e

# --- Option parsing ---
ALL_MERGE=false
ONLY_FILE=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --all-merge)
      ALL_MERGE=true
      shift
      ;;
    --file)
      ONLY_FILE="$2"
      shift 2
      ;;
    --help|-h)
      echo "Usage: $0 [--all-merge] [--file <filename>]"
      echo "  --all-merge         Merge/copy all files without prompts."
      echo "  --file <filename>   Only sync/merge the specified file or directory."
      echo "  --help, -h          Show this help message."
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo "Use --help for usage information."
      exit 1
      ;;
  esac
done

# Auto-add submodule if not present
if [ ! -d "boilerplate" ]; then
    echo "Boilerplate submodule not found. Adding automatically."
    git submodule add https://github.com/minukHwang/minuk-hwang-boilerplate.git boilerplate
fi

echo "🔄 Starting boilerplate synchronization (git diff/merge)..."

# Output color variables
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

# Update boilerplate submodule to latest commit
echo -e "${BLUE}📥 Updating boilerplate submodule...${NC}"
git submodule update --remote boilerplate

# --- Root files sync/merge ---
for file in $(ls -A boilerplate); do
    if [ -f "boilerplate/$file" ]; then
        # --file 옵션 처리
        if [ -n "$ONLY_FILE" ] && [ "$file" != "$ONLY_FILE" ]; then
            continue
        fi
        if [ -f "$file" ]; then
            # Check for diff
            git diff --no-index --quiet "boilerplate/$file" "$file"
            if [ $? -eq 0 ]; then
                echo -e "${YELLOW}⏭️ $file: no changes, skipping.${NC}"
                continue
            fi
            echo -e "${BLUE}📝 $file diff:${NC}"
            git diff --no-index "boilerplate/$file" "$file" || true
            if [ "$ALL_MERGE" = true ]; then
                git merge-file "$file" "$file" "boilerplate/$file"
                echo -e "${GREEN}🔀 $file merged!${NC}"
                echo -e "${YELLOW}🚧 If there are conflicts, please resolve the conflict markers manually.${NC}"
            else
                read -p "🤔 merge? (y/n): " yn
                if [ "$yn" = "y" ]; then
                    git merge-file "$file" "$file" "boilerplate/$file"
                    echo -e "${GREEN}🔀 $file merged!${NC}"
                    echo -e "${YELLOW}🚧 If there are conflicts, please resolve the conflict markers manually.${NC}"
                else
                    echo -e "${YELLOW}⏭️ $file skipped${NC}"
                fi
            fi
        else
            # Always prompt before copying, even with --all-merge
            read -p "🆕 copy $file from boilerplate? (y/n): " yn
            if [ "$yn" = "y" ]; then
                cp "boilerplate/$file" .
                echo -e "${GREEN}🆕 $file copied from boilerplate${NC}"
            else
                echo -e "${YELLOW}⏭️ $file copy skipped${NC}"
            fi
        fi
    fi
    # Files only in your project but not in boilerplate are warned below
    # (see below)
done

# --- Directory sync/merge (from boilerplate-sync-dirs.txt) ---
sync_dirs=()
if [ -f "scripts/boilerplate-sync-dirs.txt" ]; then
  while IFS= read -r line; do
    [[ -z "$line" || "$line" =~ ^# ]] && continue
    sync_dirs+=("$line")
  done < scripts/boilerplate-sync-dirs.txt
fi

for dir in "${sync_dirs[@]}"; do
  if [ -d "boilerplate/$dir" ]; then
    # --file 옵션 처리 (디렉토리 이름이 정확히 일치할 때만)
    if [ -n "$ONLY_FILE" ] && [ "$dir" != "$ONLY_FILE" ]; then
      continue
    fi
    echo -e "\n${BLUE}🔄 Syncing $dir directory...${NC}"
    mkdir -p "$dir"
    for file in $(ls -A "boilerplate/$dir"); do
      if [ -f "boilerplate/$dir/$file" ]; then
        if [ -f "$dir/$file" ]; then
          # Check for diff
          git diff --no-index --quiet "boilerplate/$dir/$file" "$dir/$file"
          if [ $? -eq 0 ]; then
            echo -e "${YELLOW}⏭️ $dir/$file: no changes, skipping.${NC}"
            continue
          fi
          echo -e "${BLUE}📝 $dir/$file diff:${NC}"
          git diff --no-index "boilerplate/$dir/$file" "$dir/$file" || true
          if [ "$ALL_MERGE" = true ]; then
            git merge-file "$dir/$file" "$dir/$file" "boilerplate/$dir/$file"
            echo -e "${GREEN}🔀 $dir/$file merged!${NC}"
            echo -e "${YELLOW}🚧 If there are conflicts, please resolve the conflict markers manually.${NC}"
          else
            read -p "🤔 merge $dir/$file? (y/n): " yn
            if [ "$yn" = "y" ]; then
              git merge-file "$dir/$file" "$dir/$file" "boilerplate/$dir/$file"
              echo -e "${GREEN}🔀 $dir/$file merged!${NC}"
              echo -e "${YELLOW}🚧 If there are conflicts, please resolve the conflict markers manually.${NC}"
            else
              echo -e "${YELLOW}⏭️ $dir/$file skipped${NC}"
            fi
          fi
        else
          # Always prompt before copying, even with --all-merge
          read -p "🆕 copy $dir/$file from boilerplate? (y/n): " yn
          if [ "$yn" = "y" ]; then
            cp "boilerplate/$dir/$file" "$dir/"
            echo -e "${GREEN}🆕 $dir/$file copied from boilerplate${NC}"
          else
            echo -e "${YELLOW}⏭️ $dir/$file copy skipped${NC}"
          fi
        fi
      fi
    done
  fi
done

# Warn about config files that exist in your project but not in boilerplate
extra_files=()
for file in $(ls -A); do
    if [ -f "$file" ] && [ ! -f "boilerplate/$file" ]; then
        # Only warn for config files (filter by extension/name as needed)
        case "$file" in
            .gitignore|commitlint.config.cjs|.eslintrc.json|.prettierrc|.prettierignore|.eslintignore|tsconfig.json|next.config.mjs|package.json)
                extra_files+=("$file")
                ;;
        esac
    fi
done
if [ ${#extra_files[@]} -gt 0 ]; then
    echo -e "\n${YELLOW}🚧 There are config files in your project that do not exist in boilerplate:${NC}"
    for file in "${extra_files[@]}"; do
        echo "  - $file"
    done
    echo -e "${YELLOW}These files are not synced with boilerplate. Add them to boilerplate or manage them manually if needed.${NC}"
fi

echo -e "\n${GREEN}✅ Boilerplate git diff/merge sync complete!${NC}"
echo -e "${YELLOW}💾 Please git add/commit the changed/merged files.${NC}"
echo -e "${BLUE}💡 Next steps:${NC}"
echo "   1. 🚧 If there are conflicts, resolve them manually."
echo "   2. 💾 git add . && git commit -m 'chore: merge boilerplate config files'"
echo "   3. 🚀 Test and create a PR"

read -p "💾 Do you want to git add/commit/push the changes now? (y/n): " yn
echo ""
if [ "$yn" = "y" ]; then
  echo -e "${GREEN}▶️ Run the following commands to commit and push your changes:${NC}"
  echo "git add ."
  echo "git commit -m 'chore: merge boilerplate config files'"
  echo "git push"
else
  echo -e "${YELLOW}⏭️ Skipped git commit/push.${NC}"
fi 