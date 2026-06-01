# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

`beta-core` is a ROS (Robot Operating System) repository using the **Catkin** build system. The `.gitignore` reveals the expected workspace layout: generated `devel/`, `build/`, and `lib/` directories are excluded, along with ROS message/service auto-generated files, dynamic reconfigure outputs, and a `planning` package.

## Workspace Layout

This repo is intended to live inside a Catkin workspace `src/` directory:

```
catkin_ws/
  src/
    beta-core/       ← this repo
      planning/      ← hinted by .gitignore
      <other pkgs>/
  build/             ← generated, gitignored
  devel/             ← generated, gitignored
```

## Build

```bash
# From workspace root (catkin_ws/)
catkin_make

# Or with catkin_tools (preferred for multi-package workspaces)
catkin build

# Source the workspace after building
source devel/setup.bash
```

## Testing

```bash
# Run all tests (catkin_make)
catkin_make run_tests

# Run tests for a single package
catkin_make run_tests_<package_name>

# With catkin_tools
catkin run_tests
catkin run_tests --no-deps <package_name>

# Run a specific rostest file
rostest <package_name> <test_file.test>

# Run a specific gtest/rosunit
rosrun <package_name> <test_binary>
```

## Key ROS Conventions

- **Packages** each have a `CMakeLists.txt` and `package.xml`. These define dependencies, message/service/action generation, and build targets.
- **Messages/Services/Actions**: Auto-generated Python and C++ bindings land in `devel/` — never edit those files directly.
- **Dynamic reconfigure**: Config files in `cfg/` generate `cfg/cpp/` and `cfg/*.py` (both gitignored). Run `catkin_make` to regenerate after editing `.cfg` files.
- **Launching nodes**: `roslaunch <package_name> <launch_file.launch>`
- **Environment**: Always `source devel/setup.bash` (or `setup.zsh`) before running any ROS commands in a new shell.

## Catkin Package Structure (per package)

```
<package>/
  CMakeLists.txt    ← build rules, message generation, install targets
  package.xml       ← dependencies, version, maintainer
  include/          ← C++ headers
  src/              ← C++ source or Python nodes
  scripts/          ← executable Python nodes/scripts
  launch/           ← .launch files
  msg/              ← custom message definitions (.msg)
  srv/              ← custom service definitions (.srv)
  action/           ← custom action definitions (.action)
  cfg/              ← dynamic reconfigure config files (.cfg)
  test/             ← test files (.test, _test.py, _test.cpp)
```
