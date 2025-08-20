{stdenv, fetchgit, emscripten, libogg }: stdenv.mkDerivation {
  name = "libvorbis";
  
  src = builtins.fetchTarball {
    url = "https://downloads.xiph.org/releases/vorbis/libvorbis-1.3.7.tar.gz";
    sha256 = "sha256:0bcvamndfzxsmna9cx9y1malvj86hghffbilxrbn51mlqbr74yy5";
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

    emconfigure ./configure --disable-shared --prefix="$out" --with-ogg="${libogg}"
  '';

  buildPhase = ''
    emmake make
  '';

  installPhase = ''
    emmake make install
  '';

}