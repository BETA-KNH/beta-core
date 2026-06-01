# CLAUDE.md

ROS2 Jazzy humanoid robot stack. Workspace root: `ros2_ws/`, this repo at `ros2_ws/src/beta-core/`.

## Commands

```bash
make build                  # colcon build --symlink-install (RelWithDebInfo)
make build PKG=<name>       # single package
make test                   # colcon test + results summary
make test-pkg PKG=<name>    # single package
make lint                   # pre-commit --all-files
make setup                  # first-time: pre-commit install + rosdep
```

## Hard Rules

- **Every node is a lifecycle node** (`rclcpp_lifecycle::LifecycleNode`) — `ros2_control` requires it.
- **package.xml**: `format="3"`, license `Apache-2.0`
- **Middleware**: CycloneDDS (`RMW_IMPLEMENTATION=rmw_cyclonedds_cpp`)

**QoS:**
- Sensors (LiDAR, IMU, cameras): `rclcpp::SensorDataQoS()`
- Commands / joint targets: `rclcpp::SystemDefaultsQoS()`
- `/tf_static`: `rclcpp::QoS(100).transient_local()`
- `/tf` (dynamic): `rclcpp::SystemDefaultsQoS()` — keep VOLATILE

## Skills & Slash Commands

Coding patterns (load when writing nodes, tests, or perception/navigation code):
`.claude/skills/ros2-core.md`, `ros2-testing.md`, `ros2-perception.md`, `ros2-navigation.md`

Slash commands: `/scaffold-package <name>`, `/create-node <spec>`, `/create-launch <spec>`, `/create-interface <spec>`

## Architecture Decisions

`docs/decisions/` — read before proposing alternatives to recorded choices.
