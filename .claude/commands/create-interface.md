Create ROS2 message/service/action interface files based on: $ARGUMENTS

Determine the type from the specification:
- **Message (.msg)**: data structure published on a topic
- **Service (.srv)**: request/response for synchronous calls
- **Action (.action)**: goal/result/feedback for long-running async tasks

**Message (.msg) — place in `msg/`:**
```
# Header for timestamped data
std_msgs/Header header

# Use built-in types: bool, int8/16/32/64, uint*, float32/64, string, byte[]
geometry_msgs/Pose target_pose
float64[] joint_positions
string status
```

**Service (.srv) — place in `srv/`:**
```
# Request
geometry_msgs/PoseStamped target
bool execute_immediately
---
# Response
bool success
string message
trajectory_msgs/JointTrajectory planned_trajectory
```

**Action (.action) — place in `action/`:**
```
# Goal
geometry_msgs/PoseStamped target_pose
float64 velocity_scaling
---
# Result
bool success
string message
float64 execution_time
---
# Feedback (sent periodically during execution)
float64 progress  # 0.0 to 1.0
geometry_msgs/Pose current_pose
string current_phase
```

**After creating the interface file, update CMakeLists.txt:**
```cmake
find_package(rosidl_default_generators REQUIRED)
rosidl_generate_interfaces(${PROJECT_NAME}
  "msg/MyMessage.msg"
  "srv/MyService.srv"
  "action/MyAction.action"
  DEPENDENCIES geometry_msgs std_msgs trajectory_msgs
)
```

And add to `package.xml`:
```xml
<build_depend>rosidl_default_generators</build_depend>
<exec_depend>rosidl_default_runtime</exec_depend>
<member_of_group>rosidl_interface_packages</member_of_group>
```
