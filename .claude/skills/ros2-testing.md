# ROS2 Testing Patterns

## Unit Tests with gtest (C++)

```cmake
# CMakeLists.txt
if(BUILD_TESTING)
  find_package(ament_cmake_gtest REQUIRED)
  ament_add_gtest(test_my_node test/test_my_node.cpp)
  target_link_libraries(test_my_node my_node_lib)
  ament_target_dependencies(test_my_node rclcpp)
endif()
```

```cpp
// test/test_my_node.cpp
#include <gtest/gtest.h>
#include "rclcpp/rclcpp.hpp"
#include "my_package/my_node.hpp"

class TestMyNode : public ::testing::Test {
protected:
  static void SetUpTestSuite() { rclcpp::init(0, nullptr); }
  static void TearDownTestSuite() { rclcpp::shutdown(); }
};

TEST_F(TestMyNode, ParameterDefaults) {
  rclcpp::NodeOptions opts;
  auto node = std::make_shared<my_package::MyNode>(opts);
  EXPECT_DOUBLE_EQ(node->get_parameter("rate_hz").as_double(), 10.0);
}
```

## Integration Tests with launch_testing (Python)

```python
# test/test_my_node_launch.py
import pytest
import rclpy
from launch import LaunchDescription
from launch_ros.actions import Node
import launch_testing
import launch_testing.actions
from std_msgs.msg import String

@pytest.fixture
def launch_description():
    return LaunchDescription([
        Node(package='my_package', executable='my_node', name='my_node'),
        launch_testing.actions.ReadyToTest(),
    ])

@launch_testing.markers.keep_alive
def test_proc(launch_service, proc_info, launch_description):
    pass

class TestMyNodeBehavior(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        rclpy.init()
        cls.node = rclpy.create_node('test_node')

    @classmethod
    def tearDownClass(cls):
        cls.node.destroy_node()
        rclpy.shutdown()

    def test_publishes_output(self):
        received = []
        sub = self.node.create_subscription(
            String, '/output', lambda msg: received.append(msg), 10)
        end_time = time.time() + 5.0
        while time.time() < end_time and not received:
            rclpy.spin_once(self.node, timeout_sec=0.1)
        self.assertTrue(len(received) > 0)
```

```cmake
# CMakeLists.txt
if(BUILD_TESTING)
  find_package(ament_cmake_pytest REQUIRED)
  find_package(launch_testing_ament_cmake REQUIRED)
  add_launch_test(test/test_my_node_launch.py)
endif()
```

## Running Tests

```bash
# All tests in workspace
colcon test --return-code-on-test-failure
colcon test-result --verbose           # human-readable summary

# Single package
colcon test --packages-select my_package --return-code-on-test-failure

# Single test binary
ros2 run my_package test_my_node --gtest_filter=TestMyNode.ParameterDefaults

# Integration test only
ros2 launch launch_testing my_test.launch.py
```

## Lint Tests (auto-added by ament_lint_auto)

```cmake
if(BUILD_TESTING)
  find_package(ament_lint_auto REQUIRED)
  ament_lint_auto_find_test_dependencies()  # reads package.xml test_depend
endif()
```

```xml
<!-- package.xml -->
<test_depend>ament_lint_auto</test_depend>
<test_depend>ament_lint_common</test_depend>
```
