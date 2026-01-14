{stdenv, fetchFromGitHub, cmake, emscripten}: stdenv.mkDerivation {
  name = "webshims";
  
  src = fetchFromGitHub {
    owner  = "paradust7";
    repo = "webshims";
    rev = "0767fdedd87f61a28a34f6444b669caf563a9fd5";
    hash = "sha256-GzXWgdLjRmGYThfbJ+liMFPEqkj7MaUvMM6no3nLLyw=";
  };

  buildInputs = [emscripten cmake];


  # some env variables that might be important (common.sh)
  preConfigure = ''
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

    # Pass pthread flags via CMake to ensure they're used during compilation
    emcmake cmake \
      -DCMAKE_C_FLAGS="-pthread" \
      -DCMAKE_CXX_FLAGS="-pthread" \
      -DCMAKE_INSTALL_PREFIX="$out" \
      "$src"
  '';

  buildPhase = ''
    emmake make
   
  '';

  installPhase = ''
    emmake make install
  '';

}