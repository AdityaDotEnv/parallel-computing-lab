# Parallel Computing Lab — Ubuntu Monorepo

Nine standalone C lab programs in one repository:
- Programs 1–4: OpenMP
- Programs 5–9: MPI (OpenMPI)

## 1. Extract the ZIP

Extract `parallel-computing-lab.zip`, then enter the project directory:

```bash
unzip parallel-computing-lab.zip
cd parallel-computing-lab
```

Alternatively, use the included helper script from wherever you saved the ZIP:

```bash
bash scripts/bootstrap-from-zip.sh /path/to/parallel-computing-lab.zip ~/labs
cd ~/labs/parallel-computing-lab
```

## 2. One-time Ubuntu setup

This installs the required packages and checks tool versions:

```bash
chmod +x run.sh scripts/*.sh
./scripts/setup.sh
```

Packages installed:
- `build-essential` / `gcc`
- `openmpi-bin`
- `libopenmpi-dev`

GCC provides OpenMP support through `-fopenmp`; no separate OpenMP package is needed.

## 3. Run any program independently

The runner compiles the selected source file and immediately runs only that program. Binaries are placed in `build/`.

```bash
./run.sh list
./run.sh p1
./run.sh p2
./run.sh p3
./run.sh p4
./run.sh p5
./run.sh p6
./run.sh p7
./run.sh p8
./run.sh p9
```

Programs 2, 3 and 4 prompt for input as appropriate.

### Choose OpenMP thread count

```bash
OMP_NUM_THREADS=8 ./run.sh p1
OMP_NUM_THREADS=2 ./run.sh p2
```

### Choose MPI process count

```bash
MPI_NP=4 ./run.sh p5
MPI_NP=6 ./run.sh p7
```

Programs 5 and 6 require at least 2 processes. Program 8 supports at most 100 processes because its arrays have 100 elements. Program 9's integer product can overflow for larger process counts; use 4 or fewer.

### Safely demonstrate Program 6 deadlock

The source defaults to deadlock avoidance (`DEADLOCK_PART 2`). To demonstrate the deadlock, edit `src/p6_deadlock.c` and change:

```c
#define DEADLOCK_PART 2
```

to:

```c
#define DEADLOCK_PART 1
```

Then run with a timeout so it cannot hang indefinitely:

```bash
DEADLOCK_TIMEOUT=1 ./run.sh p6
```

A timeout exit status is expected for the deadlocking version.

## 4. Compile manually (optional)

OpenMP example:

```bash
gcc -fopenmp src/p1_mergesort.c -o build/p1_mergesort
./build/p1_mergesort
```

MPI example:

```bash
mpicc src/p5_send_receive.c -o build/p5_send_receive
mpirun --oversubscribe -np 2 ./build/p5_send_receive
```

## Notes

- Run `./scripts/setup.sh` once after extraction. It uses `sudo` for `apt-get update` and package installation.
- `./run.sh pN` rebuilds that program before running it.
- `--oversubscribe` allows OpenMPI to launch the requested process count even if it exceeds the available CPU slots; it does not create additional physical cores.
- OpenMP merge sort is retained in the same recursive-sections style as the supplied lab code. Nested parallelism is commonly disabled by default, so the parallel version may not demonstrate a speedup without further tuning.
- Program 2's per-thread tracking arrays are sized for 100 threads.
