# km-installer — KISSmetrics install skill for Claude

A Claude skill that installs **KISSmetrics** analytics into your project — on any stack — and
helps you start tracking. You point Claude at your repo, it detects your framework, drops the
KISSmetrics snippet in the right file with your key pre-filled, optionally wires up custom events,
and opens a review branch for your team. Nothing is deployed without your developers' approval.

## What it does

1. **Detects your stack** by reading the repo (Next.js, React, Vue, Angular, Node, PHP/Laravel,
   Django/Flask, Rails, Go, .NET, Elixir, static HTML, WordPress/Shopify themes) — and confirms
   with you when detection is ambiguous.
2. **Installs the snippet** — the hosted KISSmetrics JS SDK — in the correct layout/head file,
   pre-filled with your product key. Page views start tracking automatically; there's no separate
   library to install.
3. **Sets up custom events** (optional) — business actions like *Signed Up* / *Purchased* via the
   `_kmq` API, placed at the right point in your code (idiomatically per stack, with values safely
   escaped).
4. **Opens a `feat/km_snippet` branch** with the changes, committed and ready for your team to
   review and merge. It never merges or deploys on its own.
5. **Helps you verify** — including checking that your product's compiled SDK actually loads, so
   you don't get a silent "installed but no data" failure.

## Install the skill

The skill lives at [`skills/SKILL.md`](skills/SKILL.md). Claude Code loads skills from
`.claude/skills/<name>/SKILL.md`, so copy it into a folder named `km-installer`.

**Option 1 — copy just the skill file (quickest):**
```bash
# into the current project only:
mkdir -p .claude/skills/km-installer
curl -sL https://raw.githubusercontent.com/<your-org>/km-installer/main/skills/SKILL.md \
  -o .claude/skills/km-installer/SKILL.md
```

**Option 2 — clone the repo, then copy in:**
```bash
git clone https://github.com/<your-org>/km-installer.git
# all your projects:
mkdir -p ~/.claude/skills/km-installer
cp km-installer/skills/SKILL.md ~/.claude/skills/km-installer/SKILL.md
# or just this project:
mkdir -p .claude/skills/km-installer
cp km-installer/skills/SKILL.md .claude/skills/km-installer/SKILL.md
```

Then restart Claude Code (or start a new session) so it picks up the skill.

## Use it

From inside your project, just ask Claude:

> Install KISSmetrics in this project

or run the skill directly:

> /km-installer

Have your **KISSmetrics product key** ready (find it in the KISSmetrics dashboard under your
product's tracking settings) — Claude will ask for it first.

## What you'll need

- A KISSmetrics account and **product key**.
- A git repo (so Claude can put the changes on a review branch).
- A few minutes to review the branch and merge it.

## Notes

- The snippet is browser-side, so it works regardless of your backend language — only *where* it
  goes changes per framework.
- For **WordPress** and **Shopify**, the easiest path is usually the official plugin/app rather
  than editing code; Claude will point this out and let you choose.
- Claude always opens a branch for review — your developers approve and merge. It will not deploy.
- No secrets are stored in this repo or the skill: your product key is requested at install time,
  never committed here.
