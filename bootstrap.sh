#!/bin/bash

# ========================
#       Info Helpers
# ========================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # Reset to default colour

info() {
    printf '%b\n' "${PURPLE}[INFO]${NC} $1"
}

success() {
    printf '%b\n' "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    printf '%b\n' "${YELLOW}[WARNING]${NC} $1"
}

error() {
    printf '%b\n' "${RED}[ERROR]${NC} $1" >&2
}

bar() {
    printf '%b\n' "${CYAN}====================${NC}" >&2
}


# ========================

# ========================
#       CHECK OS
# ========================
bar
info "Checking OS"


if [[ -f /etc/os-release ]]; then 
    # Get Appropriate Variables
    source /etc/os-release

    echo "System: $NAME"
    echo "Version: $VERSION"
    
    if [[ "$ID" == "ubuntu" && "$VERSION_ID=" != "22.04" ]]; then
        success "Ubuntu 22.04 detected. ROS2 Humble is supported."
        info "Starting Linux Bootstrap"
        source scripts/environment/bootstrap_linux.sh
    else
        info "Ubutuntu 22.04 not detected. Entering Container."  
        source scripts/environment/setup_docker.sh
    fi
else 
    error "This System does not provide /etc/os-release."
fi

bar

bar
success "Bootstrap Setup Complete!"
bar