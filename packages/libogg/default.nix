{stdenv, emscripten }: stdenv.mkDerivation {
  name = "libogg";
  
  src = builtins.fetchTarball {
    url = "https://downloads.xiph.org/releases/ogg/libogg-1.3.5.tar.gz";
    sha256 = "sha256:15rz32zw54jpjdjlrvw7r2fh1rnmrz3gkan3jvfm9nd1h1d4bj1g";
  };

  buildInputs = [emscripten];


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

    emconfigure ./configure --disable-shared --prefix="$out"
  '';

  buildPhase = ''
    emmake make
  '';

  installPhase = ''
    emmake make install
  '';

}