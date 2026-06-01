# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

`beta-core` is a **ROS2 Jazzy** repository for a humanoid robot system. It uses **colcon** as the build tool and lives inside a ROS2 workspace `src/` directory.

Authoritative architecture decisions are in `docs/decisions/`. Read those before proposing alternatives to the choices recorded there.

## Workspace Layout

```
ros2_ws/
  src/
    beta-core/        ← this repo
      <package_a>/
      <package_b>/
  build/              ← generated, gitignored
  install/            ← generated, gitignored
  log/                ← generated, gitignored
```

## Build

All commands run from the **workspace root** (`ros2_ws/`), or via `make` from inside this repo:

```bash
# From workspace root
source /opt/ros/jazzy/setup.bash
colcon build --symlink-install

# Source after building (required before running nodes)
source install/setup.bash

# Via Makefile (from inside beta-core/)
make build       # RelWithDebInfo
make build-release
make clean
```

## Testing

```bash
# All packages
colcon test --return-code-on-test-failure
colcon test-result --verbose          # human-readable summary

# Single package
colcon test --packages-select <pkg> --return-code-on-test-failure

# Via Makefile
make test
make test-pkg PKG=<package_name>
```

## Installing Dependencies

```bash
rosdep install --from-paths src --ignore-src -r -y
# Or:
make setup   # also installs pre-commit hooks
```

## Linting

```bash
pre-commit run --all-files   # all files
pre-commit run               # staged files only
make lint
```

CI runs lint as a separate job before build/test.

## Key Conventions

**Every node must be a lifecycle node** (`rclcpp_lifecycle::LifecycleNode`). Standard `rclcpp::Node` is not used — `ros2_control` controllers require lifecycle compliance.

**QoS by data type:**
- Sensor topics (LiDAR, IMU, cameras): `rclcpp::SensorDataQoS()`
- Commands and joint targets: `rclcpp::SystemDefaultsQoS()`
- `/tf`: `rclcpp::SystemDefaultsQoS()` (VOLATILE — dynamic transforms)
- `/tf_static`: `rclcpp::QoS(100).transient_local()`

**Package structure per package:**
```
<package>/
  CMakeLists.txt    ← ament_cmake, targets, lint tests
  package.xml       ← format="3", Apache-2.0
  include/<pkg>/    ← C++ headers
  src/              ← node source + main.cpp
  launch/           ← .launch.py files
  config/           ← params.yaml files
  msg/ srv/ action/ ← interface definitions
  test/             ← gtest + launch_testing
```

**Middleware:** CycloneDDS (`RMW_IMPLEMENTATION=rmw_cyclonedds_cpp`)

## Agent Skills

Detailed ROS2 coding patterns are in `.claude/skills/`. Reference them when generating nodes, tests, or interfaces:

- @.claude/skills/ros2-core.md — lifecycle nodes, QoS, composable nodes, parameters
- @.claude/skills/ros2-testing.md — gtest, launch_testing, colcon test commands
- @.claude/skills/ros2-perception.md — PointCloud2, images, TF2, message_filters
- @.claude/skills/ros2-navigation.md — Nav2 goals, BehaviorTree.CPP v4, action servers

## Slash Commands

- `/scaffold-package <name>` — generates a complete colcon-buildable ROS2 C++ package
- `/create-node <spec>` — generates a lifecycle node from a natural language spec
- `/create-launch <spec>` — generates a launch.py file
- `/create-interface <spec>` — generates .msg/.srv/.action files with CMakeLists updates

## MCP Servers (configured in .claude/settings.json)

- **memory** — in-session knowledge graph; resets on restart, so record important decisions as ADRs
- **ros2-dev** — introspect a running ROS2 system (topics, services, actions, parameters); requires rosbridge:
  ```bash
  ros2 launch rosbridge_server rosbridge_websocket.launch.xml
  ```

## CI

GitHub Actions (`.github/workflows/ci.yml`) runs on every push to `main`, `claude/**`, `feature/**`, `fix/**`:
1. **Lint** — pre-commit (black, isort, clang-format, hadolint)
2. **Build & Test** — `ros-tooling/action-ros-ci` with ROS2 Jazzy

## Architecture Decisions

See `docs/decisions/` for rationale behind key choices:
- `001-ros2-jazzy.md` — why Jazzy, why CycloneDDS
- `002-behaviour-execution.md` — BehaviorTree.CPP v4, ros2_control, Nav2, RAI stack
- `003-development-tooling.md` — agent tooling choices and setup instructions
