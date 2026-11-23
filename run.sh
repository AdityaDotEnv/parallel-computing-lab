#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$ROOT_DIR/src"
BUILD_DIR="$ROOT_DIR/build"

usage() {
    cat <<'EOF'
Usage:
  ./run.sh p1 [program arguments]
  ./run.sh p2 [program arguments]
  ...
  ./run.sh p9 [program arguments]

Optional environment variables:
  OMP_NUM_THREADS=4 ./run.sh p1
  MPI_NP=4 ./run.sh p7

Programs:
  p1  OpenMP merge sort
  p2  OpenMP static scheduling
  p3  OpenMP Fibonacci tasks
  p4  OpenMP prime numbers
  p5  MPI send/receive (2 processes)
  p6  MPI deadlock / deadlock avoidance (2 processes)
  p7  MPI broadcast (4 processes by default)
  p8  MPI scatter/gather (4 processes by default)
  p9  MPI reduce/allreduce (4 processes by default)

Use ./run.sh list to list programs.
EOF
}

list_programs() {
    printf '%-4s %-38s %s\n' "ID" "PROGRAM" "TYPE"
    printf '%-4s %-38s %s\n' "p1" "Merge Sort" "OpenMP"
    printf '%-4s %-38s %s\n' "p2" "Static Scheduling" "OpenMP"
    printf '%-4s %-38s %s\n' "p3" "Fibonacci Tasks" "OpenMP"
    printf '%-4s %-38s %s\n' "p4" "Prime Numbers" "OpenMP"
    printf '%-4s %-38s %s\n' "p5" "Send and Receive" "MPI"
    printf '%-4s %-38s %s\n' "p6" "Deadlock / Avoidance" "MPI"
    printf '%-4s %-38s %s\n' "p7" "Broadcast" "MPI"
    printf '%-4s %-38s %s\n' "p8" "Scatter and Gather" "MPI"
    printf '%-4s %-38s %s\n' "p9" "Reduce and Allreduce" "MPI"
}

if [[ $# -lt 1 ]]; then
    usage
    exit 1
fi

PROGRAM="$1"
shift

if [[ "$PROGRAM" == "list" || "$PROGRAM" == "--list" ]]; then
    list_programs
    exit 0
fi

mkdir -p "$BUILD_DIR"

case "$PROGRAM" in
    p1)
        SRC="$SRC_DIR/p1_mergesort.c"; BIN="$BUILD_DIR/p1_mergesort"
        gcc -O2 -Wall -Wextra -fopenmp "$SRC" -o "$BIN"
        OMP_NUM_THREADS="${OMP_NUM_THREADS:-4}" "$BIN" "$@"
        ;;
    p2)
        SRC="$SRC_DIR/p2_static_scheduling.c"; BIN="$BUILD_DIR/p2_static_scheduling"
        gcc -O2 -Wall -Wextra -fopenmp "$SRC" -o "$BIN"
        OMP_NUM_THREADS="${OMP_NUM_THREADS:-4}" "$BIN" "$@"
        ;;
    p3)
        SRC="$SRC_DIR/p3_fibonacci.c"; BIN="$BUILD_DIR/p3_fibonacci"
        gcc -O2 -Wall -Wextra -fopenmp "$SRC" -o "$BIN"
        OMP_NUM_THREADS="${OMP_NUM_THREADS:-4}" "$BIN" "$@"
        ;;
    p4)
        SRC="$SRC_DIR/p4_prime_numbers.c"; BIN="$BUILD_DIR/p4_prime_numbers"
        gcc -O2 -Wall -Wextra -fopenmp "$SRC" -o "$BIN" -lm
        OMP_NUM_THREADS="${OMP_NUM_THREADS:-4}" "$BIN" "$@"
        ;;
    p5)
        SRC="$SRC_DIR/p5_send_receive.c"; BIN="$BUILD_DIR/p5_send_receive"
        mpicc -O2 -Wall -Wextra "$SRC" -o "$BIN"
        mpirun --oversubscribe -np "${MPI_NP:-2}" "$BIN" "$@"
        ;;
    p6)
        SRC="$SRC_DIR/p6_deadlock.c"; BIN="$BUILD_DIR/p6_deadlock"
        mpicc -O2 -Wall -Wextra "$SRC" -o "$BIN"
        if [[ "${DEADLOCK_TIMEOUT:-0}" == "1" ]]; then
            timeout 5s mpirun --oversubscribe -np "${MPI_NP:-2}" "$BIN" "$@"
        else
            mpirun --oversubscribe -np "${MPI_NP:-2}" "$BIN" "$@"
        fi
        ;;
    p7)
        SRC="$SRC_DIR/p7_broadcast.c"; BIN="$BUILD_DIR/p7_broadcast"
        mpicc -O2 -Wall -Wextra "$SRC" -o "$BIN"
        mpirun --oversubscribe -np "${MPI_NP:-4}" "$BIN" "$@"
        ;;
    p8)
        SRC="$SRC_DIR/p8_scatter_gather.c"; BIN="$BUILD_DIR/p8_scatter_gather"
        mpicc -O2 -Wall -Wextra "$SRC" -o "$BIN"
        mpirun --oversubscribe -np "${MPI_NP:-4}" "$BIN" "$@"
        ;;
    p9)
        SRC="$SRC_DIR/p9_reduce_allreduce.c"; BIN="$BUILD_DIR/p9_reduce_allreduce"
        mpicc -O2 -Wall -Wextra "$SRC" -o "$BIN"
        mpirun --oversubscribe -np "${MPI_NP:-4}" "$BIN" "$@"
        ;;
    *)
        echo "Unknown program: $PROGRAM"
        usage
        exit 2
        ;;
esac
