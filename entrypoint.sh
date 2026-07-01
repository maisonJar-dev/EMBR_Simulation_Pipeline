#!/bin/bash
set -e

# Source Helper File
source "/home/${USERNAME}/scripts/environment/info_helpers.sh"
# Source ROS 2
source /opt/ros/humble/setup.bash

# Build workspace if not already built (for volume mounts)
if [ ! -f "/home/$USERNAME/ros2_ws/install/setup.bash" ]; then
    echo "Building ROS2 workspace (first run with volume mount)..."
    cd /home/$USERNAME/ros2_ws
    colcon build --symlink-install
    echo "Build complete!"
fi

# Source workspace
source /home/$USERNAME/ros2_ws/install/setup.bash

bar
info "EMBR-Bot Docker Container - Control System Development Mode"
bar
success "ROS 2 Humble is ready!"
info    "Workspace: /home/$USERNAME/ros2_ws"
bar

# Execute command
exec "$@"