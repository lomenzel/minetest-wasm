{stdenv, fetchFromGitHub, cmake, emscripten }: stdenv.mkDerivation {
  name = "zstd";
  
  src = fetchFromGitHub {
    owner = "facebook";
    repo = "zstd";
    rev = "e47e674cd09583ff0503f0f6defd6d23d8b718d3";
    hash = "sha256-yJvhcysxcbUGuDOqe/TQ3Y5xyM2AUw6r1THSHOqmUy0=";
  };

  buildInputs = [emscripten cmake];


  # some env variables that might be important (common.sh)
  preConfigurePhase = ''
    export MINETEST_BUILD_TYPE="Release"
    export COMMON_CFLAGS="-O2"
    export COMMON_LDFLAGS=""
    export BUILD_SUFFIX=""

    export MAKEFLAGS="-j$(nproc)"

    export CFLAGS="$COMMON_CFLAGS -pthread -sUSE_PTHREADS=1 -fexceptions"
    export CXXFLAGS="$COMMON_CFLAGS -pthread -sUSE_PTHREADS=1 -fexceptions"
    export LDFLAGS="$COMMON_LDFLAGS -pthread -sUSE_PTHREADS=1 -fexceptions"
  '';

  configurePhase = ''
    mkdir -p $out

    # makefile can't handle parallelism
    export MAKEFLAGS=""

    export CFLAGS="-D_POSIX_SOURCE=1"
    export CXXFLAGS="-D_POSIX_SOURCE=1"

    emcmake cmake \
      -DCMAKE_INSTALL_PREFIX="$out" \
      $src/build/cmake
  '';

  buildPhase = ''
    emmake make
  '';

  installPhase = ''
    emmake make install
  '';



  # /bin/zstd is missing. i dont know if its needed.
  fixupPhase = "true";
  checkPhase = "true";

}