#!/usr/bin/env bash

# ============================
# Setup Script Message Style
# ============================
set -e 

PURPLE='\033[0;35m' 
GREEN='\033[0;32m' 
YELLOW='\033[0;33m' 
RED='\033[0;31m' 
NC='\033[0m' 

info() { 
    echo -e "${PURPLE}[INFO]${NC} $1" 
    } 

success() { 
    echo -e "${GREEN}[SUCCESS]${NC} $1" 
    } 

warning() { 
    echo -e "${YELLOW}[WARNING]${NC} $1" 
    } 

error() { 
    echo -e "${RED}[ERROR]${NC} $1" >&2 
    } 

cmd() { 
    echo 
    echo -e "${PURPLE}================================${NC}" 
    echo -e "${PURPLE}$1${NC}" 
    echo -e "${PURPLE}================================${NC}" 
    }
# ============================

info "================================"
info "Installing Required Dependencies"
info "================================"

# Update the package list
sudo apt update

info "================================"
info "ROS2 Humble (LTS)"
info "================================"

cmd "Set locale"
sudo apt update && sudo apt install locales
sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8

cmd "Add ROS2 APT Repository"
sudo apt install software-properties-common
sudo add-apt-repository universe

sudo apt update && sudo apt install curl -y
export ROS_APT_SOURCE_VERSION=$(curl -s https://api.github.com/repos/ros-infrastructure/ros-apt-source/releases/latest | grep -F "tag_name" | awk -F'"' '{print $4}')
curl -L -o /tmp/ros2-apt-source.deb "https://github.com/ros-infrastructure/ros-apt-source/releases/download/${ROS_APT_SOURCE_VERSION}/ros2-apt-source_${ROS_APT_SOURCE_VERSION}.$(. /etc/os-release && echo ${UBUNTU_CODENAME:-${VERSION_CODENAME}})_all.deb"
sudo dpkg -i /tmp/ros2-apt-source.deb

cmd "Install Development Tools and ROS tools"
sudo apt update && sudo apt install -y \
  python3-flake8-docstrings \
  python3-pip \
  python3-pytest-cov \
  ros-dev-tools
  sudo rosdep init
rosdep update
rosdep install --from-paths src --ignore-src -y --skip-keys "fastcdr rti-connext-dds-6.0.1 urdfdom_headers"

info "================================"
info "Python Dependencies"
info "================================"

info "================================"
info "Gazebo Fortress (LTS)"
info "================================"


