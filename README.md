# km-installer — KISSmetrics Installation Skill for Claude

A Claude skill that installs **KISSmetrics** analytics into your project on virtually any stack and helps you start tracking immediately.

Point Claude at your repository, and it will detect your framework, add the KISSmetrics snippet in the correct location with your product key pre-filled, optionally wire up custom events, and create a review branch for your team. Nothing is deployed without developer approval.

## What It Does

### 1. Detects Your Stack

Claude analyzes your repository to identify the framework or platform you're using, including:

* Next.js
* React
* Vue
* Angular
* Node.js
* PHP / Laravel
* Django / Flask
* Ruby on Rails
* Go
* .NET
* Elixir
* WordPress
* Shopify themes

If detection is unclear, Claude asks for confirmation before making any changes.

### 2. Installs the KISSmetrics Snippet

Claude adds the hosted KISSmetrics JavaScript SDK to the appropriate layout or head file and pre-fills it with your product key.

Page views begin tracking automatically. No additional package installation is required.

### 3. Sets Up Custom Events (Optional)

Claude can also add business-specific tracking events such as:

* Signed Up
* Purchased
* Started Trial
* Completed Onboarding

Events are implemented using the `_kmq` API and inserted at the appropriate location in your codebase using conventions that match your framework. Event values are safely escaped and handled correctly.

### 4. Creates a Review Branch

Claude creates a `feat/km_snippet` branch containing all changes, commits them, and leaves everything ready for review.

It never merges, deploys, or modifies production systems on its own.

### 5. Helps You Verify the Installation

Claude guides you through validating the setup, including confirming that your product's compiled SDK loads correctly so you avoid "installed but no data" issues.

## Installing the Skill

The skill is located at `skills/SKILL.md`.

Claude Code loads skills from `.claude/skills/<name>/SKILL.md`, so copy the file into a folder named `km-installer`.

### Option 1: Copy Only the Skill File

For the current project:

```bash
mkdir -p .claude/skills/km-installer
curl -sL https://raw.githubusercontent.com/kissmetrics/km-installer/main/skills/SKILL.md \
  -o .claude/skills/km-installer/SKILL.md
```

### Option 2: Clone the Repository First

```bash
git clone https://github.com/kissmetrics/km-installer.git

# Install for all projects
mkdir -p ~/.claude/skills/km-installer
cp km-installer/skills/SKILL.md ~/.claude/skills/km-installer/SKILL.md

# Or install for the current project only
mkdir -p .claude/skills/km-installer
cp km-installer/skills/SKILL.md .claude/skills/km-installer/SKILL.md
```

Restart Claude Code, or begin a new session, so the skill can be loaded.

## Using the Skill

From within your project, ask Claude:
```bash
Install KISSmetrics in this project
```
Or invoke the skill directly:
```bash
/km-installer
```
Have your **KISSmetrics product key** available. You can find it in the KISSmetrics dashboard under your product's tracking settings. Claude will request it before starting the installation.

## Requirements

* A KISSmetrics account with a valid product key
* A Git repository so Claude can create a review branch
* A few minutes to review and approve the changes

## Notes

* The KISSmetrics snippet runs in the browser, so it works independently of your backend language. The installation location varies by framework.
* For WordPress and Shopify, the official plugin or app is often the simplest option. Claude will explain the alternatives and let you choose.
* Claude always creates a branch for review. Your team remains in control of approving, merging, and deploying changes.
* No secrets are stored in this repository or in the skill itself. Your product key is requested during installation and is never committed to this project.
