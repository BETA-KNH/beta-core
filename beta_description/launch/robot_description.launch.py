from pathlib import Path

from ament_index_python.packages import get_package_share_directory
from launch import LaunchDescription
from launch.actions import DeclareLaunchArgument
from launch.conditions import IfCondition
from launch.substitutions import Command, LaunchConfiguration, PathJoinSubstitution
from launch_ros.actions import Node
from launch_ros.substitutions import FindPackageShare


def generate_launch_description():
    pkg_share = get_package_share_directory("beta_description")
    urdf_file = Path(pkg_share) / "urdf" / "g1_23dof.urdf.xacro"

    robot_description = Command(["xacro ", str(urdf_file)])

    return LaunchDescription([
        DeclareLaunchArgument(
            "use_sim_time",
            default_value="false",
            description="Use simulation clock",
        ),
        DeclareLaunchArgument(
            "gui",
            default_value="true",
            description="Launch joint_state_publisher_gui",
        ),
        DeclareLaunchArgument(
            "rviz",
            default_value="true",
            description="Launch RViz",
        ),

        Node(
            package="robot_state_publisher",
            executable="robot_state_publisher",
            name="robot_state_publisher",
            output="screen",
            parameters=[{
                "robot_description": robot_description,
                "use_sim_time": LaunchConfiguration("use_sim_time"),
            }],
        ),

        Node(
            package="joint_state_publisher_gui",
            executable="joint_state_publisher_gui",
            name="joint_state_publisher_gui",
            output="screen",
            condition=IfCondition(LaunchConfiguration("gui")),
        ),

        Node(
            package="rviz2",
            executable="rviz2",
            name="rviz2",
            output="screen",
            arguments=[
                "-d",
                PathJoinSubstitution([
                    FindPackageShare("beta_description"),
                    "config",
                    "g1_23dof.rviz",
                ]),
            ],
            condition=IfCondition(LaunchConfiguration("rviz")),
        ),
    ])
