# pros_micro_ros_agent_image
This project builds a multiarch micro ROS agent docker image for both amd64 and arm64 with ROS2 humble. All rights reserved.



## Scheduled GitHub Action CI (Deprecated)

The GitHub Action has been set to run at 00:00 on the second of every month. This can help us to keep updating from the base image `ros:humble-ros-core-jammy`.

The tag of the Docker image has 2 formats:

- 0.0.0
  - This is triggered by adding new tag manually.
- 0.0.0-20241002
  - This is triggered by `cron` which is set in the `yaml` file.



## System Architecture

The system architecture is shown in the [LucidChart](https://lucid.app/lucidchart/521741b7-d1f5-44d3-a668-399a7c6a1aa1/edit?viewport_loc=-419%2C31%2C2560%2C1306%2CHWEp-vi-RSFO&invitationId=inv_5adc6c69-ef18-4193-9fe0-5a488a745e8c).



## Shortcut

- `r`: Do `colcon build` and `source` the `setup.bash` in the `/workspaces` folder.
- `b`: launch ros bridge server
- `m`: `make -j`



## Colcon

We've written a run command `rebuild_colcon.rc` in `/workspaces` folder. You can do `colcon build` and `source /workspaces/install/setup.bash` by the following command:

```bash
source /workspaces/rebuild_colcon.rc
```



### <font color=#FF0000>Shortcut</font> for Colcon

We have written the command `source /workspaces/rebuild_colcon.rc` as an alias <font color=#FF0000>'r'</font> in both `/root/.bashrc` and `/root/.zshrc`. Users only need to <font color=#FF0000>type 'r' to execute the command</font>.



## Reference

The reference of `src/csm` is probably https://github.com/clearpathrobotics/csm/tree/catkinize_csm_eigen. However, there are several differences shown below and thus we don't use submodule here.

```
❯ diff -rq csm pros_jetson_driver_image/src/csm

Files csm/CMakeLists.txt and pros_jetson_driver_image/src/csm/CMakeLists.txt differ
Only in csm: .git
Files csm/.gitignore and pros_jetson_driver_image/src/csm/.gitignore differ
Files csm/package.xml and pros_jetson_driver_image/src/csm/package.xml differ
Files csm/README.md and pros_jetson_driver_image/src/csm/README.md differ
Only in pros_jetson_driver_image/src/csm: resource
Files csm/src/csm/orientation.cpp and pros_jetson_driver_image/src/csm/src/csm/orientation.cpp differ
```



## Manually build the image

### Environments Setup

1. To use buildx, make sure your Docker runtime is at least version 19.03. buildx actually comes bundled with Docker by default, but needs to be enabled by setting the environment variable DOCKER_CLI_EXPERIMENTAL.

   ```bash
   export DOCKER_CLI_EXPERIMENTAL=enabled
   ```

2. If you're on Linux, you need to set up `binfmt_misc`. This is pretty easy in most distributions but is even easier now that you can just run a privileged Docker container to set it up for you.

   ```bash
   docker run --rm --privileged tonistiigi/binfmt:latest
   ```

   or

    ```bash
   docker run --rm --privileged docker/binfmt:latest
    ```

3. Create a new builder which gives access to the new multi-architecture features. This command creates a new builder instance. In this case, it supports both linux/arm64 and linux/amd64 platforms. The --name flag sets a name for the builder- "multi-platform-builder".

   ```bash
   docker buildx create --use --platform=linux/arm64,linux/amd64 --name multi-platform-builder
   ```

4. This command inspects the builder created in the previous step and performs any necessary setup or configuration. The --bootstrap flag indicates that the builder should be initialized if it hasn't been already

   ```bash
   docker buildx inspect --bootstrap
   ```

5. This command builds a Docker image using the builder created earlier.

   ```bash
   docker buildx build --platform=linux/arm64,linux/amd64 --push --tag ghcr.io/otischung/pros_ai_image:latest -f ./Dockerfile .
   ```


Reference: https://stackoverflow.com/questions/70757791/build-linux-arm64-docker-image-on-linux-amd64-host

Reference: https://unix.stackexchange.com/questions/748633/error-multiple-platforms-feature-is-currently-not-supported-for-docker-driver



### Troubleshooting

If you encounter that you can't build Dockerfile for arm64 due to `libc-bin` segmentation fault, try solve by the following instrucitons.

```bash
docker pull tonistiigi/binfmt:latest
docker run --privileged --rm tonistiigi/binfmt --uninstall qemu-*
docker run --privileged --rm tonistiigi/binfmt --install all)
```

Reference: https://askubuntu.com/questions/1339558/cant-build-dockerfile-for-arm64-due-to-libc-bin-segmentation-fault



## Log

- `ros2_laser_scan_matcher`

  ```
  #17 116.6 --- stderr: ros2_laser_scan_matcher
  #17 116.6 In file included from /workspaces/src/ros2_laser_scan_matcher/include/ros2_laser_scan_matcher/laser_scan_matcher.h:47,
  #17 116.6                  from /workspaces/src/ros2_laser_scan_matcher/src/laser_scan_matcher.cpp:38:
  #17 116.6 /opt/ros/humble/include/tf2_geometry_msgs/tf2_geometry_msgs/tf2_geometry_msgs.h:35:2: warning: #warning This header is obsolete, please include tf2_geometry_msgs/tf2_geometry_msgs.hpp instead [-Wcpp]
  #17 116.6    35 | #warning This header is obsolete, please include tf2_geometry_msgs/tf2_geometry_msgs.hpp instead
  #17 116.6       |  ^~~~~~~
  #17 116.6 ---
  #17 116.6 Finished <<< ros2_laser_scan_matcher [22.3s]
  #17 116.8 
  #17 116.8 Summary: 1 package finished [22.6s]
  #17 116.8   1 package had stderr output: ros2_laser_scan_matcher
  ```

  

- `slam_toolbox`

  We need to build slam toolbox because the default version for ROS2 humble isn't up-to-date.

  ```
  #17 117.4 [0.437s] WARNING:colcon.colcon_core.package_selection:Some selected packages are already built in one or more underlay workspaces:
  #17 117.4 	'slam_toolbox' is in: /opt/ros/humble
  #17 117.4 If a package in a merged underlay workspace is overridden and it installs headers, then all packages in the overlay must sort their include directories by workspace order. Failure to do so may result in build failures or undefined behavior at run time.
  #17 117.4 If the overridden package is used by another package in any underlay, then the overriding package in the overlay must be API and ABI compatible or undefined behavior at run time may occur.
  #17 117.4 
  #17 117.4 If you understand the risks and want to override a package anyways, add the following to the command line:
  #17 117.4 	--allow-overriding slam_toolbox
  #17 117.4 
  #17 117.4 This may be promoted to an error in a future release of colcon-override-check.
  ```



- `rplidar_ros`

  See `logs/rplidar_ros.log` in this repository.

