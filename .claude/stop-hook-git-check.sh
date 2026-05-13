#!/bin/bash
input=$(cat)

stop_hook_active=$(echo "$input" | jq -r '.stop_hook_active')
if [[ "$stop_hook_active" = "true" ]]; then exit 0; fi

if ! git rev-parse --git-dir >/dev/null 2>&1; then exit 0; fi
if [[ -z "$(git remote)" ]]; then exit 0; fi

if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "There are uncommitted changes. Please commit and push these changes to the remote branch." >&2
  exit 2
fi

untracked_files=$(git ls-files --others --exclude-standard)
if [[ -n "$untracked_files" ]]; then
  echo "There are untracked files. Please commit and push these changes to the remote branch." >&2
  exit 2
fi

current_branch=$(git branch --show-current)
if [[ -n "$current_branch" ]]; then
  if git rev-parse "origin/$current_branch" >/dev/null 2>&1; then
    unpushed=$(git rev-list "origin/$current_branch..HEAD" --count 2>/dev/null) || unpushed=0
    if [[ "$unpushed" -gt 0 ]]; then
      echo "There are $unpushed unpushed commit(s) on branch '$current_branch'. Please push." >&2
      exit 2
    fi
  fi
fi

exit 0
