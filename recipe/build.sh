
set -e
set -x

declare -a CMAKE_PLATFORM_FLAGS
if [[ ${HOST} =~ .*darwin.* ]]; then
  CMAKE_PLATFORM_FLAGS+=(-DCMAKE_OSX_SYSROOT="${CONDA_BUILD_SYSROOT}")
  # export LDFLAGS=$(echo "${LDFLAGS}" | sed "s/-Wl,-dead_strip_dylibs//g")
else
  CMAKE_PLATFORM_FLAGS+=(-DCMAKE_TOOLCHAIN_FILE="${RECIPE_DIR}/cross-linux.cmake")
fi

if [[ ${DEBUG_C} == yes ]]; then
  CMAKE_BUILD_TYPE=Debug
else
  CMAKE_BUILD_TYPE=Release
fi

blaslibs="${PREFIX}/lib/libopenblas${SHLIB_EXT}"
lapacklibs="${PREFIX}/lib/libopenblas${SHLIB_EXT}"
if [ "x${blas_impl}" = "xmkl" ]; then
    blaslibs="${PREFIX}/lib/libmkl_rt${SHLIB_EXT}"
    lapacklibs="${PREFIX}/lib/libmkl_rt${SHLIB_EXT}"
fi

mkdir -p build
cd build
cmake \
    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} \
    ${CMAKE_PLATFORM_FLAGS[@]} \
    -DFFTW_ROOT="${PREFIX}" \
    -DAATM_ROOT="${PREFIX}" \
    -DBLAS_LIBRARIES="${blaslibs}" \
    -DLAPACK_LIBRARIES="${lapacklibs}" \
    -DSUITESPARSE_INCLUDE_DIR_HINTS="${PREFIX}/include" \
    -DSUITESPARSE_LIBRARY_DIR_HINTS="${PREFIX}/lib" \
    -DPYTHON_EXECUTABLE:FILEPATH="${PYTHON}" \
    -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_PREFIX_PATH="${PREFIX}" \
    "${SRC_DIR}"
make -j $CPU_COUNT
make install
