# ADR 002 — Behaviour Execution Stack

**Status:** Accepted
**Date:** 2026-06-01

## Decision

Use the following layered stack for skill and task execution:

| Layer | Technology | Role |
|---|---|---|
| Hardware abstraction | `ros2_control` | Joint interfaces, controller lifecycle |
| Skill orchestration | `BehaviorTree.CPP v4` + `BehaviorTree.ROS2` | Reactive task trees |
| Manipulation planning | `MoveIt2 Task Constructor` | Multi-stage manipulation |
| Goal navigation | `Nav2` | High-level pose goals |
| Task planning | `PlanSys2` (PDDL) | Symbolic plan generation |
| LLM orchestration | `RAI` (RobotecAI) | Natural language → ROS2 actions |

## Rationale

- **ros2_control**: Co-developed by PAL Robotics (TALOS humanoid); confirmed on real bipedal hardware.
- **BehaviorTree.CPP v4**: De-facto standard; Nav2 and MoveIt Pro both embed it; Groot2 GUI; confirmed on industrial humanoids.
- **MoveIt2 MTC**: Best open-source multi-stage manipulation planner for ROS2.
- **Nav2**: Only mature ROS2 navigation stack; PAL TALOS confirmed.
- **PlanSys2**: Only actively maintained PDDL planner native to ROS2 (all distros); successor to ROSPlan.
- **RAI**: Most feature-complete LLM agent for ROS2 (Humble+Jazzy); real robot demos; ROSCon 2024.

## Alternatives Rejected

- **FlexBE**: Strong humanoid history (Atlas DRC) but ROS2 port has thinner real-hardware evidence; no mixed-initiative needed initially.
- **SMACH**: Declining adoption; community migrating to BT-based approaches.
- **ROSPlan**: Never ported to ROS2.
- **OpenRAVE**: No ROS2 support; superseded by MoveIt2.

## Consequences

- All nodes must be `rclcpp_lifecycle::LifecycleNode` — controllers require it.
- Skill nodes are BT leaf nodes wrapping ROS2 action servers.
- LLM integration goes through RAI's tool layer, not direct topic publishing.
