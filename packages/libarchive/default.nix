{stdenv, emscripten, zstd }: stdenv.mkDerivation {
  name = "libarchive";
  
  src = builtins.fetchTarball {
    url = "https://www.libarchive.org/downloads/libarchive-3.6.1.tar.xz";
    sha256 = "sha256:1kkfsjkwwkhwmwwn1dzyq97wbp48al7vf3d827mb2nj886nmy9ic";
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

    export CPPFLAGS="-I${zstd}/include"
    export LDFLAGS="-L${zstd}/lib"

    emconfigure ./configure \
    --enable-static \
    --disable-shared \
    --disable-bsdtar \
    --disable-bsdcat \
    --disable-bsdcpio \
    --enable-posix-regex-lib=libc \
    --disable-xattr --disable-acl --without-nettle --without-lzo2 \
    --without-cng  --without-lz4 \
    --without-xml2 --without-expat \
    --with-zstd \
    --prefix="$out"
  '';

  buildPhase = ''
    emmake make
   
  '';

  installPhase = ''
    emmake make install
  '';

}