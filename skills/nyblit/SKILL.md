---
name: nyblit
description: Use when the user mentions Nyblit, or asks about their tasks, today's plan, workflows, projects or repeating tasks and the Nyblit tools are available. Explains how Nyblit organises work so the tools are used the way the app expects.
---

# Working with Nyblit

Nyblit is a task app for Mac, iPhone, iPad and Apple Watch. This plugin connects Claude to the copy of Nyblit installed on the user's Mac through the `nyblit` MCP server, which gives Claude the same tools Nyblit's own assistant, Nyby, uses.

The tools exist only where that server can run: Claude Code on the Mac, or a Cowork session running on the Mac. If no Nyblit tools are in your tool list, say that Nyblit is reachable only from Claude Code or Cowork on a Mac with Nyblit installed, and do not act as if you could see the user's tasks.

## First call

Call `getNyblitGuide` before any other Nyblit tool in a session. It is cheap, changes nothing, and returns the full model plus the names of the user's own workflows. Which tools exist depends on the switches under Settings > AI Settings > Task Access for MCP in Nyblit; a missing tool is turned on there, not worked around.

Writes apply straight away. Nyblit does not queue them for review, so confirm with the user before creating, editing, moving, archiving or deleting anything.

## How Nyblit organises work

- **Five tabs, one per task.** Every task sits in exactly one of Not Started, Today, Blocked, Later or Done. Moving a task between tabs is the central action.
- **Today is the plan for today.** A task there, or the steps left visible on it, is due today whatever its deadline. Never describe a Today task as actionable but not due.
- **Blocked and Later differ by agency.** Blocked means something outside the user's control holds the task, such as a reply, parts or funds. Later means the user parked it deliberately, often with a return time after which it lands on a Today step.
- **Workflows carry the vocabulary.** Most tasks belong to a workflow: a category with its own state names for each tab. Watch Repair is blocked by Parts Availability, Email by Awaiting Reply. Call `listWorkflows` before creating or moving a task, and choose both the workflow and the state within the target tab. If none fits, create one with `createWorkflow` rather than forcing a task into the nearest name; a one-off with no domain can stay in No Workflow. Both are judgements, not defaults.
- **Today states are ordered steps.** A task's state is the step it is on. Which steps are finished is tracked separately and fills the task's progress: tick them with `completeTaskSteps`. Setting a state marks that step active, not complete, so a state move alone is not progress and should not be reported as any.
- **Priority is computed, never assigned.** It comes from deadline, progress and life context. Call `explainTaskPriority` before giving any reason a task ranks where it does, and use `setTaskImportance` for a signed nudge instead of asking the user to pick a priority level.

## The shape of a task

A task is one thread of work: it sits in one tab, stalls for one reason at a time, and its steps are the stages of that thread. A project groups the tasks of one endeavour and can carry a target date. So a job with several threads, such as several people to hear from, several deadlines, or work that can proceed in parallel, is a project of tasks, each on the workflow that fits it, not one task with a long step list. A step that waits on someone is the sign: a step cannot go Blocked, a task can. The user's existing projects show the grain they work at.
