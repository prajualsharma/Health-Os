#!/usr/bin/env bash
# 24h Always Free A1.Flex retry daemon for Health-Os.
set -euo pipefail
export PATH="${HOME}/lib/oracle-cli/bin:${PATH}"
export SUPPRESS_LABEL_WARNING=True
export MAX_ATTEMPTS=1440
export RETRY_DELAY_SEC=60
export SHAPE=VM.Standard.A1.Flex
export OCPUS=1
export MEMORY_GB=6
export BOOT_VOLUME_GB=50
cd "$(dirname "$0")/.."
exec bash deploy/oracle-create-instance.sh
