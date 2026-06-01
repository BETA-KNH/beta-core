# ROS2 Core Patterns

## Lifecycle Nodes (always prefer over rclcpp::Node)

```cpp
#include "rclcpp_lifecycle/lifecycle_node.hpp"
#include "rclcpp_lifecycle/lifecycle_publisher.hpp"

class MyNode : public rclcpp_lifecycle::LifecycleNode {
public:
  explicit MyNode(const rclcpp::NodeOptions & options)
  : rclcpp_lifecycle::LifecycleNode("my_node", options) {}

  rclcpp_lifecycle::node_interfaces::LifecycleNodeInterface::CallbackReturn
  on_configure(const rclcpp_lifecycle::State &) override {
    // Declare parameters here — not in constructor
    declare_parameter<double>("rate_hz", 10.0);
    declare_parameter<std::string>("frame_id", "base_link");
    rate_hz_ = get_parameter("rate_hz").as_double();
    return CallbackReturn::SUCCESS;
  }

  rclcpp_lifecycle::node_interfaces::LifecycleNodeInterface::CallbackReturn
  on_activate(const rclcpp_lifecycle::State &) override {
    pub_->on_activate();
    timer_ = create_wall_timer(
      std::chrono::duration<double>(1.0 / rate_hz_),
      std::bind(&MyNode::timer_cb, this));
    return CallbackReturn::SUCCESS;
  }

  rclcpp_lifecycle::node_interfaces::LifecycleNodeInterface::CallbackReturn
  on_deactivate(const rclcpp_lifecycle::State &) override {
    timer_.reset();
    pub_->on_deactivate();
    return CallbackReturn::SUCCESS;
  }

  rclcpp_lifecycle::node_interfaces::LifecycleNodeInterface::CallbackReturn
  on_cleanup(const rclcpp_lifecycle::State &) override {
    pub_.reset();
    return CallbackReturn::SUCCESS;
  }

  rclcpp_lifecycle::node_interfaces::LifecycleNodeInterface::CallbackReturn
  on_shutdown(const rclcpp_lifecycle::State &) override {
    return CallbackReturn::SUCCESS;
  }

private:
  rclcpp_lifecycle::LifecyclePublisher<std_msgs::msg::String>::SharedPtr pub_;
  rclcpp::TimerBase::SharedPtr timer_;
  double rate_hz_{10.0};
};
```

## QoS Profiles — Use the Right One

```cpp
// Sensor data (LiDAR, IMU, cameras) — drop old data, low latency
auto qos = rclcpp::SensorDataQoS();

// Commands and joint targets — reliable delivery required
auto qos = rclcpp::SystemDefaultsQoS();

// TF — late-joiners must get current transforms
auto qos = rclcpp::QoS(100).transient_local();

// Status/diagnostics — best effort, high frequency
auto qos = rclcpp::QoS(10).best_effort().durability_volatile();
```

## Thread-Safe Callback Groups

```cpp
// Use when a subscriber must not block a timer (e.g., sensor processing + control loop)
callback_group_timer_ = create_callback_group(
  rclcpp::CallbackGroupType::MutuallyExclusive);
callback_group_sub_ = create_callback_group(
  rclcpp::CallbackGroupType::MutuallyExclusive);

rclcpp::SubscriptionOptions sub_opts;
sub_opts.callback_group = callback_group_sub_;
sub_ = create_subscription<Msg>("/topic", qos, callback, sub_opts);

// Node must use MultiThreadedExecutor
auto exec = rclcpp::executors::MultiThreadedExecutor();
exec.add_node(node->get_node_base_interface());
exec.spin();
```

## Parameter Descriptors

```cpp
rcl_interfaces::msg::ParameterDescriptor desc;
desc.description = "Control loop frequency in Hz";
desc.floating_point_range.resize(1);
desc.floating_point_range[0].from_value = 1.0;
desc.floating_point_range[0].to_value = 1000.0;
desc.floating_point_range[0].step = 0.0;
declare_parameter<double>("rate_hz", 50.0, desc);
```

## Composable Nodes (for zero-copy IPC within a container)

```cpp
#include "rclcpp_components/register_node_macro.hpp"
// At bottom of .cpp:
RCLCPP_COMPONENTS_REGISTER_NODE(my_package::MyNode)
```

```cmake
# CMakeLists.txt
add_library(my_node_component SHARED src/my_node.cpp)
rclcpp_components_register_node(my_node_component
  PLUGIN "my_package::MyNode"
  EXECUTABLE my_node)
```
