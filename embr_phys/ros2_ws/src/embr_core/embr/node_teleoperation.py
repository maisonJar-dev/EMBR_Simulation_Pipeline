#!/usr/bin/env python3
"""Read an iBUS RC receiver and publish four Maxon drivetrain levels."""

import time
from typing import Optional

import rclpy
from rclpy.node import Node
from std_msgs.msg import Float32MultiArray

from embr.embr_hardware.ibus import (
    ChannelCalibration,
    IBusStreamDecoder,
    channels_to_drive,
)


class Teleoperation(Node):
    """ROS 2 node responsible for EMBR teleoperation."""

    def __init__(self) -> None:
        super().__init__("teleoperation")
        self.declare_parameter("serial_port", "/dev/serial0")
        self.declare_parameter("baud_rate", 115200)
        self.declare_parameter("forward_channel", 1)
        self.declare_parameter("turn_channel", 0)
        self.declare_parameter("channel_min", 1000)
        self.declare_parameter("channel_center", 1500)
        self.declare_parameter("channel_max", 2000)
        self.declare_parameter("deadband", 0.04)
        self.declare_parameter("invert_forward", False)
        self.declare_parameter("invert_turn", False)
        self.declare_parameter("frame_timeout", 0.25)
        self.declare_parameter("poll_period", 0.01)

        self._forward_channel = int(self.get_parameter("forward_channel").value)
        self._turn_channel = int(self.get_parameter("turn_channel").value)
        self._invert_forward = bool(self.get_parameter("invert_forward").value)
        self._invert_turn = bool(self.get_parameter("invert_turn").value)
        self._frame_timeout = float(self.get_parameter("frame_timeout").value)
        self._calibration = ChannelCalibration(
            minimum=int(self.get_parameter("channel_min").value),
            center=int(self.get_parameter("channel_center").value),
            maximum=int(self.get_parameter("channel_max").value),
            deadband=float(self.get_parameter("deadband").value),
        )
        self._motor_publisher = self.create_publisher(
            Float32MultiArray, "motor_velocity_levels", 10
        )
        self._command_publisher = self.create_publisher(
            Float32MultiArray, "forward_turn_velocity", 10
        )
        self._decoder = IBusStreamDecoder()
        self._last_frame_time: Optional[float] = None
        self._failsafe_published = False
        self._serial = self._open_serial()
        self._timer = self.create_timer(
            float(self.get_parameter("poll_period").value), self._poll_receiver
        )
        self.get_logger().info(
            "iBUS teleoperation started; publishing motor order "
            "[front_left, rear_left, front_right, rear_right]"
        )

    def _open_serial(self):
        try:
            import serial
        except ImportError as exc:
            raise RuntimeError(
                "pyserial is required (install the ROS dependency python3-serial)"
            ) from exc

        port = str(self.get_parameter("serial_port").value)
        baud = int(self.get_parameter("baud_rate").value)
        try:
            return serial.Serial(port=port, baudrate=baud, timeout=0)
        except serial.SerialException as exc:
            raise RuntimeError(f"could not open iBUS serial port {port}: {exc}") from exc

    def _poll_receiver(self) -> None:
        try:
            waiting = self._serial.in_waiting
            if waiting:
                for channels in self._decoder.feed(self._serial.read(waiting)):
                    self._publish_channels(channels)
        except Exception as exc:
            # UART errors must lead to a stopped drivetrain. Throttle repeated logs.
            if not self._failsafe_published:
                self.get_logger().error(f"iBUS UART read failed: {exc}")
            self._last_frame_time = None

        now = time.monotonic()
        if (
            (self._last_frame_time is None or now - self._last_frame_time > self._frame_timeout)
            and not self._failsafe_published
        ):
            self._publish(0.0, 0.0, [0.0] * 4)
            self._failsafe_published = True
            self.get_logger().warn("iBUS frame timeout: publishing zero motor levels")

    def _publish_channels(self, channels) -> None:
        forward, turn, motors = channels_to_drive(
            channels,
            self._forward_channel,
            self._turn_channel,
            self._calibration,
            self._invert_forward,
            self._invert_turn,
        )
        self._last_frame_time = time.monotonic()
        self._failsafe_published = False
        self._publish(forward, turn, motors)

    def _publish(self, forward: float, turn: float, motors) -> None:
        command = Float32MultiArray()
        command.data = [float(forward), float(turn)]
        self._command_publisher.publish(command)

        motor_command = Float32MultiArray()
        motor_command.data = [float(level) for level in motors]
        self._motor_publisher.publish(motor_command)

    def destroy_node(self) -> None:
        if hasattr(self, "_serial") and self._serial.is_open:
            self._serial.close()
        super().destroy_node()


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
