# EMBR Physical Layer

This directory contains ROS 2 packages that describe or operate the physical
robot without depending on a simulator.

Build `ros2_ws` as the base workspace for both real-robot and simulation
environments. Simulation-specific packages in `../embr_sim/ros2_ws` consume it
as an underlay.
