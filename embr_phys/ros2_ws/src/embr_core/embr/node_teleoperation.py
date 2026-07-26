#!/usr/bin/env python3

import rclpy
from rclpy.node import Node


class Teleoperation(Node):
    """ROS 2 node responsible for EMBR teleoperation."""

    def __init__(self) -> None:
        super().__init__("teleoperation")
        self.get_logger().info("Teleoperation node started")


def main(args=None) -> None:
    rclpy.init(args=args)
    node = Teleoperation()

    try:
        rclpy.spin(node)
    except KeyboardInterrupt:
        pass
    finally:
        node.destroy_node()
        if rclpy.ok():
            rclpy.shutdown()


if __name__ == "__main__":
    main()
