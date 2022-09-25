| Target | Ubuntu 20.04 LTS |
| ------ | ---------------- |

# Quick Installation

```bash
bash <(curl https://raw.githubusercontent.com/deviousprophet/drone-dev/main/src/scripts/install.bash) && . ~/.profile
```

# Manual Installation

## Ardupilot

Clone ArduPilot repository
```bash
git clone https://github.com/deviousprophet/ardupilot.git
```

Install some required packages
```bash
cd ardupilot
./Tools/environment_install/install-prereqs-ubuntu.sh -y
```

Reload the path
```bash
. ~/.profile
```

---

## Gazebo

Install `libgazebo11-dev`
```bash
sudo sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list'
wget http://packages.osrfoundation.org/gazebo.key -O - | sudo apt-key add -
sudo apt update
sudo apt install -y libgazebo11-dev
```

Clone, build & install
```bash
git clone https://github.com/deviousprophet/ardupilot_gazebo.git
cd ardupilot_gazebo
mkdir build
cd build
cmake ..
make -j4
sudo make install
echo 'source /usr/share/gazebo/setup.sh' >> ~/.bashrc
```

Set Path of Gazebo Models (Adapt the path to where to clone the repo)
```bash
echo 'export GAZEBO_MODEL_PATH=~/ardupilot_gazebo/models' >> ~/.bashrc
```

Set Path of Gazebo Worlds (Adapt the path to where to clone the repo)
```bash
echo 'export GAZEBO_RESOURCE_PATH=~/ardupilot_gazebo/worlds:${GAZEBO_RESOURCE_PATH}' >> ~/.bashrc
```

```bash
source ~/.bashrc
```

---

## ROS
Desktop-Full Install
```bash
sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -
sudo apt update
sudo apt install -y ros-noetic-desktop-full
```

Environment setup
```bash
source /opt/ros/noetic/setup.bash
echo "source /opt/ros/noetic/setup.bash" >> ~/.bashrc
source ~/.bashrc
```

Install dependencies for building packages
```bash
sudo apt install -y python3-rosdep python3-rosinstall python3-rosinstall-generator python3-wstool build-essential
```

Initialize `rosdep`
```bash
sudo rosdep init
rosdep update
```

---

## MAVROS
Install binary packages
```bash
sudo apt install -y ros-noetic-mavros ros-noetic-mavros-extras
```

Install GeographicLib datasets
```bash
wget https://raw.githubusercontent.com/mavlink/mavros/master/mavros/scripts/install_geographiclib_datasets.sh
chmod a+x install_geographiclib_datasets.sh
sudo ./install_geographiclib_datasets.sh && sudo rm ./install_geographiclib_datasets.sh
```

For ease of use on a desktop computer, install RQT
```bash
sudo apt install -y ros-noetic-rqt
```
