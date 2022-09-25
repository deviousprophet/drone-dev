# Core ROS

## Installing and Configuring ROS Environment

### ROS Installing and Managing Environment

See [ROS Installation](./installation_ubuntu_20.04.md#ros)

### Create a ROS Workspace

```bash
mkdir -p ~/catkin_ws/src
cd ~/catkin_ws/
catkin_make
source devel/setup.bash
```