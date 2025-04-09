FROM registry.screamtrumpet.csie.ncku.edu.tw/pros_images/pros_base_image:latest
ENV ROS2_WS=/workspaces
ENV WS_MICRO_ROS=/root/ws_micro_ros
ENV ROS_DOMAIN_ID=1
ENV ROS_DISTRO=humble
ARG THREADS=4
ARG TARGETPLATFORM

SHELL ["/bin/bash", "-c"]

##### System Upgrade #####
RUN apt update && \
    apt upgrade -y && \
    apt autoremove -y && \
    apt autoclean -y && \
    pip3 install --no-cache-dir --upgrade pip

##### colcon Installation #####
# Prepare Source Code
RUN mkdir -p ${WS_MICRO_ROS}/src
WORKDIR ${WS_MICRO_ROS}/src
RUN git clone -b humble https://github.com/micro-ROS/micro-ROS-Agent.git && \
    apt update && \

# Bootstrap rosdep and setup colcon mixin and metadata ###
    rosdep update --rosdistro $ROS_DISTRO && \
    colcon mixin update && \
    colcon metadata update

# Install the system dependencies for all ROS packages located in the `src` directory.
RUN rosdep install -q -y -r --from-paths . --ignore-src --rosdistro $ROS_DISTRO

### Moveit2 Installation ###
WORKDIR ${WS_MICRO_ROS}
RUN source /opt/ros/$ROS_DISTRO/setup.bash && \
    colcon build --mixin release && \
    echo "source ${WS_MICRO_ROS}/install/setup.bash" >> /root/.bashrc

##### Post-Settings #####
WORKDIR ${ROS2_WS}

# Update entrypoint
COPY ./ros_entrypoint.bash /ros_entrypoint.bash
RUN chmod +x /ros_entrypoint.bash && \

# Clear tmp and cache
    rm -rf /tmp/* && \
    rm -rf /temp/* && \
    rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/ros_entrypoint.bash"]
CMD ["bash", "-l"]
