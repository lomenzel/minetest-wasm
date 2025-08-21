{stdenv, fetchFromGitHub, cmake, emscripten}: stdenv.mkDerivation {
  name = "webshims";
  
  src = fetchFromGitHub {
    owner  = "paradust7";
    repo = "webshims";
    rev = "91c3fe85d2cb7f85cc8e19d3f53dc8f252a69ff7";
    hash = "sha256-Zvn7mv48zu9Pu/VEpAxDhQt0quThmv2NJ1xhR9qG4jI=";
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

    emcmake cmake -DCMAKE_INSTALL_PREFIX="$out" "$src"

  '';

  buildPhase = ''
    emmake make
   
  '';

  installPhase = ''
    emmake make install
  '';

}