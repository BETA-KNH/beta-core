Create a ROS2 node based on the specification: $ARGUMENTS

Parse the specification for:
- Node name and package
- Node type: `lifecycle` (default), `standard`, or `composable`
- Language: `cpp` (default) or `python`
- Inputs: topic subscriptions, service servers, action servers
- Outputs: topic publishers, service clients, action clients
- Parameters needed

**For lifecycle nodes (C++):**
```cpp
class MyNode : public rclcpp_lifecycle::LifecycleNode {
  // on_configure: declare params, create non-active resources
  // on_activate: create publishers/subscribers/timers, activate publishers
  // on_deactivate: deactivate publishers, destroy timers
  // on_cleanup: release all resources
  // on_shutdown: emergency cleanup
};
```

**QoS cheatsheet — use the right profile:**
- `/scan`, `/pointcloud`, `/imu`, `/camera/*`: `rclcpp::SensorDataQoS()`
- `/cmd_vel`, `/joint_commands`: `rclcpp::SystemDefaultsQoS()`
- `/tf_static`: `rclcpp::QoS(100).transient_local()`
- `/tf`: `rclcpp::SystemDefaultsQoS()` (keep VOLATILE — dynamic transforms)
- Action feedback: RELIABLE + VOLATILE

**For Python lifecycle nodes:**
```python
from rclpy.lifecycle import LifecycleNode, TransitionCallbackReturn, State
```

After creating the node, add it to the package's CMakeLists.txt (C++) or setup.py (Python) and verify with `make build`.
