#!/bin/sh
# Best-effort, non-fatal attempt to get a working `az` CLI into the project
# directory without root and without a pre-existing pip3. Never exits non-zero
# so it can never break the overall build/deploy.

echo "--- attempting local azure-cli install (no root, no system pip) ---"

INSTALL_DIR="$(pwd)/azure-cli-local"
PIP_BOOTSTRAP_DIR="/tmp/pip-bootstrap"

if ! command -v python3 >/dev/null 2>&1; then
  echo "az-install: no python3, aborting attempt"
  exit 0
fi

if command -v pip3 >/dev/null 2>&1; then
  echo "az-install: system pip3 found"
  PIP_RUN="pip3"
else
  echo "az-install: no system pip3, bootstrapping via get-pip.py"
  if ! curl -sS https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py; then
    echo "az-install: failed to download get-pip.py, aborting attempt"
    exit 0
  fi
  if ! python3 /tmp/get-pip.py --target="$PIP_BOOTSTRAP_DIR" >/tmp/get-pip.log 2>&1; then
    echo "az-install: get-pip.py bootstrap failed, see log:"
    cat /tmp/get-pip.log
    exit 0
  fi
  echo "az-install: pip bootstrap succeeded"
  PIP_RUN="python3 -m pip"
  export PYTHONPATH="$PIP_BOOTSTRAP_DIR"
fi

echo "az-install: installing azure-cli into $INSTALL_DIR (this can take a while)"
if PYTHONPATH="${PYTHONPATH:-}" $PIP_RUN install --target="$INSTALL_DIR" azure-cli >/tmp/az-install.log 2>&1; then
  echo "az-install: azure-cli package install succeeded"
  du -sh "$INSTALL_DIR" 2>&1 || true
else
  echo "az-install: azure-cli package install FAILED, tail of log:"
  tail -n 40 /tmp/az-install.log
  exit 0
fi

echo "--- verifying az is importable right after install (still in build) ---"
PYTHONPATH="$INSTALL_DIR" python3 -c "from azure.cli.core.__main__ import main; import sys; sys.argv=['az','version']; main()" 2>&1 || echo "az-install: import/run check failed"
