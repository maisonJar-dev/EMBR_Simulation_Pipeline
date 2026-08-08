# Raspberry Pi 4B iBUS teleoperation

The `teleoperation` node reads standard FlySky/Turnigy iBUS servo frames and publishes:

- `motor_velocity_levels` (`std_msgs/Float32MultiArray`): normalized values in the order
  `[front_left, rear_left, front_right, rear_right]`.
- `forward_turn_velocity` (`std_msgs/Float32MultiArray`): normalized
  `[forward, turn]`, primarily for diagnostics.

Both topics use values from `-1.0` to `1.0`. The Maxon/CANopen node should convert
these levels to its configured safe motor speed. If no valid frame is received for
`frame_timeout` seconds, all values are set to zero.

## Wiring

On a Raspberry Pi 4B, connect the receiver's iBUS signal to GPIO15/RXD0 (physical
pin 10) and connect receiver ground to Pi ground. GPIO14/TXD0 (physical pin 8) is
not required because iBUS telemetry is not transmitted by this node.

Raspberry Pi GPIO is **3.3 V only**. Confirm the receiver's iBUS signal level; use
a level shifter or resistor divider if it outputs 5 V. Power the receiver from a
suitable regulated supply and share ground with the Pi. Do not power motors from
the Pi.

Enable the hardware UART with `raspi-config` (disable the serial login shell and
enable the serial port), then reboot. `/dev/serial0` is the preferred stable device
alias. Ensure the ROS user belongs to the group allowed to access that device
(commonly `dialout`).

## Run

Build/source the workspace, then run:

```sh
ros2 run embr_core teleoperation --ros-args \
  -p serial_port:=/dev/serial0 \
  -p forward_channel:=1 \
  -p turn_channel:=0
```

Channel indexes are zero-based. Other parameters include `channel_min`,
`channel_center`, `channel_max`, `deadband`, `invert_forward`, `invert_turn`, and
`frame_timeout`. Keep the wheels clear of the ground while confirming channel
order, direction, and failsafe behavior.

## Terminal simulation mode

To publish commands without an iBUS receiver or serial port, run:

```sh
ros2 run embr_core teleoperation --sim
```

The `-sim` spelling is also accepted. Press `W`/`S` to increment or decrement
forward motion, `A`/`D` to increment or decrement turning, space to stop, and `Q`
to stop and exit. Commands use the same `motor_velocity_levels` and
`forward_turn_velocity` topics as hardware mode. The increment defaults to `0.1`
and can be changed with, for example:

```sh
ros2 run embr_core teleoperation --sim --ros-args -p sim_step:=0.25
```
