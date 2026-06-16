#!/bin/bash

# ========================
#       Info Helpers
# ========================
 
source scripts/environment/info_helpers.sh

# ========================

source scripts/environment/logo.sh

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