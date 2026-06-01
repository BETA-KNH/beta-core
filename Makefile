SHELL := /bin/bash
ROS_DISTRO ?= jazzy
ROS_SETUP := /opt/ros/$(ROS_DISTRO)/setup.bash

# Workspace root resolution order:
#   1. ROS2_WS env var (set automatically inside the Dev Container)
#   2. Two levels up — works when repo is at <ws>/src/beta-core/
#   3. Override: make build WS_ROOT=/path/to/ros2_ws
WS_ROOT ?= $(or $(ROS2_WS),$(realpath $(CURDIR)/../..))
_ := $(if $(wildcard $(WS_ROOT)/src),,$(warning WS_ROOT=$(WS_ROOT) has no src/ — set WS_ROOT manually))

.PHONY: all build build-release test test-verbose lint clean setup doctor sim

all: build

build:
	source $(ROS_SETUP) && cd $(WS_ROOT) && \
	colcon build --symlink-install \
		--cmake-args -DCMAKE_BUILD_TYPE=RelWithDebInfo \
		--event-handlers console_cohesion+

build-release:
	source $(ROS_SETUP) && cd $(WS_ROOT) && \
	colcon build --cmake-args -DCMAKE_BUILD_TYPE=Release

test:
	source $(ROS_SETUP) && cd $(WS_ROOT) && \
	colcon test --return-code-on-test-failure
	cd $(WS_ROOT) && colcon test-result --verbose

test-pkg:
	@[ -n "$(PKG)" ] || (echo "Usage: make test-pkg PKG=<package_name>" && exit 1)
	source $(ROS_SETUP) && cd $(WS_ROOT) && \
	colcon test --packages-select $(PKG) --return-code-on-test-failure
	cd $(WS_ROOT) && colcon test-result --verbose

lint:
	pre-commit run --all-files

lint-staged:
	pre-commit run

clean:
	rm -rf $(WS_ROOT)/build $(WS_ROOT)/install $(WS_ROOT)/log

setup:
	pip install pre-commit
	pre-commit install
	source $(ROS_SETUP) && cd $(WS_ROOT) && \
	rosdep install --from-paths src --ignore-src -r -y

doctor:
	source $(ROS_SETUP) && ros2 doctor --report

sim:
	source $(ROS_SETUP) && source $(WS_ROOT)/install/setup.bash && \
	gz sim --headless-rendering
