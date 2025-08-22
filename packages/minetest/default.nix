{
  stdenv,
  emscripten,
  fetchFromGitHub,
  webshims,
  openssl,
  zlib,
  python3,
  cmake,
  libjpeg,
  libpng,
  libvorbis,
  libarchive,
  libogg,
  freetype,
  sqlite,
  zstd,
  curl,
  irrlichtmt
}:
stdenv.mkDerivation {
  name = "minetest";

  src = fetchFromGitHub {
    owner = "paradust7";
    repo = "minetest";
    rev = "b3543e3af0c7a87012849bf824d9be2792ed2956";
    hash = "sha256-VJ2XFMzwwhFllwbpAFIkDCd9ylO3f4M7u1bmNvGbjkM=";
  };

  buildInputs = [
    emscripten
    cmake
  ];

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
    export MINETEST_REPO="./."
    export IRRLICHT_REPO="${irrlichtmt}"
  '';

  configurePhase = ''
    mkdir -p $out

    export EMSDK_EXTRA="-sUSE_SDL=2"
    export CFLAGS="$CFLAGS $EMSDK_EXTRA"
    export CXXFLAGS="$CXXFLAGS $EMSDK_EXTRA"
    export LDFLAGS="$LDFLAGS $EMSDK_EXTRA -sPTHREAD_POOL_SIZE=20 -s EXPORTED_RUNTIME_METHODS=ccall,cwrap -s INITIAL_MEMORY=2013265920 -sMIN_WEBGL_VERSION=2 -sUSE_WEBGL2 -sWASMFS=1"
    export LDFLAGS="$LDFLAGS \
        -L${libarchive}/lib \
        -L${openssl}/lib \
        -L${webshims}/lib \
        -larchive \
        -lssl \
        -lcrypto \
        -lemsocket \
        -lwebsocket.js"


    # Create a dummy .o file to use as a substitute for the OpenGLES2 / EGL libraries,
    # since Emscripten doesn't actually provide those. (the symbols are resolved through
    # javascript stubs).
    echo > dummy.c
    emcc -c dummy.c -o dummy.o
    DUMMY_OBJECT="$(pwd)/dummy.o"
    mkdir -p dummy_dir
    DUMMY_INCLUDE_DIR="$(pwd)/dummy_dir"

    cp -r ${irrlichtmt} ./lib/irrlichtmt

    emcmake cmake \
      -DCMAKE_VERBOSE_MAKEFILE=ON \
      -DENABLE_SYSTEM_GMP=OFF \
      -DENABLE_GETTEXT=TRUE \
      -DRUN_IN_PLACE=TRUE \
      -DENABLE_GLES=TRUE \
      -DCMAKE_BUILD_TYPE="Release" \
      -DZLIB_INCLUDE_DIR="${zlib}/include" \
      -DZLIB_LIBRARY="${zlib}/lib/libz.a" \
      -DJPEG_INCLUDE_DIR="${libjpeg}/include" \
      -DJPEG_LIBRARY="${libjpeg}/lib/libjpeg.a" \
      -DPNG_PNG_INCLUDE_DIR="${libpng}/include" \
      -DPNG_LIBRARY="${libpng}/lib/libpng.a" \
      -DOGG_INCLUDE_DIR="${libogg}/include" \
      -DVORBIS_INCLUDE_DIR="${libvorbis}/include" \
      -DOGG_LIBRARY="${libogg}/lib/libogg.a" \
      -DVORBIS_LIBRARY="${libvorbis}/lib/libvorbis.a" \
      -DVORBISFILE_LIBRARY="${libvorbis}/lib/libvorbisfile.a" \
      -DFREETYPE_LIBRARY="${freetype}/lib/libfreetype.a" \
      -DFREETYPE_INCLUDE_DIRS="${freetype}/include/freetype2" \
      -DOPENGLES2_INCLUDE_DIR="$DUMMY_INCLUDE_DIR" \
      -DOPENGLES2_LIBRARY="$DUMMY_OBJECT" \
      -DSQLITE3_LIBRARY="${sqlite}/lib/libsqlite3.a" \
      -DSQLITE3_INCLUDE_DIR="${sqlite}/include" \
      -DZSTD_LIBRARY="${zstd}/lib/libzstd.a" \
      -DZSTD_INCLUDE_DIR="${zstd}/include" \
      -DEGL_LIBRARY="$DUMMY_OBJECT" \
      -DEGL_INCLUDE_DIR="$DUMMY_INCLUDE_DIR" \
      -DCURL_LIBRARY="${curl}/lib/libcurl.a" \
      -DCURL_INCLUDE_DIR="${curl}/include" \
      -DCMAKE_INSTALL_PREFIX="$out" \
      -G "Unix Makefiles" \
      .
  '';

  buildPhase = ''
   # emmake make

    true
  '';

  installPhase = ''
    emmake make install
  '';

}
