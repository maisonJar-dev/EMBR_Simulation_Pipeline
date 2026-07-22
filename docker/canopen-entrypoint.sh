#!/bin/bash
set -e

CANOPEN_WS="${CANOPEN_WS:-/workspace/canopen_ws}"

source "/opt/ros/${ROS_DISTRO:-humble}/setup.bash"

# A bind-mounted workspace does not contain the image's build artifacts on its
# first run, so build it before starting the requested command.
if [ ! -f "${CANOPEN_WS}/install/setup.bash" ]; then
    echo "Building CANopen workspace..."
    cd "${CANOPEN_WS}"
    colcon build --symlink-install
fi

source "${CANOPEN_WS}/install/setup.bash"

echo "ROS 2 ${ROS_DISTRO:-humble} CANopen simulation environment is ready."
echo "Workspace: ${CANOPEN_WS}"
echo "SocketCAN interfaces:"
ip -brief link show type can 2>/dev/null || true

exec "$@"
