#!/usr/bin/env bash
# Refuse rules inputs that could become extra CLI arguments.
#
# A docker:// step passes `args:` to the container as one string that is split
# on whitespace, so a value such as "r.json --api-base-url=https://x/api/v2"
# would become flags; CLI flags override QUANT_API_TOKEN/QUANT_BASE_URL and
# could send the portal token to another host. Values reach this script only
# through the environment, never through the command line.
set -euo pipefail

fail() { echo "::error::$1"; exit 1; }

path_ok() { [[ "$1" =~ ^[A-Za-z0-9_./][A-Za-z0-9_./-]*$ ]]; }
slug_ok() { [[ "$1" =~ ^[A-Za-z0-9][A-Za-z0-9_-]*$ ]]; }

path_ok "${RULES:-}" || fail "rules must be a plain file path (letters, digits, '.', '_', '-', '/'), not '${RULES:-}'."
if [ -n "${FUNCTIONS:-}" ]; then
  path_ok "$FUNCTIONS" || fail "functions must be a plain file path when rules is set."
fi
slug_ok "${CUSTOMER:-}" || fail "customer must be an organisation slug when rules is set."
slug_ok "${PROJECT:-}" || fail "project must be a project machine name when rules is set."
[[ "${RULES_FORCE:-false}" =~ ^(true|false)$ ]] || fail "rules-force must be true or false."
[ -n "${API_TOKEN:-}" ] || fail "rules requires api-token (the project-scoped QUANT_API_TOKEN), never the content token."
[ -n "${API_BASE_URL:-}" ] || fail "rules requires api-base-url (the portal /api/v2 URL, QUANT_BASE_URL)."
echo "Rules inputs validated."
