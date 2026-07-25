from launch import LaunchDescription
from launch.substitutions import Command, FindExecutable, PathJoinSubstitution
from launch_ros.actions import Node
from launch_ros.substitutions import FindPackageShare


def generate_launch_description():
    package_share = FindPackageShare("embr_description")
    model_path = PathJoinSubstitution(
        [package_share, "urdf", "maxon_motor", "urdf", "maxon_motor.urdf.xacro"]
    )
    rviz_config = PathJoinSubstitution(
        [package_share, "rviz", "maxon_motor.rviz"]
    )

    return LaunchDescription(
        [
            Node(
                package="robot_state_publisher",
                executable="robot_state_publisher",
                parameters=[
                    {
                        "robot_description": Command(
                            [FindExecutable(name="xacro"), " ", model_path]
                        )
                    }
                ],
                output="screen",
            ),
            Node(
                package="joint_state_publisher_gui",
                executable="joint_state_publisher_gui",
                output="screen",
            ),
            Node(
                package="rviz2",
                executable="rviz2",
                arguments=["-d", rviz_config],
                output="screen",
            ),
        ]
    )
