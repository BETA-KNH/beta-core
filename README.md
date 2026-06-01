# beta-core

ROS2 Jazzy software stack for a humanoid robot. Built with colcon, using CycloneDDS middleware.

## Quick Start (Dev Container)

Open in VS Code → **Reopen in Container**. The container sets up a full ROS2 Jazzy workspace at `/ros2_ws` with all dependencies pre-installed.

```bash
make setup    # first time only — installs pre-commit hooks + rosdep deps
make build
make test
```

## Manual Setup

```bash
# Create workspace (skip if already exists)
mkdir -p ~/ros2_ws/src && cd ~/ros2_ws/src
git clone <this-repo> beta-core

# Install dependencies and build
source /opt/ros/jazzy/setup.bash
cd ~/ros2_ws
rosdep install --from-paths src --ignore-src -r -y
colcon build --symlink-install
source install/setup.bash
```

## Common Commands

```bash
make build                     # build all packages (RelWithDebInfo)
make test                      # build + run all tests
make test-pkg PKG=<name>       # test a single package
make lint                      # run pre-commit on all files
make clean                     # remove build/ install/ log/
make doctor                    # ros2 doctor --report
```

## Project Structure

```
beta-core/
  <package>/           # one directory per ROS2 package
  docs/decisions/      # architecture decision records (ADRs)
  .claude/             # AI agent config: skills, commands, MCP servers
  .devcontainer/       # VS Code Dev Container (ROS2 Jazzy)
  .github/workflows/   # CI: lint + build/test on every push
```

## For AI Agents

See [CLAUDE.md](CLAUDE.md) for build commands, coding conventions, and architecture overview.  
See [docs/decisions/](docs/decisions/) for rationale behind key design choices.
