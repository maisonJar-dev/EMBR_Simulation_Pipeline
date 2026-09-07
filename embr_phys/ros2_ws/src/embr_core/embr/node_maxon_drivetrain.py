# TODO: Should handle the control logic of the maxon motors 

import rclpy
from rclpy.node import Node

from std_msgs.msg import Float32MultiArray

class MaxonTeleopControlSystem(Node):

    def __init__(self):
        super().__init__('maxon_teleop_control_system')

        self._motor_subscriber = self.create_subscription(
            Float32MultiArray,
            'forward_turn_velocity',
            self.motor_velocity_callback,
            10
        )

        self._motor_subscriber # Avoid unused variable warning

    def motor_velocity_callback(self, msg):
        self.get_logger().info("Motor Commands: %s" % msg.data)

def main(args=None):
    rclpy.init(args=args)

    node = MaxonTeleopControlSystem()

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