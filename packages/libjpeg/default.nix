{stdenv, fetchFromGitHub, emscripten, cmake }: stdenv.mkDerivation {
  name = "libjpeg";
  
  src = fetchFromGitHub {
    owner = "libjpeg-turbo";
    repo = "libjpeg-turbo";
    rev = "2ee7264d40910f2529690de327988ce0c2276812";
    hash = "sha256-ErLvfeybvPlj/luglFGAv0w03VmMj5m8JAh7WfBlPTc=";
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

    emcmake cmake \
    -DCMAKE_INSTALL_PREFIX="$out" \
    -DWITH_SIMD=0 \
    $src
  '';

  buildPhase = ''
    emmake make
   
  '';

  installPhase = ''
    emmake make install
  '';

}