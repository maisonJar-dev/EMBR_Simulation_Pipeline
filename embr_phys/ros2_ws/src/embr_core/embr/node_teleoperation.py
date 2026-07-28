#!/usr/bin/env python3

# TODO: CREATE SIM AND REAL CLASSES
"""
    Sim class should take logic from the contoller Node located in embr_sim workspace,
    from there send the proper CANopen command and simulate moving the Maxon motors. 
    Priority List:
        1. Creat sim logic for virtual CANopen & a blank real class
        2. Test receiving command from controller node and sending on virtual-CANopen (should be able to see desired output somewhere)
        3. Visualize in Gazebo
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
