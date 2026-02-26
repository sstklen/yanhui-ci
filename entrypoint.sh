#!/bin/bash
# Confucius Debug AI — GitHub Action Entrypoint
# "不貳過 — Never repeat a mistake"
#
# Flow:
# 1. Capture error from CI logs or user input
# 2. Sanitize sensitive data (API keys, passwords, tokens)
# 3. Send to Confucius API (KB search → AI analysis fallback)
# 4. Output fix suggestion
# 5. Optionally comment on PR (with dedup)

set -euo pipefail

# ============================================
# 0. Helpers
# ============================================

# Strip potential secrets from error text
sanitize_secrets() {
  sed -E \
    -e 's/(api[_-]?key|apikey|secret|token|password|passwd|pwd|auth)(["\x27: =]+)[^ "\x27,}{)]+/\1\2***REDACTED***/gi' \
    -e 's/ghp_[A-Za-z0-9]{36}/ghp_***REDACTED***/g' \
    -e 's/gho_[A-Za-z0-9]{36}/gho_***REDACTED***/g' \
    -e 's/sk-[A-Za-z0-9]{20,}/sk-***REDACTED***/g' \
    -e 's/Bearer [A-Za-z0-9._-]+/Bearer ***REDACTED***/g' \
    -e 's/[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z]{2,}/***EMAIL***/gi'
}

# Mask ID for logging (show last 4 chars only)
mask_id() {
  local id="$1"
  local len=${#id}
  if [ "$len" -le 4 ]; then
    echo "****"
  else
    echo "****${id: -4}"
  fi
}

# ============================================
# 1. Capture Error
# ============================================

ERROR_TEXT="${ERROR_LOG:-}"

if [ -z "$ERROR_TEXT" ]; then
  echo "::group::Capturing CI error logs"

  # Check common log file locations
  for LOG_FILE in /tmp/build-error.log /tmp/test-output.log /tmp/ci-error.log /tmp/lint-output.log; do
    if [ -f "$LOG_FILE" ] && [ -s "$LOG_FILE" ]; then
      ERROR_TEXT=$(tail -50 "$LOG_FILE" 2>/dev/null || true)
      if [ -n "$ERROR_TEXT" ]; then
        echo "Found error log: $LOG_FILE"
        break
      fi
    fi
  done

  # Fallback: try GitHub API to identify the failed step
  if [ -z "$ERROR_TEXT" ]; then
    echo "::warning::No error log file found. Trying GitHub API..."

    if [ -n "${GITHUB_TOKEN:-}" ] && [ -n "${GITHUB_RUN_ID:-}" ]; then
      FAILED_LOG=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
        "https://api.github.com/repos/$GITHUB_REPOSITORY/actions/runs/$GITHUB_RUN_ID/jobs" \
        2>/dev/null | python3 -c "
import sys, json
try:
    jobs = json.load(sys.stdin).get('jobs', [])
    for job in jobs:
        for step in job.get('steps', []):
            if step.get('conclusion') == 'failure':
                print(f\"Step '{step['name']}' failed in job '{job['name']}'\")
except: pass
" 2>/dev/null || true)

      if [ -n "$FAILED_LOG" ]; then
        ERROR_TEXT="CI Failure: $FAILED_LOG"
      fi
    fi
  fi

  if [ -z "$ERROR_TEXT" ]; then
    echo "::error::Could not capture error. Please provide error text via 'error-log' input."
    echo "::error::Example: pipe your build output to a file with '2>&1 | tee /tmp/build-error.log'"
    echo "status=error" >> "$GITHUB_OUTPUT"
    echo "fix=" >> "$GITHUB_OUTPUT"
    exit 0  # Don't fail the workflow
  fi

  echo "::endgroup::"
fi

# Sanitize secrets before sending
ERROR_TEXT=$(echo "$ERROR_TEXT" | sanitize_secrets)

# Truncate to 2000 chars on a line boundary
ERROR_TEXT=$(echo "$ERROR_TEXT" | head -c 2000 | head -n -0)

echo "::group::Sending to Confucius Debug AI"
echo "Error length: ${#ERROR_TEXT} chars"
echo "Lobster ID: $(mask_id "$LOBSTER_ID")"

# ============================================
# 2. Call Confucius API
# ============================================

# Extract structured error message from the log text
ERROR_DESC="$ERROR_TEXT"
ERROR_MSG=""

# Match common error patterns across languages/tools
EXTRACTED_MSG=$(echo "$ERROR_TEXT" | grep -iE \
  "^(Error|TypeError|ReferenceError|SyntaxError|RangeError|URIError|fatal|FAIL|FAILED|panic|exception|AssertionError|ModuleNotFoundError|ImportError|NameError|ValueError|KeyError|AttributeError|RuntimeError|OSError|IOError|CompilationError|BuildError|npm ERR!|error\[E[0-9]+\]|error TS[0-9]+)" \
  | tail -1 || true)
if [ -n "$EXTRACTED_MSG" ]; then
  ERROR_MSG="$EXTRACTED_MSG"
fi

# Build JSON payload safely via environment variables
export ERROR_DESC ERROR_MSG
PAYLOAD=$(python3 -c "
import json, os
print(json.dumps({
    'lobster_id': os.environ['LOBSTER_ID'],
    'error_description': os.environ.get('ERROR_DESC', '')[:1000],
    'error_message': os.environ.get('ERROR_MSG', '')[:500],
    'language': os.environ.get('LANGUAGE', 'en'),
    'environment': {
        'source': 'github_action',
        'repo': os.environ.get('GITHUB_REPOSITORY', ''),
        'ref': os.environ.get('GITHUB_REF', ''),
        'sha': os.environ.get('GITHUB_SHA', '')[:8],
        'runner': os.environ.get('RUNNER_OS', ''),
        'workflow': os.environ.get('GITHUB_WORKFLOW', ''),
    }
}))
" 2>/dev/null)

# Call the API
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_URL" \
  -H "Content-Type: application/json" \
  -H "User-Agent: Confucius-Debug/2.0" \
  -d "$PAYLOAD" \
  --max-time 30 \
  2>/dev/null || echo -e "\n000")

HTTP_CODE=$(echo "$RESPONSE" | tail -1)
BODY=$(echo "$RESPONSE" | sed '$d')

echo "API response: HTTP $HTTP_CODE"
echo "::endgroup::"

# ============================================
# 3. Parse Response & Set Outputs
# ============================================

if [ "$HTTP_CODE" -ge 200 ] && [ "$HTTP_CODE" -lt 300 ]; then
  # 解析 API 回傳（安全方式：寫入暫存檔，避免 eval 注入風險）
  export PARSE_FILE=$(mktemp)
  echo "$BODY" | python3 -c "
import sys, json, shlex, os
try:
    d = json.load(sys.stdin)
    r = d.get('result', {})
    y = d.get('yanhui', {})
    fields = {
        'STATUS': d.get('status', 'unknown'),
        'SOURCE': d.get('source', 'unknown'),
        'COST': str(d.get('cost', 0)),
        'ENTRY_ID': str(d.get('entry_id', '')),
        'FIX_DESC': r.get('fix_description', ''),
        'FIX_PATCH': r.get('fix_patch', ''),
        'ROOT_CAUSE': r.get('root_cause', ''),
        'CATEGORY': r.get('category', ''),
        'ATTRIBUTION': y.get('attribution', ''),
    }
    # 寫入暫存檔（用 shlex.quote 確保安全），避免直接 eval API 回傳
    with open(os.environ['PARSE_FILE'], 'w') as f:
        for k, v in fields.items():
            f.write(f'{k}={shlex.quote(v)}\n')
except Exception:
    with open(os.environ['PARSE_FILE'], 'w') as f:
        f.write("STATUS='unknown'\nSOURCE='unknown'\nCOST='0'\nENTRY_ID=''\nFIX_DESC=''\nFIX_PATCH=''\nROOT_CAUSE=''\nCATEGORY=''\nATTRIBUTION=''\n")
" 2>/dev/null
  # 驗證暫存檔只包含合法的 shell 變數賦值
  if grep -qvE '^[A-Z_]+=' "$PARSE_FILE" 2>/dev/null; then
    echo "::warning::Unexpected content in parsed response, using defaults"
    STATUS='unknown'; SOURCE='unknown'; COST='0'; ENTRY_ID=''; FIX_DESC=''; FIX_PATCH=''; ROOT_CAUSE=''; CATEGORY=''; ATTRIBUTION=''
  else
    source "$PARSE_FILE"
  fi
  rm -f "$PARSE_FILE"

  # Set outputs
  echo "status=$STATUS" >> "$GITHUB_OUTPUT"
  echo "source=$SOURCE" >> "$GITHUB_OUTPUT"
  echo "cost=$COST" >> "$GITHUB_OUTPUT"
  echo "entry_id=$ENTRY_ID" >> "$GITHUB_OUTPUT"

  # Multi-line output for fix (unique delimiter)
  EOF_MARKER="CONFUCIUS_EOF_$$"
  {
    echo "fix<<$EOF_MARKER"
    echo "$BODY"
    echo "$EOF_MARKER"
  } >> "$GITHUB_OUTPUT"

  # ============================================
  # 4. Display Results
  # ============================================

  if [ "$STATUS" = "knowledge_hit" ]; then
    echo ""
    echo "::notice::🦞 Confucius: YanHui KB Hit! (cost: \$$COST)"
    echo ""
    echo "============================================"
    echo "  Source: $SOURCE"
    echo "  Root Cause: $ROOT_CAUSE"
    echo "  Category: $CATEGORY"
    echo ""
    echo "  Fix: $FIX_DESC"
    echo ""
    if [ -n "$FIX_PATCH" ]; then
      echo "  Patch:"
      echo "  $FIX_PATCH"
      echo ""
    fi
    echo "  $ATTRIBUTION"
    echo "============================================"
    echo ""
  elif [ "$STATUS" = "analyzed" ]; then
    echo ""
    echo "::notice::🦞 Confucius: New Analysis Complete (cost: \$$COST)"
    echo ""
    echo "============================================"
    echo "  Source: $SOURCE"
    echo "  Root Cause: $ROOT_CAUSE"
    echo "  Category: $CATEGORY"
    echo ""
    echo "  Fix: $FIX_DESC"
    echo ""
    if [ -n "$FIX_PATCH" ]; then
      echo "  Patch:"
      echo "  $FIX_PATCH"
      echo ""
    fi
    echo "  $ATTRIBUTION"
    echo "  (Saved to YanHui KB — next time anyone hits this, instant fix!)"
    echo "============================================"
    echo ""
  elif [ "$STATUS" = "rejected" ]; then
    echo ""
    echo "::warning::Confucius: This doesn't look like a bug. Please provide actual error messages."
    echo ""
  else
    echo ""
    echo "::warning::Confucius returned unexpected status: $STATUS"
    echo ""
  fi

  # ============================================
  # 5. Comment on PR (if enabled, with dedup)
  # ============================================

  if [ "$COMMENT" = "true" ] && [ -n "${GITHUB_TOKEN:-}" ] && [ -n "$FIX_DESC" ]; then
    # Find associated PR
    PR_NUMBER=""
    if [ -n "${GITHUB_EVENT_PATH:-}" ]; then
      PR_NUMBER=$(python3 -c "
import json, os
try:
    with open(os.environ['GITHUB_EVENT_PATH']) as f:
        event = json.load(f)
    pr = event.get('pull_request', {}).get('number', '')
    if not pr:
        pr = event.get('number', '')
    print(pr)
except: print('')
" 2>/dev/null || true)
    fi

    if [ -n "$PR_NUMBER" ] && [ "$PR_NUMBER" != "0" ]; then
      echo "::group::Posting comment on PR #$PR_NUMBER"

      # Check for existing comment (dedup) — supports both old and new markers
      EXISTING_COMMENT_ID=$(curl -s \
        -H "Authorization: token $GITHUB_TOKEN" \
        "https://api.github.com/repos/$GITHUB_REPOSITORY/issues/$PR_NUMBER/comments?per_page=100" \
        2>/dev/null | python3 -c "
import sys, json
try:
    comments = json.load(sys.stdin)
    for c in comments:
        body = c.get('body', '')
        if '## :lobster: Confucius Debug' in body or '## :lobster: YanHui Debug AI' in body:
            print(c['id'])
            break
except: pass
" 2>/dev/null || true)

      # Build markdown comment safely via environment variables
      export STATUS SOURCE COST ENTRY_ID ROOT_CAUSE FIX_DESC FIX_PATCH CATEGORY ATTRIBUTION
      COMMENT_BODY=$(python3 -c "
import json, os

status = os.environ.get('STATUS', '')
source = os.environ.get('SOURCE', '')
cost = os.environ.get('COST', '0')
entry_id = os.environ.get('ENTRY_ID', '')
root_cause = os.environ.get('ROOT_CAUSE', '')
fix_desc = os.environ.get('FIX_DESC', '')
fix_patch = os.environ.get('FIX_PATCH', '')
category = os.environ.get('CATEGORY', '')
attribution = os.environ.get('ATTRIBUTION', '')

speed = 'Instant KB hit!' if status == 'knowledge_hit' else 'Fresh analysis'

lines = []
lines.append('## :lobster: Confucius Debug')
lines.append('')
lines.append(f'**{speed}** | Source: \`{source}\` | Cost: \${cost}')
lines.append('')
lines.append('### Root Cause')
lines.append(root_cause)
lines.append('')
lines.append('### Fix')
lines.append(fix_desc)
if fix_patch.strip():
    lines.append('')
    lines.append('### Suggested Patch')
    lines.append('\`\`\`')
    lines.append(fix_patch)
    lines.append('\`\`\`')
lines.append('')
lines.append(f'> {attribution}')
if entry_id:
    lines.append(f'> Entry #{entry_id} | Category: {category}')
lines.append('')
lines.append('---')
lines.append('*Powered by [Confucius Debug](https://github.com/sstklen/confucius-debug) — never repeat a mistake 🦞*')

print(json.dumps({'body': chr(10).join(lines)}))
" 2>/dev/null)

      if [ -n "$COMMENT_BODY" ]; then
        if [ -n "$EXISTING_COMMENT_ID" ]; then
          # Update existing comment (dedup)
          curl -s -X PATCH \
            -H "Authorization: token $GITHUB_TOKEN" \
            -H "Content-Type: application/json" \
            "https://api.github.com/repos/$GITHUB_REPOSITORY/issues/comments/$EXISTING_COMMENT_ID" \
            -d "$COMMENT_BODY" > /dev/null 2>&1 || true
          echo "Updated existing comment on PR #$PR_NUMBER"
        else
          # Create new comment
          curl -s -X POST \
            -H "Authorization: token $GITHUB_TOKEN" \
            -H "Content-Type: application/json" \
            "https://api.github.com/repos/$GITHUB_REPOSITORY/issues/$PR_NUMBER/comments" \
            -d "$COMMENT_BODY" > /dev/null 2>&1 || true
          echo "Posted new comment on PR #$PR_NUMBER"
        fi
      fi

      echo "::endgroup::"
    fi
  fi

else
  # API error
  echo "::warning::Confucius API returned HTTP $HTTP_CODE"
  echo "status=error" >> "$GITHUB_OUTPUT"
  echo "fix=" >> "$GITHUB_OUTPUT"

  ERROR_MSG_API=$(echo "$BODY" | python3 -c "import sys,json; print(json.load(sys.stdin).get('error','Unknown error'))" 2>/dev/null || echo "Unknown error")
  echo "::warning::$ERROR_MSG_API"

  # Show helpful hints for common errors
  if [ "$HTTP_CODE" = "402" ]; then
    HINT=$(echo "$BODY" | python3 -c "import sys,json; print(json.load(sys.stdin).get('hint',''))" 2>/dev/null || echo "")
    echo ""
    echo "::error::Insufficient balance. Get credits via: claude mcp add confucius-debug --transport http https://api.washinmura.jp/mcp/debug"
    if [ -n "$HINT" ]; then
      echo "::error::$HINT"
    fi
    echo "::error::Or use debug_search (free) to check if this bug is already in the KB."
  elif [ "$HTTP_CODE" = "429" ]; then
    echo ""
    echo "::warning::Rate limited. Wait a moment and retry."
  elif [ "$HTTP_CODE" = "000" ]; then
    echo ""
    echo "::error::Could not reach Confucius API. Check your network or try again later."
  fi
fi

echo ""
echo "Done. Learn more: https://github.com/sstklen/confucius-debug"
