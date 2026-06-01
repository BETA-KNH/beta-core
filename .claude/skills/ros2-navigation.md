# ROS2 Navigation and Behavior Patterns

## Sending Nav2 Goals

```cpp
#include "nav2_msgs/action/navigate_to_pose.hpp"
#include "rclcpp_action/rclcpp_action.hpp"

using Nav2Goal = nav2_msgs::action::NavigateToPose;
auto nav2_client_ = rclcpp_action::create_client<Nav2Goal>(this, "navigate_to_pose");

void send_goal(double x, double y, double yaw) {
  Nav2Goal::Goal goal;
  goal.pose.header.frame_id = "map";
  goal.pose.header.stamp = now();
  goal.pose.pose.position.x = x;
  goal.pose.pose.position.y = y;
  tf2::Quaternion q;
  q.setRPY(0, 0, yaw);
  goal.pose.pose.orientation = tf2::toMsg(q);

  auto opts = rclcpp_action::Client<Nav2Goal>::SendGoalOptions();
  opts.result_callback = [](const auto & result) {
    bool ok = result.code == rclcpp_action::ResultCode::SUCCEEDED;
  };
  nav2_client_->async_send_goal(goal, opts);
}
```

## BehaviorTree.CPP v4 Leaf Node wrapping a ROS2 Action

```cpp
#include "behaviortree_ros2/bt_action_node.hpp"

class NavigateAction
: public BT::RosActionNode<nav2_msgs::action::NavigateToPose>
{
public:
  NavigateAction(const std::string & name, const BT::NodeConfig & conf,
                 const BT::RosNodeParams & params)
  : BT::RosActionNode<nav2_msgs::action::NavigateToPose>(name, conf, params) {}

  static BT::PortsList providedPorts() {
    return {BT::InputPort<geometry_msgs::msg::PoseStamped>("target_pose")};
  }

  bool setGoal(Goal & goal) override {
    return getInput("target_pose", goal.pose);
  }

  BT::NodeStatus onResultReceived(const WrappedResult & result) override {
    return (result.code == rclcpp_action::ResultCode::SUCCEEDED)
      ? BT::NodeStatus::SUCCESS
      : BT::NodeStatus::FAILURE;
  }
};
```

## Action Server

```cpp
#include "rclcpp_action/rclcpp_action.hpp"

using MyTask = my_msgs::action::MyTask;
using GoalHandle = rclcpp_action::ServerGoalHandle<MyTask>;

rclcpp_action::Server<MyTask>::SharedPtr action_server_;

// Create in on_activate():
action_server_ = rclcpp_action::create_server<MyTask>(
  this, "my_task",
  [](const rclcpp_action::GoalUUID &, std::shared_ptr<const MyTask::Goal>) {
    return rclcpp_action::GoalResponse::ACCEPT_AND_EXECUTE;
  },
  [](std::shared_ptr<GoalHandle>) { return rclcpp_action::CancelResponse::ACCEPT; },
  [this](std::shared_ptr<GoalHandle> handle) {
    std::thread([this, handle]() { execute(handle); }).detach();
  });

void execute(std::shared_ptr<GoalHandle> handle) {
  auto feedback = std::make_shared<MyTask::Feedback>();
  auto result   = std::make_shared<MyTask::Result>();
  for (int i = 0; i <= 100 && rclcpp::ok(); ++i) {
    if (handle->is_canceling()) { result->success = false; handle->canceled(result); return; }
    feedback->progress = i / 100.0f;
    handle->publish_feedback(feedback);
    std::this_thread::sleep_for(std::chrono::milliseconds(50));
  }
  result->success = true;
  handle->succeed(result);
}
```

## Service Server

```cpp
rclcpp::Service<my_msgs::srv::MyService>::SharedPtr service_;

// Create in on_activate():
service_ = create_service<my_msgs::srv::MyService>(
  "my_service",
  [this](const std::shared_ptr<my_msgs::srv::MyService::Request> req,
         std::shared_ptr<my_msgs::srv::MyService::Response> res) {
    res->success = process(req);
  });
```
