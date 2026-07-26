#!/bin/bash

set -e          # stop on unhandled command failure
set -u          # error on unset variables
set -o pipefail # fail a pipeline if any command in it fails

# ========================
#       Info Helpers
# ========================
 
source scripts/environment/info_helpers.sh

# ========================

source scripts/environment/logo.sh

# ========================
#       Setup Init
# ========================
bar

info "SETUP INITIALIZED"
source scripts/environment/setup_docker.sh

bar

bar
success "Bootstrap Setup Complete!"
bar