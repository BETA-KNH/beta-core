# ROS2 Perception Patterns

## PointCloud2 Subscriber (LiDAR)

```cpp
#include "sensor_msgs/msg/point_cloud2.hpp"
#include "sensor_msgs/point_cloud2_iterator.hpp"

// Always use SensorDataQoS for LiDAR — drops stale scans, low latency
sub_cloud_ = create_subscription<sensor_msgs::msg::PointCloud2>(
  "/pointcloud", rclcpp::SensorDataQoS(),
  [this](sensor_msgs::msg::PointCloud2::UniquePtr msg) {
    // UniquePtr avoids a copy — preferred for large messages
    process_cloud(std::move(msg));
  });

void process_cloud(sensor_msgs::msg::PointCloud2::UniquePtr cloud) {
  sensor_msgs::PointCloud2Iterator<float> iter_x(*cloud, "x");
  sensor_msgs::PointCloud2Iterator<float> iter_y(*cloud, "y");
  sensor_msgs::PointCloud2Iterator<float> iter_z(*cloud, "z");
  for (; iter_x != iter_x.end(); ++iter_x, ++iter_y, ++iter_z) {
    float x = *iter_x, y = *iter_y, z = *iter_z;
  }
}
```

## Image Subscriber (Camera)

```cpp
#include "image_transport/image_transport.hpp"
#include "cv_bridge/cv_bridge.hpp"

// In on_configure():
image_transport::ImageTransport it(shared_from_this());
sub_image_ = it.subscribe("/camera/image_raw", 1,
  [this](const sensor_msgs::msg::Image::ConstSharedPtr & msg) {
    cv::Mat frame = cv_bridge::toCvShare(msg, "bgr8")->image;
    // process frame
  });
```

## TF2 Transforms

```cpp
#include "tf2_ros/transform_listener.hpp"
#include "tf2_ros/buffer.hpp"
#include "tf2_geometry_msgs/tf2_geometry_msgs.hpp"

// In class members:
std::shared_ptr<tf2_ros::Buffer> tf_buffer_;
std::shared_ptr<tf2_ros::TransformListener> tf_listener_;

// In on_configure():
tf_buffer_ = std::make_shared<tf2_ros::Buffer>(get_clock());
tf_listener_ = std::make_shared<tf2_ros::TransformListener>(*tf_buffer_);

// Lookup transform:
try {
  auto transform = tf_buffer_->lookupTransform(
    "base_link", "camera_link", tf2::TimePointZero);
  geometry_msgs::msg::PointStamped pt_out;
  tf2::doTransform(pt_in, pt_out, transform);
} catch (const tf2::TransformException & ex) {
  RCLCPP_WARN(get_logger(), "TF lookup failed: %s", ex.what());
}
```

## Synchronized Subscribers (message_filters)

```cpp
#include "message_filters/subscriber.hpp"
#include "message_filters/sync_policies/approximate_time.hpp"
#include "message_filters/synchronizer.hpp"

using SyncPolicy = message_filters::sync_policies::ApproximateTime<
  sensor_msgs::msg::Image, sensor_msgs::msg::CameraInfo>;

message_filters::Subscriber<sensor_msgs::msg::Image> sub_image_;
message_filters::Subscriber<sensor_msgs::msg::CameraInfo> sub_info_;
std::shared_ptr<message_filters::Synchronizer<SyncPolicy>> sync_;

// In on_configure():
sub_image_.subscribe(this, "/camera/image_raw");
sub_info_.subscribe(this, "/camera/camera_info");
sync_ = std::make_shared<message_filters::Synchronizer<SyncPolicy>>(
  SyncPolicy(10), sub_image_, sub_info_);
sync_->registerCallback(std::bind(&MyNode::image_cb, this,
  std::placeholders::_1, std::placeholders::_2));
```

## IMU Subscriber

```cpp
#include "sensor_msgs/msg/imu.hpp"

sub_imu_ = create_subscription<sensor_msgs::msg::Imu>(
  "/imu/data", rclcpp::SensorDataQoS(),
  [this](const sensor_msgs::msg::Imu::ConstSharedPtr & msg) {
    double roll, pitch, yaw;
    tf2::Quaternion q(msg->orientation.x, msg->orientation.y,
                      msg->orientation.z, msg->orientation.w);
    tf2::Matrix3x3(q).getRPY(roll, pitch, yaw);
  });
```
