<p align="center">
  <h1 align="center">🦞 Confucius Debug — AI Debugging That Never Repeats a Mistake</h1>
  <p align="center"><strong>6,800+ scraped issues · 980+ imported solutions · Search instantly. No match? AI fixes it and saves to KB — next person gets it free.</strong></p>
</p>

<p align="center">
  <a href="https://github.com/sstklen/confucius-debug/actions"><img src="https://img.shields.io/badge/GitHub_Action-Marketplace-2088FF?style=for-the-badge&logo=github-actions&logoColor=white" alt="GitHub Action"/></a>
  <a href="https://github.com/sstklen/confucius-debug/blob/main/LICENSE"><img src="https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge" alt="MIT License"/></a>
  <a href="#mcp-server-recommended"><img src="https://img.shields.io/badge/MCP-Server-brightgreen?style=for-the-badge&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSJ3aGl0ZSI+PHBhdGggZD0iTTEyIDJDNi40OCAyIDIgNi40OCAyIDEyczQuNDggMTAgMTAgMTAgMTAtNC40OCAxMC0xMFMxNy41MiAyIDEyIDJ6bTAgMThjLTQuNDIgMC04LTMuNTgtOC04czMuNTgtOCA4LTggOCAzLjU4IDggOC0zLjU4IDgtOCA4eiIvPjwvc3ZnPg==" alt="MCP Server"/></a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/YanHui_KB-6,800+_issues_·_980+_solutions-blue?style=for-the-badge" alt="6800+ Issues"/>
  <img src="https://img.shields.io/badge/Search-FREE_·_~150ms-green?style=for-the-badge" alt="Search Free"/>
  <img src="https://img.shields.io/badge/AI_Fix-FREE_·_~6s-orange?style=for-the-badge" alt="AI Fix Free"/>
  <img src="https://img.shields.io/badge/Accuracy-9/9_confirmed-brightgreen?style=for-the-badge" alt="9/9 Confirmed"/>
</p>

<p align="center">
  <a href="#mcp-server-recommended"><strong>MCP Server →</strong></a>
  &nbsp;·&nbsp;
  <a href="#github-action"><strong>GitHub Action →</strong></a>
  &nbsp;·&nbsp;
  <a href="#openclaw-skill"><strong>OpenClaw Skill →</strong></a>
  &nbsp;·&nbsp;
  <a href="#rest-api"><strong>REST API →</strong></a>
  &nbsp;·&nbsp;
  <a href="https://github.com/sstklen/confucius-debug/issues/new/choose"><strong>Submit Bug →</strong></a>
</p>

---

## The Philosophy

> **「不貳過」** — *Never repeat a mistake.* (Confucius on his student Yan Hui, Analects 6.3)

[Yan Hui (顏回)](https://en.wikipedia.org/wiki/Yan_Hui) was Confucius's favorite student — praised for never making the same mistake twice. We named our Knowledge Base after him: the **YanHui KB (不貳過知識庫)**.

**Confucius Debug** is the system built on top of it: once a bug is solved, nobody has to solve it again.

---

## How It Works

```
Your AI agent hits a bug
       │
       ▼
  Search YanHui KB ──── Found! → Instant fix (FREE, ~150ms)
       │
       Not found
       ▼
  Confucius AI analyzes (FREE, ~6s)
       │
       ├── High confidence → Fix saved to KB → Next person gets it FREE
       │
       └── Low confidence → "We don't know yet"
                │
                ▼
          debug_escalate → Agent sends environment + logs
                │
                ▼
          Queued for offline research → Solved → Added to KB
```

**Your bugs help everyone. Everyone's bugs help you.**
**Honest when unsure — Confucius never makes up answers.**

---

## What Makes It Different

Most debug tools **wait for you to ask**. Confucius Debug **proactively hunts bugs** — scraping 9 major AI repos daily, fixing them with AI, verifying fixes, and posting solutions on GitHub.

| What we do | Numbers |
|------------|---------|
| Daily automated scraping | 9 repos (OpenClaw, Claude Code, MCP SDK, Anthropic SDK, Aider, Codex...) |
| Issues scraped | **6,800+** from 4 shards |
| Imported solutions | **980+** verified and searchable |
| Platform specialties | **12** (MCP, Telegram, Docker, OpenAI, Ollama, Discord...) |
| Fix quality (A-rate) | **79%** overall (S+A grade) |
| GitHub replies posted | **280** |
| Confirmed correct | **9/9 = 100%** (0 corrections) |
| Notable | OpenClaw creator [verified our fix](https://github.com/openclaw/openclaw/issues/2019) and closed the issue |

**By the time you hit a bug, there's a good chance we already have the fix.**

---

## Install

### MCP Server (Recommended)

For **Claude Code**, **Claude Desktop**, or any MCP-compatible client:

```bash
claude mcp add confucius-debug --transport http https://drclaw.washinmura.jp/mcp/debug -s user
```

Or add to your MCP config:

```json
{
  "mcpServers": {
    "confucius-debug": {
      "url": "https://drclaw.washinmura.jp/mcp/debug"
    }
  }
}
```

Then tell your AI: *"Use debug_hello to set up"* — imports your past bugs and gets you started.

### GitHub Action

```yaml
- name: Confucius Debug AI
  if: failure()
  uses: sstklen/confucius-debug@v2
  with:
    lobster-id: ${{ secrets.CONFUCIUS_LOBSTER_ID }}
```

4 lines. When CI fails, Confucius posts the fix on your PR.

### OpenClaw Skill

```
"Help me install the Confucius Debug skill"
```

See [`skills/confucius-debug/SKILL.md`](skills/confucius-debug/SKILL.md) for full details.

### REST API

```bash
# Search (always free)
curl -X POST https://drclaw.washinmura.jp/api/v2/debug-ai/search \
  -H "Content-Type: application/json" \
  -d '{"query": "Telegram bot 409 Conflict error", "limit": 5}'

# AI analysis (when search returns nothing, free)
curl -X POST https://drclaw.washinmura.jp/api/v2/debug-ai \
  -H "Content-Type: application/json" \
  -d '{"error_description": "...", "lobster_id": "your-id"}'
```

---

## 5 Tools

| Tool | What it does | Cost |
|------|-------------|------|
| `debug_search` | Search YanHui KB for existing solutions | **Free** |
| `debug_analyze` | No match? AI solves it, saves to KB | **Free** |
| `debug_escalate` | Low confidence? Submit environment + logs for offline research | **Free** |
| `debug_contribute` | Share your own solutions back | **Free** |
| `debug_hello` | Scan your bug history, bulk-import to KB | **Free** |

**Workflow:** `debug_hello` (once) → `debug_search` (always) → `debug_analyze` (if needed) → `debug_escalate` (if unsolved)

---

## Platform Coverage

The YanHui KB specializes in AI agent bugs across 12 platforms:

| Platform | Solutions | Quality (A-Rate) |
|----------|-----------|-------------------|
| Anthropic / Claude | 392 | 80% |
| MCP (Model Context Protocol) | 261 | 87% |
| Telegram | 101 | 97% |
| Memory / RAG / Vector DB | 94 | 87% |
| Browser / WebSocket | 73 | 92% |
| OpenAI / GPT | 54 | 87% |
| Docker / K8s | 51 | 84% |
| Discord | 40 | 93% |
| Cron / Scheduler | 37 | 92% |
| WhatsApp | 16 | 94% |
| Google / Gemini | 15 | 100% |
| Ollama / Local LLM | 14 | 93% |

**A-Rate** = percentage of fixes independently verified as correct (S or A grade).

---

## How the KB Grows

An automated pipeline runs daily:

```
scrape (GitHub Issues) → verify → fix (AI analysis)
    → import (vector KB) → reply (GitHub) → track → learn
```

| Stage | What happens |
|-------|-------------|
| **Scrape** | Pull new issues from 9 AI repos |
| **Verify** | Grade existing solutions for quality |
| **Fix** | AI generates fixes for unsolved bugs |
| **Import** | Good fixes go into the YanHui KB (vector database) |
| **Reply** | Post solutions on GitHub with smart filtering |
| **Track** | Monitor community responses |
| **Learn** | Extract lessons from corrections to improve |

The KB grows by ~100 entries per day, automatically.

---

## Pricing

**Everything is free.** Search, analyze, contribute — no cost.

---

## Submit a Bug

Have a bug you can't solve? Three ways to submit:

<p>
  <a href="https://github.com/sstklen/confucius-debug/issues/new?template=bug-report.yml"><img src="https://img.shields.io/badge/📝_For_Humans-Fill_the_form-blue?style=for-the-badge" alt="Submit Bug"/></a>
  &nbsp;
  <a href="https://github.com/sstklen/confucius-debug/issues/new?template=ai-assisted.yml"><img src="https://img.shields.io/badge/🤖_AI_Assisted-Let_AI_help_you-purple?style=for-the-badge" alt="AI Assisted"/></a>
  &nbsp;
  <a href="#for-ai-agents"><img src="https://img.shields.io/badge/🧠_For_AI_Agents-Direct_API/MCP-green?style=for-the-badge" alt="For AI Agents"/></a>
</p>

### Option 1: Fill the form (for humans)

Tell us the error message, platform, and steps to reproduce → [Open form](https://github.com/sstklen/confucius-debug/issues/new?template=bug-report.yml)

### Option 2: AI-assisted (for humans using AI)

Copy the prompt below, paste into your AI (Claude/ChatGPT), answer its questions, then paste the output into our form.

<details>
<summary><b>Copy this prompt</b></summary>

```
I need you to help me create a structured bug report for Confucius Debug (https://github.com/sstklen/confucius-debug).

Ask me these questions one by one:
1. What error message or unexpected behavior did you see? (paste the exact error)
2. What were you trying to do when this happened?
3. What platform/tool is involved? (e.g., Claude Code, MCP, Telegram, Docker, OpenAI, Discord, etc.)
4. What's your environment? (OS, runtime version, tool version)
5. Can you reproduce it? If so, what are the steps?

Then format my answers into this markdown template:

### Error Message
[exact error]

### What I Was Doing
[context]

### Platform
[platform name]

### Environment
- OS: [os]
- Runtime: [version]
- Tool: [version]

### Steps to Reproduce
1. [step]
2. [step]

### Additional Context
[anything else relevant]
```

</details>

### Option 3: For AI Agents (they find us on their own)

**AI agents discover Confucius Debug organically and submit bugs without human involvement.**

```
How AI agents find us:

GitHub Issues ─── We already reply on 9 major repos (280+ replies)
    │              → AI agents see our fixes → follow the link → connect
    │
OpenClaw ──────── Confucius Debug Skill in the Skill Library
    │              → Agents install the skill → start submitting
    │
MCP Directory ─── Listed as MCP Server
    │              → Claude Code / Desktop users add it → agent uses it
    │
AI Crawlers ───── GPTBot, ClaudeBot read our llms.txt + README
                   → When users ask "debug tools for CI" → we show up
```

**Once connected, the agent works autonomously:**

```
Agent hits a bug
    ↓
debug_search → KB has a fix? → Use it! (instant)
    ↓ no match
debug_analyze → AI generates a fix
    ├── High confidence → Saved to KB ✅
    └── Low confidence → status: "unsolved"
         ↓
    debug_escalate → Agent sends environment + logs
         ↓
    Queued for offline research → solved → added to KB
    ↓
Agent solves a bug on its own?
    ↓
debug_contribute → Shares fix back → KB grows
```

**Every agent that connects makes the KB stronger. Every KB entry helps every other agent.**

#### Connect via MCP (Claude Code / Claude Desktop)

```json
{
  "mcpServers": {
    "confucius-debug": {
      "url": "https://drclaw.washinmura.jp/mcp/debug"
    }
  }
}
```

#### Connect via REST API (any AI agent)

```bash
# Search KB (always try first)
curl -s -X POST https://drclaw.washinmura.jp/api/v2/debug-ai/search \
  -H "Content-Type: application/json" \
  -d '{"query": "your error message here", "limit": 5}'

# AI analysis (if search found nothing)
curl -s -X POST https://drclaw.washinmura.jp/api/v2/debug-ai \
  -H "Content-Type: application/json" \
  -d '{"error_description": "what happened", "error_message": "exact error", "lobster_id": "your-agent-name"}'

# Escalate (if analyze returned "unsolved" — provide environment info)
curl -s -X POST https://drclaw.washinmura.jp/api/v2/debug-ai/escalate \
  -H "Content-Type: application/json" \
  -d '{"error_description": "the unsolved bug", "lobster_id": "your-agent-name",
       "environment": {"os": "macOS", "runtime": "bun 1.2"}, "logs": "error output...",
       "tried": ["restarted", "cleared cache"]}'

# Contribute back (if agent solved it)
curl -s -X POST https://drclaw.washinmura.jp/api/v2/debug-ai/onboard \
  -H "Content-Type: application/json" \
  -d '{"lobster_id": "your-agent-name", "entries": [{"error_description": "the bug", "fix_description": "how you fixed it"}]}'
```

#### Connect via OpenClaw Skill

```
"Help me install the Confucius Debug skill"
```

**The flywheel:** We post fixes on GitHub → AI agents see them → agents connect → agents contribute bugs → KB grows → we post more fixes → more agents find us → **repeat**.

---

<details>
<summary><b>GitHub Action — Full Setup Guide</b></summary>

### Quick Start (2 minutes)

#### 1. Get a free Lobster ID

```bash
claude mcp add confucius-debug --transport http https://drclaw.washinmura.jp/mcp/debug -s user
```
Tell Claude: *"Use debug_hello to onboard"* — it scans your past bugs and imports them.

#### 2. Add to GitHub Secrets

Repo → `Settings` → `Secrets` → Add `CONFUCIUS_LOBSTER_ID`

#### 3. Add to workflow

```yaml
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

      - name: Confucius Debug AI
        if: steps.build.outcome == 'failure'
        uses: sstklen/confucius-debug@v2
        with:
          lobster-id: ${{ secrets.CONFUCIUS_LOBSTER_ID }}

      - name: Fail if build failed
        if: steps.build.outcome == 'failure'
        run: exit 1
```

### Inputs

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `lobster-id` | Yes | - | Your Lobster ID |
| `error-log` | No | auto-capture | Custom error text |
| `comment` | No | `true` | Post fix as PR comment |
| `language` | No | `en` | Response language (en/zh/ja) |

### Outputs

| Output | Description |
|--------|-------------|
| `status` | `knowledge_hit`, `analyzed`, `unsolved`, or `error` |
| `fix` | Full JSON response with fix details |
| `source` | `knowledge_base`, `sonnet`, or `opus` |
| `cost` | Cost in USD (always 0 — everything is free) |

</details>

<details>
<summary><b>Security & Privacy</b></summary>

### What leaves your machine
Only the error description and error message you provide. The GitHub Action also sends CI metadata (repo name, branch, runner OS) for context. No source code, no file contents, no secret environment variables.

### What's stored
Error descriptions and fixes in the YanHui KB. No PII beyond your chosen lobster-id.

### Automatic redaction
API keys, tokens, and passwords are filtered before sending.

### Data retention
Contributions are permanent — that's the point. Never repeat a mistake.

</details>

---

## Maintainer Note

> Hi, I'm **tkman** — the creator of Confucius Debug. I'm **not an engineer**. I built this entire project with AI, and I'll do my best to maintain it. If you find a bug, please report it — I'll try my hardest to fix it. If you're an engineer and know how to help, **PRs are very welcome**. Let's make Confucius better together. 🙏

---

## Related Projects

| Project | What it does |
|---------|-------------|
| [112 Claude Code Skills](https://github.com/sstklen/washin-claude-skills) | Battle-tested coding patterns |
| [Zero Engineer](https://github.com/sstklen/zero-engineer) | How a non-engineer built all of this with AI |

---

<p align="center">
  <b>「不遷怒，不貳過。」</b><br>
  <i>"Never redirect anger, never repeat a mistake."</i><br><br>
  Built at <a href="https://washinmura.jp">Washin Village (和心村)</a> — an animal sanctuary in Japan, 28 cats & dogs 🐾<br>
  Powered by Claude (Anthropic) + the Confucius philosophy.<br><br>
  🦞 <i>The bigger the Knowledge Base, the stronger Confucius becomes.</i>
</p>
