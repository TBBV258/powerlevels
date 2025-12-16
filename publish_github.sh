#!/usr/bin/env bash
# publish_github.sh
# Usage: set GITHUB_TOKEN and GITHUB_USER env vars, then run:
#   REPO_NAME=Powerlevel ./publish_github.sh
# This script will create a GitHub repository under your user account and push the current directory.

set -euo pipefail

REPO_NAME=${REPO_NAME:-Powerlevel}
GITHUB_USER=${GITHUB_USER:-}
GITHUB_TOKEN=${GITHUB_TOKEN:-}
VISIBILITY=${VISIBILITY:-public} # or 'private'

if [ -z "$GITHUB_USER" ]; then
  echo "Error: GITHUB_USER env var is required."
  exit 1
fi
if [ -z "$GITHUB_TOKEN" ]; then
  echo "Error: GITHUB_TOKEN env var is required."
  exit 1
fi

API_URL="https://api.github.com/user/repos"

echo "Creating GitHub repo '$REPO_NAME' for user '$GITHUB_USER'..."
create_resp=$(curl -s -o /dev/stderr -w "%{http_code}" -X POST -H "Authorization: token $GITHUB_TOKEN" -d "{\"name\": \"$REPO_NAME\", \"private\": $( [ "$VISIBILITY" = "private" ] && echo true || echo false ) }" $API_URL) || true

# Note: curl writes response body to stderr above; check exit code/status
# If the repo already exists, we will continue to push.

# Initialize local git repo if needed
if [ ! -d .git ]; then
  echo "Initializing git repository..."
  git init
fi

git add --all
if git rev-parse --verify HEAD >/dev/null 2>&1; then
  git commit -m "chore: initial commit" || true
else
  git commit -m "chore: initial commit" || true
fi

# Create remote using token in URL (note: this exposes token in process list briefly)
REMOTE_URL="https://$GITHUB_TOKEN@github.com/$GITHUB_USER/$REPO_NAME.git"

echo "Adding remote origin and pushing..."

# Create remote if not exists
if git remote | grep origin >/dev/null 2>&1; then
  git remote remove origin || true
fi

git remote add origin "$REMOTE_URL"
# Ensure main branch exists
if git show-ref --verify --quiet refs/heads/main; then
  git branch -M main
else
  git checkout -b main
fi

echo "Pushing to GitHub (this will push all commits)..."
GIT_TERMINAL_PROMPT=0 git push -u origin main --force

echo "Repository pushed: https://github.com/$GITHUB_USER/$REPO_NAME"

echo "IMPORTANT: For security, remove the token from any URLs and avoid committing it."

echo "Done."