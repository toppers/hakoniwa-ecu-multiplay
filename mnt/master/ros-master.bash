#!/bin/bash

source /opt/ros/foxy/setup.bash

# ROS2 does not require roscore
# The ROS2 daemon will start automatically when needed
ros2 daemon start

# Keep the script running
echo "ROS2 daemon started. Press Ctrl+C to stop."
tail -f /dev/null
