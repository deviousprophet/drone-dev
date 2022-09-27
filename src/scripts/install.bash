#!/usr/bin/env bash -i
set -e
set -x

COLOR_RESET='\033[0m'     # Text Reset
GREEN='\033[1;32m'        # Light Green
YELLOW='\033[1;33m'       # Light Yellow
CYAN='\033[1;36m'         # Light Cyan

print_info () {
    echo -e "${GREEN}[INFO] $1${COLOR_RESET}"
}

print_warn () {
    echo -e "${YELLOW}[WARN] $1${COLOR_RESET}"
}

print_choice () {
    echo -e "${CYAN}[CHOICE] $1${COLOR_RESET}"
}

if (( $EUID == 0 )); then
    print_warn "Please don't run this script as root!"
    exit
fi

# Preventing sudo timeout. See https://serverfault.com/a/833888

trap "exit" INT TERM
trap "kill 0" EXIT
sudo -v || exit $?
sleep 1
while true; do
    sleep 60
    sudo -nv
done 2>/dev/null &

# Checking Distribution

print_info "Checking Distribution"

DISTRIB_DESCR="Unknown"

if command -v lsb_release &> /dev/null; then
    DISTRIB_DESCR="$(lsb_release -sd)"
fi

if [[ $DISTRIB_DESCR == "Ubuntu 20.04"* ]]; then
    print_info "Detected Distribution: $DISTRIB_DESCR [✓]"
else
    print_warn "This installation is recommended on 'Ubuntu 20.04 LTS'. Detected Distribution: $DISTRIB_DESCR"
    print_choice "Do you wish to continue anyway?"
    select opt in "Yes" "No"; do
        case $opt in
            "Yes")
                break;;
            "No")
                exit;;
        esac
    done
fi

INSTALL_ROS=false

print_info "Ardupilot with Gazebo plugins will be installed"
print_choice "Do you wish to install ROS and MAVROS?"
select opt in "Yes" "No" "Quit"; do
    case $opt in
        "Yes")
            INSTALL_ROS=true
            break;;
        "No")
            break;;
        "Quit")
            exit;;
    esac
done

INSTALL_DIR=`pwd`
DISTRO="noetic"

# 0. Prerequisites

print_info "Checking prerequisites"

if ! command -v git &> /dev/null; then
    echo "git could not be found"
    sudo apt update
    sudo apt install git -y
else
    echo "git found"
fi

# 1. Add to sources list

echo -ne "$INFO Adding to sources list\r"

sudo sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list'
wget http://packages.osrfoundation.org/gazebo.key -O - | sudo apt-key add -

if $INSTALL_ROS; then
    sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
    wget https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc -O - | sudo apt-key add -
fi

sudo apt update

# 2. Clone from git

print_info "Cloning from git"

ARDU_REPO_URL="https://github.com/deviousprophet/ardupilot"
ARDU_REPO_DIR="$INSTALL_DIR/ardupilot"

GAZEBO_REPO_URL="https://github.com/deviousprophet/ardupilot_gazebo"
GAZEBO_REPO_DIR="$INSTALL_DIR/ardupilot_gazebo"

git clone "$ARDU_REPO_URL" "$ARDU_REPO_DIR" || git -C "$ARDU_REPO_DIR" pull
git clone "$GAZEBO_REPO_URL" "$GAZEBO_REPO_DIR" || git -C "$GAZEBO_REPO_DIR" pull

# [Solved] fatal: detected dubious ownership in repository
git config --global --add safe.directory '*'

# 3. Install Ardupilot required packages

print_info "Installing Ardupilot required packages"

cd $ARDU_REPO_DIR
bash ./Tools/environment_install/install-prereqs-ubuntu.sh -y

# 4. Build & install gazebo plugin

print_info "Installing libgazebo11-dev"
sudo apt install -y libgazebo11-dev

print_info "Building gazebo plugin"
mkdir -p $GAZEBO_REPO_DIR/build
cd $GAZEBO_REPO_DIR/build
cmake ..
make -j4

print_info "Installing gazebo plugin"
sudo make install

EXPORT_LINE="source /usr/share/gazebo/setup.sh"
if ! grep -q "$EXPORT_LINE" ~/.bashrc; then
    echo "$EXPORT_LINE" >> ~/.bashrc
fi

EXPORT_LINE="export GAZEBO_MODEL_PATH=$GAZEBO_REPO_DIR/models"
if ! grep -q "$EXPORT_LINE" ~/.bashrc; then
    echo "$EXPORT_LINE" >> ~/.bashrc
fi

EXPORT_LINE="export GAZEBO_RESOURCE_PATH=$GAZEBO_REPO_DIR/worlds:\${GAZEBO_RESOURCE_PATH}"
if ! grep -q "$EXPORT_LINE" ~/.bashrc; then
    echo "$EXPORT_LINE" >> ~/.bashrc
fi

source ~/.bashrc

# 5. ROS Desktop-Full & MAVROS installation

if $INSTALL_ROS; then

    print_info "Installing ROS Desktop-Full & MAVROS"

    sudo apt install -y ros-$DISTRO-desktop-full python3-rosdep python3-rosinstall python3-rosinstall-generator python3-wstool build-essential

    source /opt/ros/noetic/setup.bash

    EXPORT_LINE="source /opt/ros/$DISTRO/setup.bash"
    if ! grep -q "$EXPORT_LINE" ~/.bashrc ; then
        echo "$EXPORT_LINE" >> ~/.bashrc
    fi

    source ~/.bashrc

    if [ ! -f /etc/ros/rosdep/sources.list.d/20-default.list ] ; then
        sudo rosdep init
    fi
    rosdep update

    sudo apt install -y ros-$DISTRO-mavros ros-$DISTRO-mavros-extras
    wget -O - https://raw.githubusercontent.com/mavlink/mavros/master/mavros/scripts/install_geographiclib_datasets.sh | sudo bash

    # Optional RQT install

    print_info "Installing optional RQT"
    sudo apt install -y ros-$DISTRO-rqt

else
    print_info "Skipping ROS installation"
fi

# 6. Finish

echo -e " ********************* ${GREEN}[✓] Installation completed${COLOR_RESET} ********************* "