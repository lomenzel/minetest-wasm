{stdenv, fetchFromGitHub, emscripten }: stdenv.mkDerivation {
  name = "zlib";
  
  src = fetchFromGitHub {
    owner = "madler";
    repo = "zlib";
    rev = "21767c654d31d2dccdde4330529775c6c5fd5389";
    hash = "sha256-bIm5+uHv12/x2uqEbZ4/VGzUJnDzW9C3GkyHo3EnC1A=";
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

    emconfigure ./configure --static --prefix="$out"
  '';

  buildPhase = ''
    emmake make
   
  '';

  installPhase = ''
    emmake make install
  '';

}