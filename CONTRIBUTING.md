# Contributing to Confucius Debug

> **「不貳過」** — *Never repeat a mistake.* Every contribution makes Confucius stronger for everyone.

Thank you for helping grow the YanHui Knowledge Base! There are many ways to contribute — from sharing bug fixes to improving documentation.

---

## Ways to Contribute

### 1. Share a Bug Fix (Easiest — No Code Required)

Already solved a tough bug? Share it so nobody has to solve it again.

**Via MCP (if you use Claude Code):**
```
Tell Claude: "Use debug_contribute to share my fix"
```

**Via API:**
```bash
curl -s -X POST https://api.washinmura.jp/api/v2/debug-ai/onboard \
  -H "Content-Type: application/json" \
  -d '{
    "lobster_id": "your-name",
    "entries": [{
      "error_description": "What was the bug",
      "fix_description": "How you fixed it",
      "error_category": "config_error"
    }]
  }'
```

**Categories:** `api_error`, `config_error`, `logic_error`, `dependency_error`, `network_error`, `permission_error`, `data_error`, `general`

Your fix goes directly into the YanHui KB and helps every future user.

### 2. Report a Bug or Request a Feature

Use our issue templates:

- [🐛 Bug Report](https://github.com/sstklen/confucius-debug/issues/new?template=bug-report.yml) — Something broken?
- [🤖 AI-Assisted Report](https://github.com/sstklen/confucius-debug/issues/new?template=ai-assisted.yml) — Let AI help you write the report

### 3. Improve Documentation or Code

We welcome PRs for:

- **README / docs improvements** — Typos, clarifications, translations
- **GitHub Action enhancements** — New features, better error handling
- **Skill improvements** — Better prompts, workflow optimizations
- **New integrations** — Support for more CI platforms, IDE plugins

### 4. Bulk Import Your Bug History

Run `debug_hello` to scan your local git history for past bug fixes and bulk-import them to the KB:

```bash
# Via MCP
Tell Claude: "Use debug_hello to onboard my bugs"

# This scans your git log for fix/bug/error commits
# and imports them — you get 10 free credits as thanks!
```

---

## Pull Request Process

### Before You Start

1. Check [existing issues](https://github.com/sstklen/confucius-debug/issues) to avoid duplicating work
2. For significant changes, open an issue first to discuss your approach

### Making a PR

1. **Fork** the repo
2. **Create a branch** from `main`:
   ```bash
   git checkout -b feat/your-feature
   ```
3. **Make your changes** — keep commits focused and atomic
4. **Test locally** if applicable:
   ```bash
   # For GitHub Action changes
   act -j confucius-debug  # or test in a fork

   # For script changes
   bash skills/confucius-debug/scripts/search.sh "test query"
   ```
5. **Submit the PR** with a clear description of what and why

### PR Review

- Small fixes (typos, docs): Usually merged within 24 hours
- Feature PRs: Reviewed within a few days
- The maintainer (tkman) is not an engineer — if you're an engineer and can help review, your expertise is greatly appreciated!

---

## Architecture Overview

Understanding the project structure helps you contribute effectively:

```
confucius-debug (this repo — open source)
├── action.yml          # GitHub Action definition
├── entrypoint.sh       # GitHub Action entrypoint
├── skills/             # OpenClaw Skill definition + shell scripts
│   └── confucius-debug/scripts/  # search.sh, analyze.sh
├── scripts/            # Utilities (social preview generator)
├── .github/            # Issue templates, CI workflows
├── llms.txt            # AI-readable project description
└── README.md

Washin Village API (private — hosted backend)
├── YanHui KB           # Qdrant vector database (6,800+ issues, 980+ solutions)
├── Debug AI Engine     # Claude-powered analysis
├── MCP Server          # Model Context Protocol endpoint
└── Daily Pipeline      # Automated scraping + fixing + replying
```

**Key point:** The "front store" (this repo) is open source. The "back kitchen" (API, DB, AI engine) is hosted by Washin Village. You don't need access to the backend to contribute.

---

## Community Maintainers

We're looking for trusted community maintainers to help with:

- **Issue triage** — Label, reproduce, and prioritize incoming issues
- **PR review** — Review and merge community PRs
- **KB curation** — Help verify and improve solution quality

### How to Apply

1. Be an active contributor (PRs, issues, or KB contributions)
2. Open an issue with the title: `[Maintainer Application] Your Name`
3. Include:
   - Your GitHub username
   - How you use Confucius Debug
   - What area you'd like to help maintain
   - Your lobster_id (if you have one)

Current maintainers are listed in [CODEOWNERS](.github/CODEOWNERS).

---

## Code of Conduct

- Be respectful and constructive
- Help others learn — we're all building something together
- When reporting bugs, include enough context to reproduce
- Credit others' work

---

## Questions?

- Open a [GitHub Issue](https://github.com/sstklen/confucius-debug/issues)
- Check the [README](README.md) for setup and usage details

---

*Built at [Washin Village (和心村)](https://washinmura.jp) — an animal sanctuary in Japan, 28 cats & dogs 🐾*
