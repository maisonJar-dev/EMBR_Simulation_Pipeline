#!/bin/bash
set -e

EMBR_PHYS_WS="${EMBR_PHYS_WS:-/workspace/embr_phys_ws}"
EMBR_SIM_WS="${EMBR_SIM_WS:-/workspace/embr_sim_ws}"

source "/opt/ros/${ROS_DISTRO:-humble}/setup.bash"

# The physical workspace is an underlay shared by real-robot and simulation
# environments. A bind mount may not contain build artifacts on first run.
if [ ! -f "${EMBR_PHYS_WS}/install/setup.bash" ]; then
    echo "Building EMBR physical workspace..."
    cd "${EMBR_PHYS_WS}"
    colcon build --symlink-install
fi

source "${EMBR_PHYS_WS}/install/setup.bash"

if [ ! -f "${EMBR_SIM_WS}/install/setup.bash" ]; then
    echo "Building EMBR simulation workspace..."
    cd "${EMBR_SIM_WS}"
    colcon build --symlink-install
fi

source "${EMBR_SIM_WS}/install/setup.bash"

echo "ROS 2 ${ROS_DISTRO:-humble} CANopen simulation environment is ready."
echo "Physical workspace: ${EMBR_PHYS_WS}"
echo "Simulation workspace: ${EMBR_SIM_WS}"
echo "SocketCAN interfaces:"
ip -brief link show type can 2>/dev/null || true

exec "$@"
