#!/bin/bash

set -e
set -x

export OMP_NUM_THREADS=2

echo "Testing build"

python -c 'import toast.tests; toast.tests.run()'
