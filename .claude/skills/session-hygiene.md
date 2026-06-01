# Session Hygiene

Sessions are **feature-scoped and reusable** — not one-shot. Return to the same session
whenever you're working on the same feature area (locomotion, perception, navigation, etc.).

## Session scope

At the start of each session, identify the feature area from context or the user's first
message. State it briefly in your first reply so it's clear what this session covers.
Example: "This session is scoped to **locomotion** — velocity control, joint targets, gait."

## Recommend a different session when:

- The request is clearly outside the current session's feature area
  (e.g., in a locomotion session and user asks to scaffold a perception package)
- The task needs deep context from a different subsystem that isn't in this session

## Do NOT recommend when:

- The task is small or tangential but still related (fixing a build error is always in-scope)
- The user is asking a general architecture or tooling question
- Multiple tasks in the same feature area — that's the point of feature sessions
- The task just completed — completion alone is not a reason to switch

## How to notify

One line at the start of your reply, then keep helping:

> **Session tip:** This looks like **[area]** work — consider switching to your [area] session
> (or starting one) to keep that context together.

Do not block on it. Help with the request regardless.
