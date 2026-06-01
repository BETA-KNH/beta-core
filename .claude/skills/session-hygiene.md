# Session Hygiene

After completing any self-contained task, evaluate whether the user should start a new session.

## Recommend a new session when:

- A package was scaffolded, a node created, or a launch file written (feature complete)
- A bug was fixed and tests pass (fix complete)
- An ADR was written or updated (decision recorded)
- A CI/lint issue was fully resolved (infra complete)
- The user is about to switch to a completely different subsystem (e.g., locomotion → perception)
- This session has had 10+ back-and-forth exchanges on the same topic

## Do NOT recommend when:

- The current task is still in progress (build failing, mid-refactor)
- The user just asked a question and is deciding what to do next
- The task naturally continues (e.g., scaffold → add node → write test is one flow)

## How to notify

At the end of your reply, add a short line:

> **Session tip:** This task is complete. Start a fresh session for your next independent task to keep context lean.

Keep it one line. Do not repeat it if the user continues in the same session anyway.
