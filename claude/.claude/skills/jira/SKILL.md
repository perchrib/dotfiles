---
name: jira
description: Read a Jira issue (e.g. TILT-945) with the jira CLI, investigate the codebase, and propose an implementation plan. Use when the user references a Jira issue key or asks to work on a Jira task.
argument-hint: "[ISSUE-KEY]"
allowed-tools: Bash(jira issue view:*), Bash(JIRA_PAGER=cat jira issue view:*), Bash(git branch:*), Read, Glob, Grep, Agent
---

# Work on a Jira issue

## 1. Parse the arguments

Arguments: `$ARGUMENTS`

- The issue key is the first word if it looks like a Jira key (e.g.
  `TILT-945` or `tilt-945`, uppercase it).
- Otherwise derive it from the current branch: `git branch --show-current`
  (e.g. `tilt-945-lagre-sendeskjema` → `TILT-945`).
- If there is still no key, ask the user.
- **Everything else in the arguments is extra instructions from the user.**
  They take priority over the ticket where they conflict (e.g. scope limits,
  "only backend", "skip the plan and implement", hints about where to look).

## 2. Read the ticket

```bash
JIRA_PAGER=cat jira issue view <KEY> --plain --comments 10
```

- If the ticket has a parent/epic or linked issues that look relevant, view
  those too (fewer comments is fine).
- Attachments only show as `[attachment]`. If the ticket seems to depend on
  one, say so and ask the user to describe or paste it.
- Tickets are often written in Norwegian. Answer in the language the user
  writes to you in.

## 3. Investigate the codebase

Read-only: find the code, components, tests and patterns relevant to the
ticket. Do not edit anything yet.

## 4. Draft the plan and get it reviewed by another model

Draft a concrete step-by-step implementation plan, including tests. Then
get an independent review before showing it to the user (skip only if the
user's extra instructions say so, e.g. "no review"):

- Launch one `Plan` subagent with the Agent tool, setting `model` to a
  different model than the one you are running on (`sonnet` if you are
  Opus, otherwise `opus`). Do not use `fable`; it is not available.
- The reviewer has none of your context, so give it everything it needs:
  the full ticket text, the user's extra instructions, the relevant file
  paths, and your draft plan.
- Ask it to critically review the plan against the ticket and the code:
  missed or misread requirements, wrong assumptions about the code, risks
  and edge cases, missing tests, and simpler alternatives. It should read
  the code itself to verify claims, and end with a verdict: approve, or
  revise with concrete changes.
- Evaluate its feedback on the merits. Adopt what is right and reject what
  is not. The reviewer can be wrong too.

## 5. Save the plan, report and wait

Write the report below to `<KEY>-plan.md` (e.g. `TILT-945-plan.md`) at the
root of the current branch's checkout (`git rev-parse --show-toplevel`; in a
worktree this is the worktree root). Overwrite it if it already exists. This
is the only file you may write before approval. Do not commit it unless the
user asks.

Then reply with the same content:

1. **Ticket**: key, title, type, status, and a short summary of what is asked
2. **Acceptance criteria**: explicit or inferred from the description
3. **Open questions**: anything unclear or missing in the ticket
4. **Relevant code**: files and why they matter (`path:line`)
5. **Plan**: the final plan, after the review
6. **Review**: which model reviewed it, what changed because of the review,
   and any points you disagreed with (and why), so the user can decide

Then **stop and wait for the user's approval** before making any changes.
