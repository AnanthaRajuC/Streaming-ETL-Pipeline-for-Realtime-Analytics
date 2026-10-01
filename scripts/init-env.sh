#!/bin/bash
# Creates .env from .env.example on first run, filling every empty
# *_PASSWORD with a random value. An existing .env is left untouched.
set -euo pipefail
cd "$(dirname "$0")/.."

if [[ -f .env ]]; then
  exit 0
fi

random_password() {
  head -c 16 /dev/urandom | od -An -tx1 | tr -d ' \n'
}

while IFS= read -r line || [[ -n "$line" ]]; do
  if [[ "$line" =~ ^([A-Z_]+_PASSWORD)=$ ]]; then
    echo "${BASH_REMATCH[1]}=$(random_password)"
  else
    echo "$line"
  fi
done < .env.example > .env
chmod 600 .env
echo "Created .env with generated passwords (see .env.example)."
