# Drone Development

Drone Development with Ardupilot, Gazebo, ROS on Linux/Ubuntu 20.04 LTS

## Installation

- [Ubuntu 20.04 LTS](./docs/installation_ubuntu_20.04.md)

## Run simulation

Create simulation directory
```bash
mkdir ~/sim_dir
```

### On 1st Terminal
Launch Ardupilot SITL
```bash
cd ~/sim_dir
sim_vehicle.py -v ArduCopter -f gazebo-iris --console
```

### On 2nd Terminal
Launch simulator with demo 3DR Iris model

- By `ardupilot_gazebo` plugin

    ```bash
    gazebo --verbose worlds/iris_arducopter_runway.world
    ```

- By `gazebo_ros` packages (require ROS and MAVROS installed)

    Download the launch file
    ```bash
    cd ~/sim_dir
    wget https://raw.githubusercontent.com/deviousprophet/drone-dev/main/src/launch/runway.launch
    ```

    ```bash
    roslaunch runway.launch fcu_url:=udp://127.0.0.1:14551@ world_name:=worlds/iris_arducopter_runway.world
    ```

## Troubleshooting

See [Troubleshooting](./docs/troubleshooting.md)