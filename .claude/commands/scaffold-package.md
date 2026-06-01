Generate a complete ROS2 C++ package named $ARGUMENTS inside the current workspace src/ directory.

The package must include:

**Package structure:**
- `CMakeLists.txt` using ament_cmake, with targets for the node executable, library (if applicable), install rules, and ament_lint tests
- `package.xml` format="3" with correct maintainer (nk.kulis@gmail.com), license (Apache-2.0), and build/exec dependencies
- `include/$ARGUMENTS/$ARGUMENTS_node.hpp` — class declaration
- `src/$ARGUMENTS_node.cpp` — lifecycle node implementation
- `src/main.cpp` — minimal entry point
- `launch/$ARGUMENTS.launch.py` — launches the node with parameter file
- `config/params.yaml` — default parameters matching declared node parameters
- `test/test_$ARGUMENTS_node.cpp` — gtest unit tests

**Node requirements:**
- Inherit from `rclcpp_lifecycle::LifecycleNode`, not `rclcpp::Node`
- Implement `on_configure`, `on_activate`, `on_deactivate`, `on_cleanup`, `on_shutdown`
- Declare all parameters in `on_configure` using `declare_parameter<T>()` with descriptors
- Create publishers/subscribers/timers in `on_activate`, destroy in `on_deactivate`
- Use callback groups for thread safety if multiple callbacks exist

**Quality requirements:**
- All subscribers use appropriate QoS (SENSOR_DATA profile for sensor topics, SYSTEM_DEFAULT for commands)
- No raw pointers to ROS2 objects — use shared_ptr
- Follow .clang-format style (Google-based, 99 col limit)

After generating, verify it builds: `make build PKG=$ARGUMENTS`
