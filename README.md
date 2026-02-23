<p align="center">
  <h1 align="center">YanHui Debug AI</h1>
  <p align="center"><strong>CI fails? Get the fix in 4ms — not 20 minutes.</strong></p>
  <p align="center">A GitHub Action that checks 200+ known bugs instantly, or has AI analyze new ones.</p>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/KB_Hit-$0.02_·_4ms-green?style=for-the-badge" alt="KB Hit"/>
  <img src="https://img.shields.io/badge/New_Analysis-$0.05_·_6s-blue?style=for-the-badge" alt="New Analysis"/>
  <img src="https://img.shields.io/badge/Setup-2_minutes-orange?style=for-the-badge" alt="Setup"/>
</p>

<p align="center">
  <a href="https://github.com/sstklen/yanhui-ci/stargazers"><img src="https://img.shields.io/github/stars/sstklen/yanhui-ci?style=social" alt="Stars"/></a>
  &nbsp;
  <a href="https://github.com/marketplace/actions/yanhui-debug-ai"><strong>Get it on Marketplace →</strong></a>
</p>

---

## The Problem

Your CI fails. You open the log. Scroll through 200 lines. Google the error. Read 3 Stack Overflow answers. Try a fix. Push. Wait 5 minutes for CI. Still broken.

**Total time: 20-40 minutes.** And someone on another team already solved this exact bug last week.

## The Fix

```yaml
- name: YanHui Debug AI
  if: failure()
  uses: sstklen/yanhui-ci@v1
  with:
    claw-id: ${{ secrets.YANHUI_CLAW_ID }}
```

That's it. 4 lines. When CI fails:

```
1. YanHui checks 200+ known bugs         →  4ms, $0.02
2. Not found? Claude Sonnet analyzes it   →  6s,  $0.05
3. Fix posted as PR comment               →  automatic
4. Solution saved to KB for everyone      →  next person gets instant fix
```

---

## Before vs After

**Without YanHui:**
```
CI fails → open logs → Google error → try fix → push → wait → still broken → repeat
⏱️ 20-40 minutes per failure
```

**With YanHui:**
```
CI fails → YanHui finds fix in KB → posts on PR → you copy-paste the fix
⏱️ 4 milliseconds (KB hit) or 6 seconds (new analysis)
```

---

## Quick Start (2 minutes)

### 1. Get a free Claw ID

Add YanHui MCP to Claude Code:
```bash
claude mcp add yanhui-debug --transport http https://api.washinmura.jp/mcp/debug -s user
```
Then tell Claude: *"Use debug_hello to onboard"* — you get **10 free credits**.

### 2. Add to GitHub Secrets

Go to your repo → `Settings` → `Secrets` → Add `YANHUI_CLAW_ID`

### 3. Add to your workflow

```yaml
# .github/workflows/ci.yml
name: CI
on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Build
        id: build
        run: npm run build 2>&1 | tee /tmp/build-error.log
        continue-on-error: true

      - name: YanHui Debug AI
        if: steps.build.outcome == 'failure'
        uses: sstklen/yanhui-ci@v1
        with:
          claw-id: ${{ secrets.YANHUI_CLAW_ID }}

      - name: Fail if build failed
        if: steps.build.outcome == 'failure'
        run: exit 1
```

Done. Next time CI fails, YanHui posts the fix on your PR.

---

## How the Shared KB Works

This is the key insight: **every bug solved by any user makes YanHui smarter for everyone.**

```
Day 1:   Dev A hits "ENOENT" error  → Sonnet analyzes ($0.05) → Fix saved to KB
Day 2:   Dev B hits same error      → KB hit ($0.02, 4ms)     → Instant fix!
Day 30:  Dev C hits similar error   → KB hit ($0.02, 4ms)     → Instant fix!
Day 100: 200+ bugs in KB            → Most CI failures = instant fix
```

The more people use it, the cheaper and faster it gets. Your bugs help everyone. Everyone's bugs help you.

---

## Pricing

| Scenario | Cost | Speed |
|----------|------|-------|
| **KB hit** (someone solved this before) | $0.02 | ~4ms |
| **New analysis** (Claude Sonnet) | $0.05 | ~6s |
| **New analysis** (Claude Opus) | $0.07 | ~8s |
| **Search only** | Free | ~150ms |

> Most CI errors are variations of the same ~50 problems. After a few weeks, 80%+ of your failures will be KB hits at $0.02.

---

<details>
<summary><b>More examples: tests, custom errors, PR comments</b></summary>

### With test errors

```yaml
      - name: Run tests
        id: test
        run: npm test 2>&1 | tee /tmp/test-output.log
        continue-on-error: true

      - name: YanHui Debug AI
        if: steps.test.outcome == 'failure'
        uses: sstklen/yanhui-ci@v1
        with:
          claw-id: ${{ secrets.YANHUI_CLAW_ID }}
          # Auto-detects /tmp/test-output.log — no config needed!
```

### With custom error text

```yaml
      - name: Build
        id: build
        run: npm run build 2>&1 | tee /tmp/build.log
        continue-on-error: true

      - name: Capture error
        if: steps.build.outcome == 'failure'
        id: capture
        run: |
          ERROR=$(tail -50 /tmp/build.log)
          echo "error<<EOF" >> $GITHUB_OUTPUT
          echo "$ERROR" >> $GITHUB_OUTPUT
          echo "EOF" >> $GITHUB_OUTPUT

      - name: YanHui Debug AI
        if: steps.build.outcome == 'failure'
        uses: sstklen/yanhui-ci@v1
        with:
          claw-id: ${{ secrets.YANHUI_CLAW_ID }}
          error-log: ${{ steps.capture.outputs.error }}
```

### With PR comments (enabled by default)

```yaml
      - name: YanHui Debug AI
        if: failure()
        uses: sstklen/yanhui-ci@v1
        with:
          claw-id: ${{ secrets.YANHUI_CLAW_ID }}
          comment: 'true'  # Posts fix as PR comment (updates on re-run)
```

### Use outputs in subsequent steps

```yaml
      - name: YanHui Debug AI
        id: yanhui
        if: failure()
        uses: sstklen/yanhui-ci@v1
        with:
          claw-id: ${{ secrets.YANHUI_CLAW_ID }}

      - name: Check if KB hit
        if: steps.yanhui.outputs.status == 'knowledge_hit'
        run: echo "Found in KB! This bug was solved before."
```

</details>

<details>
<summary><b>Inputs & Outputs reference</b></summary>

### Inputs

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `claw-id` | Yes | - | Your Claw ID for billing |
| `error-log` | No | auto-capture | Custom error text |
| `auto-fix` | No | `false` | Create PR with fix (coming soon) |
| `comment` | No | `true` | Post fix as PR comment |
| `api-url` | No | production | Custom API endpoint |
| `language` | No | `en` | Response language (en/zh/ja) |
| `github-token` | No | `github.token` | Token for PR comments |

### Outputs

| Output | Description |
|--------|-------------|
| `status` | `knowledge_hit`, `analyzed`, or `error` |
| `fix` | Full JSON response with fix details |
| `source` | `knowledge_base`, `sonnet_4.6`, or `opus_local` |
| `cost` | Cost in USD |
| `entry-id` | KB entry ID (for feedback) |

### Auto-detected log files

YanHui auto-captures errors from these locations (no config needed):

| File | When to use |
|------|-------------|
| `/tmp/build-error.log` | `npm run build 2>&1 \| tee /tmp/build-error.log` |
| `/tmp/test-output.log` | `npm test 2>&1 \| tee /tmp/test-output.log` |
| `/tmp/ci-error.log` | General CI errors |
| `/tmp/lint-output.log` | Linter output |

Or use the `error-log` input for full control.

</details>

<details>
<summary><b>Security & Privacy</b></summary>

- **Secret filtering**: API keys, tokens, passwords, and emails are automatically redacted before sending
- **No source code**: Only error messages and stack traces are sent
- **Claw ID masking**: Your Claw ID is never printed in CI logs
- **Minimal data**: Only the last 50 lines of error output are captured
- **Your Claw ID** is used only for billing

</details>

---

## Why "YanHui"?

Named after [Yan Hui (顏回)](https://en.wikipedia.org/wiki/Yan_Hui), Confucius's favorite student — famous for **never making the same mistake twice**. That's exactly what this tool does: once a bug is solved, nobody has to solve it again.

---

<p align="center">
  <sub>
    Built at <a href="https://washinmura.jp">Washin Village</a> — an animal sanctuary in Japan building AI tools for developers.
  </sub>
</p>
