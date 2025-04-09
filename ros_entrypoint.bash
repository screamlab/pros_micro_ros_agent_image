#!/bin/bash
set -e

# setup ros2 environment
source /root/.bashrc
source "/opt/ros/$ROS_DISTRO/setup.bash" --
if [ -f "$ROS2_WS/install/setup.bash" ]; then
    source "$ROS2_WS/install/setup.bash"
else
    echo "Warning: setup.bash not found!"
fi
source /root/ws_micro_ros/install/setup.bash
exec "$@"
