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