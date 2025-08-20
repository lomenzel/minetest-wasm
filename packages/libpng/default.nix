{stdenv, fetchgit, emscripten, zlib }: stdenv.mkDerivation {
  name = "libpng";
  
  src = fetchgit {
    url = "https://git.code.sf.net/p/libpng/code";
    rev = "a37d4836519517bdce6cb9d956092321eca3e73b";
    hash = "sha256-KCpOY1kL4eG51bUv28aw8jTjUNwr3UHAGBqAaN2eBvg=";
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

    export CPPFLAGS="-I${zlib}/include"
    export LDFLAGS="-L${zlib}/lib"

    emconfigure ./configure --disable-shared --prefix="$out"
  '';

  buildPhase = ''
    emmake make
   
  '';

  installPhase = ''
    emmake make install
  '';

}