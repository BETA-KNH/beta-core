# ADR 003 — AI-Assisted Development Tooling

**Status:** Accepted
**Date:** 2026-06-01

## Decision

Equip the repository with tooling that lets AI coding agents (Claude Code, Cursor) operate effectively without human intervention for routine development tasks.

## Tooling Chosen

### Agent Context
- **CLAUDE.md** — project instructions read at every session start
- **`.claude/skills/`** — ROS2 pattern libraries (lifecycle nodes, QoS, testing, perception, navigation)
- **`.claude/commands/`** — slash commands: `/scaffold-package`, `/create-node`, `/create-launch`, `/create-interface`

### Agent Capability
- **`.claude/settings.json`** — MCP servers:
  - `memory`: `@modelcontextprotocol/server-memory` — within-session knowledge graph
  - `ros2-dev`: `ros-mcp-server` — live ROS2 system introspection via rosbridge
- **RDE MCP Server** (VS Code extension, Ranch Hand Robotics) — 34 ROS2 dev tools when using VS Code

### Code Quality (automated, no human review needed)
- **`.pre-commit-config.yaml`** — black, isort, clang-format, hadolint run on every commit
- **`.clang-format`** — Google-derived C++ style, 99 col limit

### Build & Test
- **`Makefile`** — `make build`, `make test`, `make lint`, `make clean`, `make setup`
- **`.github/workflows/ci.yml`** — `action-ros-ci` runs colcon build + colcon test on every push

### Environment
- **`.devcontainer/devcontainer.json`** — `osrf/ros:jazzy-desktop-full`; includes colcon, rosdep, pre-commit, RDE VS Code extension

## External References
- [robotics-agent-skills](https://github.com/arpitg1304/robotics-agent-skills) — source of skill pattern library (Apache-2.0)
- [ros2-claude-code-template](https://github.com/harunkurtdev/ros2-claude-code-template) — source of command templates
- [ros-mcp-server](https://github.com/robotmcp/ros-mcp-server) — ROS2 MCP bridge

## Consequences

- All CI runs in ROS2 Jazzy container — no local environment differences.
- Agents must run `make setup` once after cloning to install pre-commit hooks.
- The `ros2-dev` MCP server requires `rosbridge_server` running: `ros2 launch rosbridge_server rosbridge_websocket.launch.xml`
- Important cross-session decisions must be recorded as ADRs in `docs/decisions/` — the memory MCP server resets on session restart.
