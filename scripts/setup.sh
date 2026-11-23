#!/usr/bin/env bash
set -euo pipefail

echo "== Parallel Computing Lab: Ubuntu setup =="

if [[ ! -f /etc/os-release ]] || ! grep -qi ubuntu /etc/os-release; then
    echo "Warning: this setup script is intended for Ubuntu."
fi

if ! command -v apt-get >/dev/null 2>&1; then
    echo "Error: apt-get not found. This script expects Ubuntu/Debian."
    exit 1
fi

echo
echo "[1/4] Updating package lists..."
sudo apt-get update

echo
echo "[2/4] Installing GCC, make, OpenMP-capable GCC and OpenMPI..."
sudo apt-get install -y build-essential gcc openmpi-bin libopenmpi-dev

echo
echo "[3/4] Checking compiler/runtime versions..."
gcc --version | head -n 1
mpicc --version | head -n 1
mpirun --version | head -n 1

echo
echo "[4/4] Setting executable permissions..."
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
chmod +x "$ROOT_DIR/run.sh" "$ROOT_DIR/scripts/"*.sh

echo
echo "Setup complete."
echo "OpenMP compile flag: -fopenmp"
echo "MPI compiler:        mpicc"
echo "MPI launcher:        mpirun"
echo
echo "Try: ./run.sh p1"
