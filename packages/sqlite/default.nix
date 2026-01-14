{
  stdenv,
  fetchFromGitHub,
  tcl,
  emscripten,
  zstd,
  gcc,
}:
stdenv.mkDerivation rec {
  pname = "sqlite";
  version = "3.39.2";

  src = fetchFromGitHub {
    owner = "sqlite";
    repo = "sqlite";
    tag = "version-${version}";
    hash = "sha256-LGmiFat9pponVu5ePxx6hXBt3PnCu4uUH76oOMLJKqM=";
  };

  buildInputs = [
    emscripten
    tcl
  ];

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

    export BUILD_CC="${gcc}/bin/gcc"
    export CFLAGS="-O2 -pthread"
    export CXXFLAGS="-O2 -pthread"
    export LDFLAGS="-pthread"
    emconfigure ./configure --disable-tcl --disable-shared --prefix="$out" cross_compiling=yes CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS"

  '';

  buildPhase = ''
    emmake make

  '';

  installPhase = ''
    emmake make install
  '';

}
