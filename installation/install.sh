#!/bin/bash
# DEBUG MODE:
set -euo pipefail
. ./.env
. ./.install-lib.sh



create_hoopad_user || true
install_apt_deps
install_pip_deps
enable_wanpad_services
start_wanpad_services
