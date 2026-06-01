# ADR 001 — Use ROS2 Jazzy Jalisco

**Status:** Accepted
**Date:** 2026-06-01

## Decision

Use ROS2 **Jazzy Jalisco** as the ROS2 distribution for all packages in this repository.

## Rationale

- Jazzy is the current LTS release (supported until May 2029), giving the longest maintenance window for a production humanoid system.
- Jazzy is supported by all key dependencies: BehaviorTree.CPP v4, MoveIt2, Nav2, ros2_control, PAL Robotics TALOS stack.
- The Unitree G1 community packages (`g1pilot`, `unitree_ros2`) explicitly support Humble and Jazzy.
- NVIDIA Isaac ROS and GR00T N1 deployment tooling targets Jazzy.

## Alternatives Rejected

- **Humble**: Previous LTS; shorter remaining support window; fewer new packages targeting it.
- **Rolling/Kilted**: Unstable API surface; inappropriate for production robot software.

## Consequences

- Dev Container, CI, and all CMakeLists.txt/package.xml must target `jazzy`.
- Default middleware: CycloneDDS (`RMW_IMPLEMENTATION=rmw_cyclonedds_cpp`) — better performance than FastDDS for real-time robot control.
