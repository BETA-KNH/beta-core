Create a ROS2 launch file based on: $ARGUMENTS

**Standard launch file template (Python):**
```python
from launch import LaunchDescription
from launch.actions import DeclareLaunchArgument, GroupAction
from launch.substitutions import LaunchConfiguration, PathJoinSubstitution
from launch_ros.actions import Node, PushRosNamespace
from launch_ros.substitutions import FindPackageShare

def generate_launch_description():
    pkg = FindPackageShare('package_name')

    return LaunchDescription([
        DeclareLaunchArgument('use_sim_time', default_value='false'),
        Node(
            package='package_name',
            executable='node_executable',
            name='node_name',
            parameters=[
                PathJoinSubstitution([pkg, 'config', 'params.yaml']),
                {'use_sim_time': LaunchConfiguration('use_sim_time')},
            ],
            remappings=[('/old_topic', '/new_topic')],
            output='screen',
        ),
    ])
```

**Common patterns to include based on the specification:**
- `use_sim_time` argument (always declare it)
- `namespace` argument if multiple robot instances are needed
- `log_level` argument for debugging
- Lifecycle manager if launching lifecycle nodes
- Composable node container if using composable nodes for zero-copy IPC

**Naming conventions:**
- Launch files: `<purpose>.launch.py` (e.g., `perception.launch.py`, `control.launch.py`)
- Add to `CMakeLists.txt` install rules under `launch/`
