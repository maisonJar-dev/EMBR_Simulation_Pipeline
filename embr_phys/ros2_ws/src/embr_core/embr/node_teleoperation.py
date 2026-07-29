#!/usr/bin/env python3

# TODO: CREATE SIM AND REAL CLASSES
"""
    Sim class should take logic from the contoller Node located in embr_sim workspace,
    from there send the proper CANopen command and simulate moving the Maxon motors. 
    Priority List:
        1. Creat real logic for teleoperation i.bus frame reading & a blank sim logic class
        2. ...
        3. ...
""" 

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
