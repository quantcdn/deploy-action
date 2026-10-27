#!/usr/bin/env bash
# Refuse kv-indexes inputs that could become extra CLI arguments.
#
# The same reason as validate-rules-inputs.sh: a docker:// step splits `args:`
# on whitespace, so a value with a space could become a flag that overrides
# QUANT_API_TOKEN/QUANT_BASE_URL. Values reach this script only through the
# environment, never through the command line.
set -euo pipefail

fail() { echo "::error::$1"; exit 1; }

path_ok() { [[ "$1" =~ ^[A-Za-z0-9_./][A-Za-z0-9_./-]*$ ]]; }
slug_ok() { [[ "$1" =~ ^[A-Za-z0-9][A-Za-z0-9_-]*$ ]]; }

path_ok "${KV_INDEXES:-}" || fail "kv-indexes must be a plain file path (letters, digits, '.', '_', '-', '/'), not '${KV_INDEXES:-}'."
slug_ok "${CUSTOMER:-}" || fail "customer must be an organisation slug when kv-indexes is set."
slug_ok "${PROJECT:-}" || fail "project must be a project machine name when kv-indexes is set."
[ -n "${API_TOKEN:-}" ] || fail "kv-indexes requires api-token (the project-scoped QUANT_API_TOKEN with kv:read and kv:write), never the content token."
[ -n "${API_BASE_URL:-}" ] || fail "kv-indexes requires api-base-url (the portal /api/v2 URL, QUANT_BASE_URL)."
echo "KV index inputs validated."
