# Session Hygiene

Sessions are **feature-scoped and reusable** — not one-shot. Return to the same session
whenever you're working on the same feature area (locomotion, perception, navigation, etc.).

## Session scope

At the start of each session, identify the feature area from context or the user's first
message. State it briefly in your first reply so it's clear what this session covers.
Example: "This session is scoped to **locomotion** — velocity control, joint targets, gait."

## When a request falls outside the current session's feature area

**Step 1 — name the feature area** the request actually belongs to (e.g., "perception", "navigation", "hardware interface").

**Step 2 — check if a session exists** by asking the user:

> **Session tip:** This looks like **[area]** work, which is outside this session's scope.
> Do you have a **[area]** session open? If not, I can create a session starter for you.

**Step 3 — if no session exists**, generate a session starter block the user can paste into a new session:

```
Session scope: [Area] — [one-sentence description of what this session covers]

Goal: [What does "done" look like? Be specific — e.g., "G1 robot loads in RViz with
all joints visible and a working launch file."]

Relevant packages: [list any existing packages in /ros2_ws/src/ that belong to this area]
Relevant skills: [from .claude/skills/ — e.g., ros2-core.md, ros2-perception.md]
Relevant ADRs: [any docs/decisions/ entries that apply]
Relevant upstream: [any external repos or assets needed]

First task: [concrete, actionable first step — specific enough to start without clarification]
```

Then continue helping with the current request — do not block on the session decision.

## Do NOT recommend when:

- The task is small or tangential but still related (fixing a build error is always in-scope)
- The user is asking a general architecture or tooling question
- Multiple tasks in the same feature area — that's the point of feature sessions
- The task just completed — completion alone is not a reason to switch
