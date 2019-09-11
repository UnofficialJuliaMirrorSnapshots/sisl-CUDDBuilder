# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "CUDDBuilder"
version = v"3.0.0"

# Collection of sources required to build CUDDBuilder
sources = [
    "http://davidkebo.com/source/cudd_versions/cudd-3.0.0.tar.gz" =>
    "b8e966b4562c96a03e7fbea239729587d7b395d53cadcc39a7203b49cf7eeb69",

]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir
cd cudd-3.0.0


if [[ "${target}" == *-mingw* ]]; then
    sed -i 's/cross_compiling=no/cross_compiling=yes/' configure
    ./configure --prefix=$prefix --target=${target} --build=x86_64-w64-mingw32 --enable-silent-rules --enable-shared --enable-obj 
elif [[ "${target}" == *-apple-* ]]; then
    sed -i 's/cross_compiling=no/cross_compiling=yes/' configure
    export CC=/opt/${target}/bin/${target}-gcc
    export CXX=/opt/${target}/bin/${target}-g++
    ./configure --prefix=$prefix --target=${target} --enable-silent-rules --enable-shared --enable-obj
else
    autoreconf -fi
    sed -i 's/cross_compiling=no/cross_compiling=yes/' configure
    export CC=/opt/${target}/bin/${target}-gcc
    export CXX=/opt/${target}/bin/${target}-g++
    export LD=/opt/${target}/bin/${target}-ld
    export LDFLAGS=-L/opt/${target}/${target}/lib64

    ./configure --prefix=$prefix --target=${target} --enable-silent-rules --enable-shared --enable-obj
fi

make -j${nproc} check
make install

"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    Linux(:x86_64, libc=:glibc),
    MacOS(:x86_64),
    Windows(:x86_64)
]

# The products that we will ensure are always built
products(prefix) = [
    LibraryProduct(prefix, "libcudd", Symbol(""))
]

# Dependencies that must be installed before this package can be built
dependencies = [
    
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)

