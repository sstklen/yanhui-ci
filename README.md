<p align="center">
  <h1 align="center">🦞 YanHui — The Never-Repeat Knowledge Base</h1>
  <p align="center"><strong>AI's shared mistake notebook — every bug solved once, never repeated.</strong></p>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Knowledge_Base-4,300+_Solutions-blue?style=for-the-badge" alt="4300+ Solutions"/>
  <img src="https://img.shields.io/badge/KB_Hit-$0.02_·_4ms-green?style=for-the-badge" alt="KB Hit"/>
  <img src="https://img.shields.io/badge/New_Fix-$0.05_·_6s-orange?style=for-the-badge" alt="New Fix"/>
</p>

<p align="center">
  <a href="https://github.com/sstklen/yanhui-ci/stargazers"><img src="https://img.shields.io/github/stars/sstklen/yanhui-ci?style=social" alt="Stars"/></a>
  &nbsp;
  <a href="https://github.com/marketplace/actions/yanhui-debug-ai"><strong>GitHub Action →</strong></a>
  &nbsp;·&nbsp;
  <a href="#mcp-server"><strong>MCP Server →</strong></a>
</p>

---

## The Name

[Yan Hui (顏回)](https://en.wikipedia.org/wiki/Yan_Hui) was Confucius's favorite student. His master praised him: **「不遷怒，不貳過」** — *"Never redirect anger, never repeat a mistake."*

We turned that into a product: **once a bug is solved, nobody has to solve it again.**

---

## How It Works

```
Your AI agent hits a bug
     │
     ▼
Search KB ──── Found! → Instant fix ($0.02, ~4ms)
     │
     Not found
     ▼
AI analyzes & solves ($0.05, ~6s) → Saved to KB → Next time = instant
```

The more people use it, the bigger the KB gets, the more bugs are instant fixes.

**Your bugs help everyone. Everyone's bugs help you.**

---

## What Makes YanHui Different

Most debug tools **wait for you to ask**. YanHui **proactively hunts bugs** across the open-source ecosystem — solving them before you even hit them.

The Knowledge Base doesn't just grow from user queries. It grows continuously from the open-source community. By the time you encounter a bug, there's a good chance YanHui already has the fix.

**4,300+ verified solutions and growing daily.**

---

## Install

### MCP Server (for Claude Code / AI Agents) {#mcp-server}

```bash
claude mcp add yanhui-debug --transport http https://api.washinmura.jp/mcp/debug -s user
```

Then tell Claude: *"Use debug_hello to set up"* — you get **10 free credits**.

### GitHub Action (for CI/CD)

```yaml
- name: YanHui Debug AI
  if: failure()
  uses: sstklen/yanhui-ci@v1
  with:
    claw-id: ${{ secrets.YANHUI_CLAW_ID }}
```

4 lines. When CI fails, YanHui posts the fix on your PR.

---

## 4 Tools (MCP Protocol)

| Tool | What it does | Cost |
|------|-------------|------|
| `debug_hello` | Scan your bug history, bulk-import to KB | Free + 10 credits |
| `debug_search` | Search KB for existing solutions | Free |
| `debug_analyze` | No match? AI solves it, saves to KB | $0.05 |
| `debug_contribute` | Share your own solutions back | Free |

**Workflow:** `debug_hello` (once) → `debug_search` (always free) → `debug_analyze` (only if needed)

---

## Pricing

| Scenario | Cost | Speed |
|----------|------|-------|
| **KB hit** (already solved) | $0.02 | ~4ms |
| **New analysis** (Sonnet) | $0.05 | ~6s |
| **New analysis** (Opus) | $0.07 | ~8s |
| **Search only** | Free | ~150ms |

> **Free to start.** 10 credits on signup = 500 free debug sessions at $0.02 each.

**Contributors earn back.** Your solutions get cited by others → you earn per citation. The more you help, the more you earn.

---

## The Flywheel

```
More bugs solved → KB grows → hit rate ↑ → cost ↓ → more users → more contributions → 🔄
```

YanHui gets **better** over time, not worse. Every fix makes it smarter for everyone.

---

<details>
<summary><b>GitHub Action — Full Setup Guide</b></summary>

### Quick Start (2 minutes)

#### 1. Get a free Claw ID

```bash
claude mcp add yanhui-debug --transport http https://api.washinmura.jp/mcp/debug -s user
```
Tell Claude: *"Use debug_hello to onboard"* → 10 free credits.

#### 2. Add to GitHub Secrets

Repo → `Settings` → `Secrets` → Add `YANHUI_CLAW_ID`

#### 3. Add to workflow

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

### Inputs

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `claw-id` | Yes | - | Your Claw ID |
| `error-log` | No | auto-capture | Custom error text |
| `comment` | No | `true` | Post fix as PR comment |
| `language` | No | `en` | Response language (en/zh/ja) |

### Outputs

| Output | Description |
|--------|-------------|
| `status` | `knowledge_hit`, `analyzed`, or `error` |
| `fix` | Full JSON response with fix details |
| `source` | `knowledge_base`, `sonnet_4.6`, or `opus_local` |
| `cost` | Cost in USD |

</details>

<details>
<summary><b>Security & Privacy</b></summary>

- **Zero privacy risk** — only stores error messages and fixes, never source code or secrets
- **Automatic redaction** — API keys, tokens, passwords filtered before sending
- **Minimal data** — only last 50 lines of error output captured

</details>

---

## Related Projects

| Project | What it does |
|---------|-------------|
| [112 Claude Code Skills](https://github.com/sstklen/washin-claude-skills) | Battle-tested code patterns — YanHui's companion |
| [crawl-share](https://github.com/sstklen/crawl-share) | Community web intelligence — same philosophy |
| [Zero Engineer](https://github.com/sstklen/zero-engineer) | The full story behind all of this |

---

<p align="center">
  <i>「不遷怒，不貳過。」</i><br>
  <i>"Never repeat a mistake."</i><br><br>
  <sub>Built at <a href="https://washinmura.jp">Washin Village</a> (和心村) — an animal sanctuary in Japan, 28 cats & dogs 🐾</sub>
</p>
