---
inclusion: manual
name: "web-ctl"
description: "Use when user asks to \"open a webpage\", \"browse website\", \"log into site\", \"scrape page\", \"interact with web\", \"web automation\", \"browser control\"."
---

# /web-ctl Command

Browser automation for AI agents. Navigate websites, authenticate with human handoff, and interact with web pages.

## Intent Routing

Parse the user's request and route appropriately:

### Simple Actions (Direct Skill Invocation)

For single-step requests like "go to example.com" or "take a screenshot":

1. Invoke the **web-browse** skill with session name and action
2. Sessions auto-create on first run command if they don't exist

### Auth Requests

For "log into X" or "authenticate to Y":

1. Create a session named after the service
2. Invoke the **web-auth** skill

### Multi-Step Flows

For complex requests like "find information on a website" or "fill out a form":

1. Delegate to the **web-session** agent via Task tool

## Quick Reference

```bash
# Session lifecycle
node /Users/avifen/.agentsys/plugins/web-ctl/scripts/web-ctl.js session start <name>
node /Users/avifen/.agentsys/plugins/web-ctl/scripts/web-ctl.js session auth <name> --provider <provider>
node /Users/avifen/.agentsys/plugins/web-ctl/scripts/web-ctl.js session auth <name> --url <url> [--verify-url <url>] [--verify-selector <sel>]
node /Users/avifen/.agentsys/plugins/web-ctl/scripts/web-ctl.js session auth <name> --provider <slug> --providers-file <path>
node /Users/avifen/.agentsys/plugins/web-ctl/scripts/web-ctl.js session providers
node /Users/avifen/.agentsys/plugins/web-ctl/scripts/web-ctl.js session list
node /Users/avifen/.agentsys/plugins/web-ctl/scripts/web-ctl.js session end <name>
node /Users/avifen/.agentsys/plugins/web-ctl/scripts/web-ctl.js session verify <name> --url <url>

# Browser actions
node /Users/avifen/.agentsys/plugins/web-ctl/scripts/web-ctl.js run <session> goto <url> [--ensure-auth]
node /Users/avifen/.agentsys/plugins/web-ctl/scripts/web-ctl.js run <session> snapshot
node /Users/avifen/.agentsys/plugins/web-ctl/scripts/web-ctl.js run <session> click <selector>
node /Users/avifen/.agentsys/plugins/web-ctl/scripts/web-ctl.js run <session> read <selector>
node /Users/avifen/.agentsys/plugins/web-ctl/scripts/web-ctl.js run <session> screenshot

# Snapshot control (apply to any action with snapshot output)
node /Users/avifen/.agentsys/plugins/web-ctl/scripts/web-ctl.js run <session> snapshot --snapshot-depth 3
node /Users/avifen/.agentsys/plugins/web-ctl/scripts/web-ctl.js run <session> goto <url> --snapshot-selector "css=nav"
node /Users/avifen/.agentsys/plugins/web-ctl/scripts/web-ctl.js run <session> click <sel> --no-snapshot
node /Users/avifen/.agentsys/plugins/web-ctl/scripts/web-ctl.js run <session> snapshot --snapshot-collapse
node /Users/avifen/.agentsys/plugins/web-ctl/scripts/web-ctl.js run <session> snapshot --snapshot-compact
node /Users/avifen/.agentsys/plugins/web-ctl/scripts/web-ctl.js run <session> snapshot --snapshot-text-only --snapshot-max-lines 50
node /Users/avifen/.agentsys/plugins/web-ctl/scripts/web-ctl.js run <session> goto <url> --snapshot-full
node /Users/avifen/.agentsys/plugins/web-ctl/scripts/web-ctl.js run <session> goto <url> --snapshot-collapse --snapshot-depth 4

# Macros
node /Users/avifen/.agentsys/plugins/web-ctl/scripts/web-ctl.js run <session> select-option <sel> <text>
node /Users/avifen/.agentsys/plugins/web-ctl/scripts/web-ctl.js run <session> tab-switch <name>
node /Users/avifen/.agentsys/plugins/web-ctl/scripts/web-ctl.js run <session> modal-dismiss [--accept]
node /Users/avifen/.agentsys/plugins/web-ctl/scripts/web-ctl.js run <session> form-fill --fields '<json>' [--submit]
node /Users/avifen/.agentsys/plugins/web-ctl/scripts/web-ctl.js run <session> search-select <sel> <query> --pick <text>
node /Users/avifen/.agentsys/plugins/web-ctl/scripts/web-ctl.js run <session> date-pick <sel> --date <YYYY-MM-DD>
node /Users/avifen/.agentsys/plugins/web-ctl/scripts/web-ctl.js run <session> file-upload <sel> <path>
node /Users/avifen/.agentsys/plugins/web-ctl/scripts/web-ctl.js run <session> hover-reveal <sel> --click <target>
node /Users/avifen/.agentsys/plugins/web-ctl/scripts/web-ctl.js run <session> scroll-to <sel>
node /Users/avifen/.agentsys/plugins/web-ctl/scripts/web-ctl.js run <session> wait-toast [--dismiss]
node /Users/avifen/.agentsys/plugins/web-ctl/scripts/web-ctl.js run <session> iframe-action <iframe> <action> [args]
node /Users/avifen/.agentsys/plugins/web-ctl/scripts/web-ctl.js run <session> login --user <u> --pass <p>
node /Users/avifen/.agentsys/plugins/web-ctl/scripts/web-ctl.js run <session> next-page
node /Users/avifen/.agentsys/plugins/web-ctl/scripts/web-ctl.js run <session> paginate --selector <sel> [--max-pages N] [--max-items N]
node /Users/avifen/.agentsys/plugins/web-ctl/scripts/web-ctl.js run <session> extract --selector <sel> [--fields f1,f2,...] [--max-items N] [--max-field-length N]
node /Users/avifen/.agentsys/plugins/web-ctl/scripts/web-ctl.js run <session> extract --auto [--max-items N] [--max-field-length N]
```

## Examples

User: "Open github.com and show me my profile"
1. Start session "github"
2. Auth if needed (web-auth skill)
3. Navigate to github.com/profile
4. Snapshot and report

User: "Take a screenshot of example.com"
1. Start session "quick"
2. Goto example.com
3. Screenshot
4. End session

User: "Log into Twitter"
1. Start session "twitter"
2. Auth with `--provider twitter` (auto-configures URL and success detection)
3. Report success/failure

User: "Log into GitHub"
1. Start session "github"
2. Auth with `--provider github`
3. Report success/failure
