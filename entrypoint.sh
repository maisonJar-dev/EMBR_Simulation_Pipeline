#!/bin/bash
set -e

# Source Helper File
source "/home/${USERNAME}/scripts/environment/info_helpers.sh"
# Source ROS 2
source /opt/ros/humble/setup.bash

ROS_WS="${ROS_WS:-/workspace/ros2_ws}"

# Build workspace if not already built (for volume mounts)
if [ ! -f "$ROS_WS/install/setup.bash" ]; then
    echo "Building ROS2 workspace (first run with volume mount)..."
    mkdir -p "$ROS_WS/src"
    cd "$ROS_WS"
    colcon build --symlink-install
    echo "Build complete!"
fi

# Source workspace
source "$ROS_WS/install/setup.bash"

bar
info "EMBR-Bot Docker Container - Control System Development Mode"
bar
success "ROS 2 Humble is ready!"
info    "Workspace: $ROS_WS"
bar

# Execute command
exec "$@"
