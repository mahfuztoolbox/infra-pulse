#!/usr/bin/env bash
# Deploy public portfolio to GitHub as mahfuztoolbox ONLY (no Cursor co-author).
#
# Why contributor was dmahfuzd70 before:
#   git user.email was dmahfuzd@gmail.com → GitHub maps that to dmahfuzd70
# This script always commits as mahfuztoolbox noreply email.
#
# Usage:
#   cd infra-pulse
#   ./deploy-github.sh --init
#   ./deploy-github.sh
#   ./deploy-github.sh "Update static UI"
#   ./deploy-github.sh --sync
#   ./deploy-github.sh --dry-run
#
# Repo: https://github.com/mahfuztoolbox/infra-pulse

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PRIVATE_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
REMOTE_URL="${INFRA_PULSE_REMOTE:-https://github.com/mahfuztoolbox/infra-pulse.git}"
BRANCH="${INFRA_PULSE_BRANCH:-main}"

# Must match the GitHub account that owns the repo (mahfuztoolbox)
GIT_AUTHOR_NAME="${INFRA_PULSE_GIT_NAME:-mahfuztoolbox}"
GIT_AUTHOR_EMAIL="${INFRA_PULSE_GIT_EMAIL:-291569830+mahfuztoolbox@users.noreply.github.com}"

MSG=""
SYNC=0
DRY_RUN=0
DO_INIT=0

for arg in "$@"; do
  case "$arg" in
    --sync) SYNC=1 ;;
    --dry-run) DRY_RUN=1 ;;
    --init) DO_INIT=1 ;;
    -h|--help)
      sed -n '2,18p' "$0"
      exit 0
      ;;
    *)
      if [[ -z "$MSG" ]]; then
        MSG="$arg"
      else
        echo "ERROR: unexpected arg: $arg" >&2
        exit 1
      fi
      ;;
  esac
done

if [[ -z "$MSG" ]]; then
  MSG="Update Infra Pulse portfolio"
fi

cd "${SCRIPT_DIR}"

if [[ -d api && -d web && -d scripts ]]; then
  echo "ERROR: refuse to deploy from private project root. Stay inside infra-pulse/." >&2
  exit 1
fi

if [[ ! -d .git ]]; then
  if [[ "${DO_INIT}" -eq 1 ]]; then
    git init
    git branch -M "${BRANCH}"
    echo "Initialized new git repo in ${SCRIPT_DIR}"
  else
    echo "ERROR: no .git here. Run:  ./deploy-github.sh --init"
    exit 1
  fi
fi

# Ensure this folder is its own repo (not parent applicationflux)
TOP="$(git rev-parse --show-toplevel)"
if [[ "${TOP}" != "${SCRIPT_DIR}" ]]; then
  echo "ERROR: git toplevel is ${TOP}"
  echo "This folder must have its own .git. Run: rm -rf .git; ./deploy-github.sh --init"
  exit 1
fi

if ! git remote get-url origin >/dev/null 2>&1; then
  git remote add origin "${REMOTE_URL}"
else
  current_remote="$(git remote get-url origin)"
  if [[ "${current_remote}" != *"infra-pulse"* ]]; then
    echo "ERROR: origin is '${current_remote}' (expected infra-pulse)." >&2
    exit 1
  fi
fi

if [[ "${SYNC}" -eq 1 ]]; then
  src_arch="${PRIVATE_ROOT}/docs/images/architecture.png"
  dst_arch="${SCRIPT_DIR}/images/architecture.png"
  if [[ -f "${src_arch}" ]]; then
    mkdir -p "$(dirname "${dst_arch}")"
    cp -f "${src_arch}" "${dst_arch}"
    echo "Synced architecture.png"
  else
    echo "WARN: ${src_arch} not found — skip sync"
  fi
fi

git add README.md index.html .gitignore deploy-github.sh images docs 2>/dev/null || \
git add README.md index.html .gitignore deploy-github.sh images
# Drop obsolete HTML readme if it still exists in git history / working tree
git rm -f --ignore-unmatch readme.html 2>/dev/null || true

if git diff --cached --quiet; then
  echo "No changes to deploy."
  git status -sb
  exit 0
fi

echo "Staged changes:"
git diff --cached --stat
echo
echo "Commit author will be: ${GIT_AUTHOR_NAME} <${GIT_AUTHOR_EMAIL}>"
echo "(This maps to GitHub user mahfuztoolbox — NOT dmahfuzd70, NOT Cursor)"

if [[ "${DRY_RUN}" -eq 1 ]]; then
  echo "Dry run — not committing or pushing."
  exit 0
fi

# Explicit author/committer every time — never inherit dmahfuzd@gmail.com / Cursor.
# Use commit-tree so IDE hooks cannot inject "Co-authored-by: Cursor".
export GIT_AUTHOR_NAME GIT_AUTHOR_EMAIL
export GIT_COMMITTER_NAME="${GIT_AUTHOR_NAME}"
export GIT_COMMITTER_EMAIL="${GIT_AUTHOR_EMAIL}"

TREE="$(git write-tree)"
PARENTS=()
if git rev-parse --verify HEAD >/dev/null 2>&1; then
  PARENTS=(-p HEAD)
fi
NEW_COMMIT="$(printf '%s\n' "${MSG}" | git commit-tree "${TREE}" "${PARENTS[@]}")"
git reset --hard "${NEW_COMMIT}"
git branch -M "${BRANCH}"
git push -u origin "${BRANCH}"

echo
echo "Deployed: ${REMOTE_URL} (${BRANCH})"
echo "Check contributor (should be only mahfuztoolbox):"
echo "  https://github.com/mahfuztoolbox/infra-pulse"
echo
git log -1 --format='Latest: %h | %an <%ae> | %s'
