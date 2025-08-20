{
  stdenv,
  fetchFromGitLab,
  emscripten,
  zlib,
  libpng,
  cmake
}:
stdenv.mkDerivation {
  name = "freetype";

  src = fetchFromGitLab {
    #https://gitlab.freedesktop.org/freetype/freetype.git
    owner = "freetype";
    repo = "freetype";
    domain = "gitlab.freedesktop.org";
    rev = "a8e4563c3418ed74d39019a6c5e2122d12c8f56f";
    hash = "sha256-sazxm6yCzoXZSQLK547Fl1WWRQjH4I97IeZ6glJ7XrU=";
  };

  buildInputs = [ emscripten cmake ];

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

    emcmake cmake \
      -DCMAKE_INSTALL_PREFIX="$out" \
      -DZLIB_LIBRARY="${zlib}/lib/zlib.a" \
      -DZLIB_INCLUDE_DIR="${zlib}/include" \
      -DPNG_LIBRARY="${libpng}/lib/libpng.a" \
      -DPNG_PNG_INCLUDE_DIR="${libpng}/include" \
      $src
  '';

  buildPhase = ''
    emmake make

  '';

  installPhase = ''
    emmake make install
  '';

}
