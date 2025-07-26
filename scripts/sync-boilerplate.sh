#!/bin/bash

# Boilerplate Synchronization Script (git diff/merge, recursive, with options)
# Supports: --all-merge, --file <filename>, --help

set -e

# --- Log function ---
log() {
  echo -e "\033[1;36m[LOG]\033[0m $1"
}

# --- Change tracking flag ---
has_changes=false

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

# --- Read ignore directories ---
ignore_dirs=()
if [ -f "scripts/boilerplate-ignore-dirs.txt" ]; then
  while IFS= read -r line || [ -n "$line" ]; do
    line=$(echo "$line" | xargs)
    [[ -z "$line" || "$line" =~ ^# ]] && continue
    ignore_dirs+=("$line")
  done < scripts/boilerplate-ignore-dirs.txt
else
  ignore_dirs=(".git")
fi

# --- Helper: check if directory is ignored ---
is_ignored_dir() {
  local d="$1"
  for ig in "${ignore_dirs[@]}"; do
    if [[ "$d" == "$ig" ]]; then
      return 0
    fi
  done
  return 1
}



# Output color variables
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Auto-add submodule if not present
if [ ! -d "boilerplate" ]; then
    log "Boilerplate submodule not found. Adding automatically."
    git submodule add https://github.com/minukHwang/minuk-hwang-boilerplate.git boilerplate
fi

log "🔄 Starting boilerplate synchronization (git diff/merge)..."

# Check if boilerplate submodule exists (after auto-add attempt)
if [ ! -d "boilerplate" ]; then
    echo -e "${RED}❌ Boilerplate submodule not found!${NC}"
    echo -e "${YELLOW}💡 To add boilerplate as submodule, run:${NC}"
    echo "   git submodule add <boilerplate-repo-url> boilerplate"
    exit 1
fi

log "📥 Updating boilerplate submodule..."
git submodule update --remote boilerplate

# --- Pre-sync: Check for diffs in scripts directory and prompt for merge/copy/skip ---
pre_sync_changes=false
if [ -d "boilerplate/scripts" ]; then
  # Store find results in array to avoid pipe issues (macOS compatible)
  script_files=()
  while IFS= read -r -d '' file; do
    script_files+=("$file")
  done < <(find "boilerplate/scripts" -type f -print0)
  
  for src_file in "${script_files[@]}"; do
    relpath="${src_file#boilerplate/scripts/}"
    dest_file="scripts/$relpath"
    
    # Check if this file should be ignored
    if is_ignored_dir "scripts/$relpath"; then
      echo -e "${PURPLE}⏭️  Ignored${YELLOW}: scripts/$relpath skipping${NC}"
      continue
    fi
    
    if [ -f "$dest_file" ]; then
      # Check for diff using cmp (content only, ignores permissions)
      if ! cmp -s "$src_file" "$dest_file" 2>/dev/null; then
        echo -e "${YELLOW}⚠️ scripts/$relpath has changes between boilerplate and your project.${NC}"
        echo -e "${BLUE}📝 scripts/$relpath diff:${NC}"
        git --no-pager diff --no-index --color=always "$src_file" "$dest_file" || true
        echo -e "${BLUE}🤔 Merge this ${CYAN}scripts/$relpath${BLUE}? (y/n): "
        read -p "" yn
        if [ "$yn" = "y" ]; then
          git merge-file "$dest_file" "$dest_file" "$src_file"
          echo -e "${GREEN}🔀 scripts/$relpath merged!${NC}"
          echo -e "${YELLOW}🚧 If there are conflicts, please resolve the conflict markers manually.${NC}"
          has_changes=true
          pre_sync_changes=true
          
          # If sync-boilerplate.sh was merged, exit immediately
          if [ "$relpath" = "sync-boilerplate.sh" ]; then
            echo -e "\n${YELLOW}⚠️ sync-boilerplate.sh was updated. Please re-run the script to continue with the latest version.${NC}"
            exit 0
          fi
        else
          echo -e "${YELLOW}⏭️ scripts/$relpath skipped${NC}"
        fi
      fi
    else
      echo -e "${BLUE}🆕 Copy this ${CYAN}scripts/$relpath${BLUE}? (y/n): "
      read -p "" yn
      if [ "$yn" = "y" ]; then
        mkdir -p "$(dirname "$dest_file")"
        cp "$src_file" "$dest_file"
        echo -e "${GREEN}🆕 scripts/$relpath copied from boilerplate${NC}"
        has_changes=true
        pre_sync_changes=true
        
        # If sync-boilerplate.sh was copied, exit immediately
        if [ "$relpath" = "sync-boilerplate.sh" ]; then
          echo -e "\n${YELLOW}⚠️ sync-boilerplate.sh was copied. Please re-run the script to continue with the latest version.${NC}"
          exit 0
        fi
      else
        echo -e "${YELLOW}⏭️ scripts/$relpath copy skipped${NC}"
      fi
    fi
  done
fi
if $pre_sync_changes; then
  echo -e "\n${YELLOW}⚠️ Some files in scripts/ were merged or copied. Please re-run the sync script to ensure everything is up-to-date.${NC}"
  exit 0
fi

# --- Root files sync/merge ---
for file in $(ls -A boilerplate); do
    # Skip directories that are in ignore_dirs
    if [ -d "boilerplate/$file" ] && is_ignored_dir "$file"; then
        echo -e "${PURPLE}⏭️  Ignored${YELLOW}: $file skipping${NC}"
        continue
    fi
    # Skip files that are in ignore_dirs
    if [ -f "boilerplate/$file" ] && is_ignored_dir "$file"; then
        echo -e "${PURPLE}⏭️  Ignored${YELLOW}: $file skipping${NC}"
        continue
    fi
    if [ -f "boilerplate/$file" ]; then
        # --file option
        if [ -n "$ONLY_FILE" ] && [ "$file" != "$ONLY_FILE" ]; then
            continue
        fi
        if [ -f "$file" ]; then
          # Check for diff using cmp (content only, ignores permissions)
          if cmp -s "boilerplate/$file" "$file" 2>/dev/null; then
            echo -e "${GREEN}⏭️  No Changes${YELLOW}: $file skipping${NC}"
            continue
          fi
          echo -e "${BLUE}📝 $file diff:${NC}"
          git --no-pager diff --no-index --color=always "boilerplate/$file" "$file" | grep -v "^old mode\|^new mode" || true
          if [ "$ALL_MERGE" = true ]; then
            git merge-file "$file" "$file" "boilerplate/$file"
            echo -e "${GREEN}🔀 $file merged!${NC}"
            echo -e "${YELLOW}🚧 If there are conflicts, please resolve the conflict markers manually.${NC}"
            has_changes=true
          else
            echo -e "${BLUE}🤔 Merge this ${CYAN}$file${BLUE}? (y/n): "
            read -p "" yn
            if [ "$yn" = "y" ]; then
              git merge-file "$file" "$file" "boilerplate/$file"
              echo -e "${GREEN}🔀 $file merged!${NC}"
              echo -e "${YELLOW}🚧 If there are conflicts, please resolve the conflict markers manually.${NC}"
              has_changes=true
            else
              echo -e "${YELLOW}⏭️ $file skipped${NC}"
            fi
          fi
        else
          # Always prompt before copying, even with --all-merge
          echo -e "${BLUE}🆕 Copy this ${CYAN}$file${BLUE}? (y/n): "
          read -p "" yn
          if [ "$yn" = "y" ]; then
            cp "boilerplate/$file" .
            echo -e "${GREEN}🆕 $file copied from boilerplate${NC}"
            has_changes=true
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
  while IFS= read -r line || [ -n "$line" ]; do
    line=$(echo "$line" | xargs) # trim leading/trailing whitespace
    [[ -z "$line" || "$line" =~ ^# ]] && continue
    sync_dirs+=("$line")
  done < scripts/boilerplate-sync-dirs.txt
fi

for dir in "${sync_dirs[@]}"; do
  if [ -d "boilerplate/$dir" ]; then
    if is_ignored_dir "$dir"; then
      echo -e "${PURPLE}⏭️  Ignored${YELLOW}: $dir skipping${NC}"
      continue
    fi
    # --file option (directory or specific file)
    if [ -n "$ONLY_FILE" ]; then
      if [[ "$ONLY_FILE" == "$dir" ]]; then
        # Sync entire directory (fall through)
          :
      elif [[ "$ONLY_FILE" == $dir/* ]]; then
        # Sync only a specific file inside the directory (recursive support)
        target_file="${ONLY_FILE#*/}"
        if [ -f "boilerplate/$dir/$target_file" ]; then
          echo -e "${BLUE}📝 $dir/$target_file diff:${NC}"
          git --no-pager diff --no-index --color=always "boilerplate/$dir/$target_file" "$dir/$target_file" | grep -v "^old mode\|^new mode" || true
          if [ "$ALL_MERGE" = true ]; then
            git merge-file "$dir/$target_file" "$dir/$target_file" "boilerplate/$dir/$target_file"
            echo -e "${GREEN}🔀 $dir/$target_file merged!${NC}"
            echo -e "${YELLOW}🚧 If there are conflicts, please resolve the conflict markers manually.${NC}"
            has_changes=true
          else
            echo -e "${BLUE}🤔 Merge this ${CYAN}$dir/$target_file${BLUE}? (y/n): "
            read -p "" yn
            if [ "$yn" = "y" ]; then
              git merge-file "$dir/$target_file" "$dir/$target_file" "boilerplate/$dir/$target_file"
              echo -e "${GREEN}🔀 $dir/$target_file merged!${NC}"
              echo -e "${YELLOW}🚧 If there are conflicts, please resolve the conflict markers manually.${NC}"
              has_changes=true
            else
              echo -e "${YELLOW}⏭️ $dir/$target_file skipped${NC}"
            fi
          fi
        else
          echo -e "${BLUE}🆕 Copy this ${CYAN}$dir/$target_file${BLUE}? (y/n): "
          read -p "" yn
          if [ "$yn" = "y" ]; then
            mkdir -p "$(dirname "$dir/$target_file")"
            cp "boilerplate/$dir/$target_file" "$dir/$target_file"
            echo -e "${GREEN}🆕 $dir/$target_file copied from boilerplate${NC}"
            has_changes=true
          else
            echo -e "${YELLOW}⏭️ $dir/$target_file copy skipped${NC}"
          fi
        fi
        continue
      else
        continue
      fi
    fi
    log "🔄 Syncing $dir directory..."
    # Recursively sync all files (find)
    find "boilerplate/$dir" -type f | while read src_file; do
      relpath="${src_file#boilerplate/$dir/}"
      # Skip files/dirs in ignore_dirs
      skip=false
      for ig in "${ignore_dirs[@]}"; do
        case "$relpath" in
          $ig/*) skip=true; break;;
        esac
      done
      if $skip; then
        echo -e "${PURPLE}⏭️  Ignored${YELLOW}: $dir/$relpath skipping${NC}"
        continue
      fi
      dest_file="$dir/$relpath"
      mkdir -p "$(dirname "$dest_file")"
      if [ -f "$dest_file" ]; then
        # Check for diff using cmp (content only, ignores permissions)
        if cmp -s "$src_file" "$dest_file" 2>/dev/null; then
          echo -e "${GREEN}⏭️  No Changes${YELLOW}: $dir/$relpath skipping${NC}"
          continue
        fi
        echo -e "${BLUE}📝 $dir/$relpath diff:${NC}"
        git --no-pager diff --no-index --color=always "$src_file" "$dest_file" | grep -v "^old mode\|^new mode" || true
        if [ "$ALL_MERGE" = true ]; then
          git merge-file "$dest_file" "$dest_file" "$src_file"
          echo -e "${GREEN}🔀 $dir/$relpath merged!${NC}"
          echo -e "${YELLOW}🚧 If there are conflicts, please resolve the conflict markers manually.${NC}"
          has_changes=true
        else
          echo -e "${BLUE}🤔 Merge this ${CYAN}$dir/$relpath${BLUE}? (y/n): "
          read -p "" yn
          if [ "$yn" = "y" ]; then
            git merge-file "$dest_file" "$dest_file" "$src_file"
            echo -e "${GREEN}🔀 $dir/$relpath merged!${NC}"
            echo -e "${YELLOW}🚧 If there are conflicts, please resolve the conflict markers manually.${NC}"
            has_changes=true
          else
            echo -e "${YELLOW}⏭️ $dir/$relpath skipped${NC}"
          fi
        fi
      else
        echo -e "${BLUE}🆕 Copy this ${CYAN}$dir/$relpath${BLUE}? (y/n): "
        read -p "" yn
        if [ "$yn" = "y" ]; then
          cp "$src_file" "$dest_file"
          echo -e "${GREEN}🆕 $dir/$relpath copied from boilerplate${NC}"
          has_changes=true
        else
          echo -e "${YELLOW}⏭️ $dir/$relpath copy skipped${NC}"
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


if [ "$has_changes" = true ]; then
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
else
  echo -e "\n${BLUE}✅ Boilerplate sync complete! No changes were made. Everything is up to date!${NC}"
fi 