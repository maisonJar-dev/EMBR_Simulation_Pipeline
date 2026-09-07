# TODO: Should handle the control logic of the maxon motors 

import rclpy
from rclpy.node import Node

from std_msgs.msg import Float64
from embr_interfaces.msg import TeleCmd

class MaxonTeleopControlSystem(Node):

    def __init__(self):
        super().__init__('maxon_teleop_control_system')

        self._tele_subscriber = self.create_subscription(
            TeleCmd,
            'tele_cmd',
            self.motor_velocity_callback,
            10
        )

        self._tele_subscriber # Avoid unused variable warning

    def motor_velocity_callback(self, msg):
        self.get_logger().info(f"Velocity: {msg.velocity}, Turn: {msg.turn}")

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