{
  stdenv,
  emscripten,
  fetchFromGitHub,
  webshims,
  openssl,
  zlib,
  python3,
  cmake,
  which,
  libjpeg,
  libpng,
  libvorbis,
  libarchive,
  libogg,
  freetype,
  sqlite,
  zstd,
  curl,
  sdl,
}:
stdenv.mkDerivation {
  name = "luanti-wasm-module";

  src = fetchFromGitHub {
    owner = "paradust7";
    repo = "minetest";
    rev = "1cfdd6d6bedbd860ab993e99db18f29db1a0c5d2";
    hash = "sha256-cNc8tCJBKbWPEsSgozRZFsT15D1PW/njkXqacPe7O7w=";
  };

  buildInputs = [
    emscripten
    cmake
    which
  ];

  # some env variables that might be important (common.sh)
  preConfigure = ''
    export MINETEST_BUILD_TYPE="Release"
    export COMMON_CFLAGS="-O2"
    export COMMON_LDFLAGS=""
    export BUILD_SUFFIX=""

    export MAKEFLAGS="-j$(nproc)"

    export CFLAGS="$COMMON_CFLAGS -pthread -sUSE_PTHREADS=1 -fexceptions -D__BYTE_ORDER__=__ORDER_LITTLE_ENDIAN__ -I${webshims}/include"
    export CXXFLAGS="$COMMON_CFLAGS -pthread -sUSE_PTHREADS=1 -fexceptions -D__BYTE_ORDER__=__ORDER_LITTLE_ENDIAN__ -I${webshims}/include"
    export LDFLAGS="$COMMON_LDFLAGS -pthread -sUSE_PTHREADS=1 -fexceptions"
    export MINETEST_REPO="./."

    # Disable emscripten sanity checks
    export EMCC_SKIP_SANITY_CHECK=1
    
    # Create a writable copy of the emscripten cache
    mkdir -p /tmp/emscripten_cache
    cp -r ${emscripten}/share/emscripten/cache/* /tmp/emscripten_cache/
    chmod -R +w /tmp/emscripten_cache
    export EM_CACHE=/tmp/emscripten_cache
    
    # Remove the fake SDL headers that Emscripten uses to force -sUSE_SDL=2
    # We're providing our own SDL, so these stubs would cause build errors
    # Remove from our writable cache
    rm -rf /tmp/emscripten_cache/sysroot/include/fakesdl
    rm -rf /tmp/emscripten_cache/sysroot/include/SDL
    # Also remove from any hash-based cache paths that emscripten might create
    rm -rf /tmp/*-emscripten-*_cache/sysroot/include/fakesdl 2>/dev/null || true
    rm -rf /tmp/*-emscripten-*_cache/sysroot/include/SDL 2>/dev/null || true
  '';

  configurePhase = ''
    mkdir -p $out

    export EMSDK_ROOT="${emscripten}"
    export EMSDK_SYSLIB="${emscripten}/share/emscripten/cache/sysroot/lib/wasm32-emscripten"
    export EMSDK_SYSINCLUDE="${emscripten}/share/emscripten/cache/sysroot/include"
    export SDL2_INCLUDE="${sdl}/include/SDL2"

    # Don't use -sUSE_SDL=2 as it triggers the ports system which needs network access
    # Instead we provide SDL2 paths directly from the pre-built cache
    # SDL2 is already built in the emscripten cache, we just need to include it properly
    # Note: We don't add generic sysroot includes as it interferes with C++ vs C header order
    export EMSDK_EXTRA=""
    export CFLAGS="$CFLAGS $EMSDK_EXTRA"
    export CXXFLAGS="$CXXFLAGS $EMSDK_EXTRA"
    # -pthread is critical for pthreads support - it must be passed at both compile AND link time
    export LDFLAGS="$LDFLAGS $EMSDK_EXTRA -pthread -L${sdl}/lib -lSDL2 -sPTHREAD_POOL_SIZE=20 -s EXPORTED_RUNTIME_METHODS=ccall,cwrap -s INITIAL_MEMORY=2013265920 -sMIN_WEBGL_VERSION=2 -sUSE_WEBGL2 -sWASMFS=1"
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



    emcmake cmake \
      -DCMAKE_VERBOSE_MAKEFILE=ON \
      -DCMAKE_C_FLAGS="-pthread -isystem ${webshims}/include -isystem ${sdl}/include/SDL2 -isystem ${libarchive}/include" \
      -DCMAKE_CXX_FLAGS="-pthread -isystem ${webshims}/include -isystem ${sdl}/include/SDL2 -isystem ${libarchive}/include" \
      -DCMAKE_EXE_LINKER_FLAGS="-pthread -L${sdl}/lib -lSDL2 -sPTHREAD_POOL_SIZE=20 -sEXPORTED_RUNTIME_METHODS=ccall,cwrap -sINITIAL_MEMORY=2013265920 -sMIN_WEBGL_VERSION=2 -sUSE_WEBGL2 -sWASMFS=1 -L${libarchive}/lib -L${openssl}/lib -L${webshims}/lib -larchive -lssl -lcrypto -lemsocket -lwebsocket.js" \
      -DENABLE_SYSTEM_GMP=OFF \
      -DENABLE_SYSTEM_JSONCPP=OFF \
      -DENABLE_LUAJIT=OFF \
      -DENABLE_GETTEXT=TRUE \
      -DRUN_IN_PLACE=TRUE \
      -DENABLE_GLES=TRUE \
      -DENABLE_UPDATE_CHECKER=0 \
      -DCMAKE_BUILD_TYPE=Release \
      -DTHREADS_PREFER_PTHREAD_FLAG=ON \
      -DCMAKE_USE_PTHREADS_INIT=1 \
      -DCMAKE_THREAD_LIBS_INIT="" \
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
      -DZstd_LIBRARY="${zstd}/lib/libzstd.a" \
      -DZstd_INCLUDE_DIR="${zstd}/include" \
      -DEGL_LIBRARY="$DUMMY_OBJECT" \
      -DEGL_INCLUDE_DIR="$DUMMY_INCLUDE_DIR" \
      -DCURL_LIBRARY="${curl}/lib/libcurl.a" \
      -DCURL_INCLUDE_DIR="${curl}/include" \
      -DCHECK_SDL_VERSION=ON \
      -DCMAKE_INSTALL_PREFIX="$out" \
      -G "Unix Makefiles" \
      .
  '';
  postPatch = ''
    # Fix jsoncpp to work with emscripten's math.h macros
    # std::isnan, std::isinf, std::fpclassify are defined as macros in emscripten
    # so we need to use them without the std:: prefix
    substituteInPlace lib/jsoncpp/jsoncpp.cpp \
      --replace-quiet "std::isnan" "isnan" \
      --replace-quiet "std::isinf" "isinf" \
      --replace-quiet "std::fpclassify" "fpclassify"

    # Fix sha256.c for emscripten - be32toh and htobe32 are not available
    # We need to add definitions for these byte-order conversion functions
    sed -i '1i\
#ifndef htobe32\n\
#if __BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__\n\
#define htobe32(x) __builtin_bswap32(x)\n\
#define be32toh(x) __builtin_bswap32(x)\n\
#else\n\
#define htobe32(x) (x)\n\
#define be32toh(x) (x)\n\
#endif\n\
#endif\n' lib/sha256/sha256.c

    # Fix serialize.h for emscripten - add emscripten case for byte order detection
    # Emscripten/WebAssembly is always little-endian
    # Also add the actual byte order conversion functions since emscripten doesn't provide them
    substituteInPlace src/util/serialize.h \
      --replace-quiet '#ifdef _WIN32' '#ifdef __EMSCRIPTEN__
	#define BYTE_ORDER LITTLE_ENDIAN
	// Emscripten does not provide these functions, define them for little-endian
	#define be16toh(x) __builtin_bswap16(x)
	#define be32toh(x) __builtin_bswap32(x)
	#define be64toh(x) __builtin_bswap64(x)
	#define htobe16(x) __builtin_bswap16(x)
	#define htobe32(x) __builtin_bswap32(x)
	#define htobe64(x) __builtin_bswap64(x)
#elif defined(_WIN32)'

    # 1. Prevent CMake from unsetting our forced value
    # 2. Force the check to true
    # 3. Change the FATAL_ERROR to a status message so it doesn't stop the build
    # 4. Replace find_package(SDL2) with our own target that doesn't trigger emscripten ports
    substituteInPlace irr/src/CMakeLists.txt \
      --replace 'unset(CHECK_SDL_VERSION CACHE)' 'set(CHECK_SDL_VERSION 1 CACHE BOOL "Forced" FORCE)' \
      --replace 'message(FATAL_ERROR "SDL2 is too old, required is at least 2.0.10!")' 'message(STATUS "Bypassing SDL2 version check")' \
      --replace 'find_package(SDL2 REQUIRED)' 'add_library(SDL2::SDL2 INTERFACE IMPORTED)
set_target_properties(SDL2::SDL2 PROPERTIES
  INTERFACE_INCLUDE_DIRECTORIES "${sdl}/include/SDL2"
  INTERFACE_LINK_LIBRARIES "${sdl}/lib/libSDL2.a"
)'

    # Skip the ZSTD symbol check that fails during cross-compilation with Emscripten
    # The check_symbol_exists doesn't work properly when cross-compiling
    substituteInPlace cmake/Modules/FindZstd.cmake \
      --replace 'check_symbol_exists(ZSTD_initCStream zstd.h HAVE_ZSTD_INITCSTREAM)' 'set(HAVE_ZSTD_INITCSTREAM TRUE)'

    # For Emscripten, threads are handled via -pthread flag, not a library
    # We need to bypass the FindThreads check
    substituteInPlace src/CMakeLists.txt \
      --replace 'find_package(Threads REQUIRED)' 'set(CMAKE_THREAD_LIBS_INIT "")
set(CMAKE_USE_PTHREADS_INIT 1)
set(Threads_FOUND TRUE)
set(CMAKE_HAVE_THREADS_LIBRARY 1)' \
      --replace 'set(PLATFORM_LIBS Threads::Threads)' 'set(PLATFORM_LIBS "")'

    # Skip the lua_atccall check that fails during cross-compilation with Emscripten
    # This check verifies that we're using the bundled Lua with the lua_atccall extension
    # but the check doesn't work in cross-compilation. We're using bundled Lua anyway.
    substituteInPlace src/CMakeLists.txt \
      --replace 'check_c_source_compiles("#include <lua.h>\nint main(){return sizeof(lua_atccall);}" HAVE_ATCCALL)' 'set(HAVE_ATCCALL TRUE)'

    # Fix semaphore.cpp for emscripten - sem_timedwait is not available
    # Add an emscripten-specific implementation using condition variables
    substituteInPlace src/threading/semaphore.cpp \
      --replace '#if defined(__MACH__) && defined(__APPLE__)' '#if defined(__EMSCRIPTEN__)
#include <emscripten/threading.h>
#include <mutex>
#include <condition_variable>
// Emscripten does not support sem_timedwait, use a polling implementation
#elif defined(__MACH__) && defined(__APPLE__)'

    # Fix the timed wait implementation for emscripten
    substituteInPlace src/threading/semaphore.cpp \
      --replace '# if defined(__MACH__) && defined(__APPLE__)
	mach_timespec_t wait_time;' '# if defined(__EMSCRIPTEN__)
	// Emscripten: use sem_trywait with polling
	struct timespec wait_end;
	clock_gettime(CLOCK_REALTIME, &wait_end);
	wait_end.tv_nsec += (time_ms % 1000) * 1000000;
	wait_end.tv_sec += time_ms / 1000 + wait_end.tv_nsec / 1000000000;
	wait_end.tv_nsec %= 1000000000;
	int ret;
	do {
		ret = sem_trywait(&semaphore);
		if (ret == 0) break;
		if (errno != EAGAIN) break;
		struct timespec now;
		clock_gettime(CLOCK_REALTIME, &now);
		if (now.tv_sec > wait_end.tv_sec ||
		    (now.tv_sec == wait_end.tv_sec && now.tv_nsec >= wait_end.tv_nsec)) {
			errno = ETIMEDOUT;
			break;
		}
		emscripten_thread_sleep(1);
	} while (true);
# elif defined(__MACH__) && defined(__APPLE__)
	mach_timespec_t wait_time;'
  '';

  buildPhase = ''
   # emmake make

    true
  '';

  installPhase = ''
    emmake make install
    
    # Copy the .wasm file that emscripten generates alongside the .js file
    # CMake's install rules only copy the .js file, but we need the .wasm too
    if [ -f "bin/luanti.wasm" ]; then
      cp bin/luanti.wasm $out/bin/
    fi
    
    # Also copy the worker.js file if it exists (for pthreads support)
    if [ -f "bin/luanti.worker.js" ]; then
      cp bin/luanti.worker.js $out/bin/
    fi
    
    # Fix broken symlinks for emscripten builds
    # The minetest symlink points to luanti which doesn't exist
    # because the actual executables are .js files with emscripten
    rm -f $out/bin/minetest
    if [ -f "$out/bin/luanti.js" ]; then
      ln -s luanti.js $out/bin/minetest
    fi
    if [ -f "$out/bin/luanti.wasm" ]; then
      ln -s luanti.wasm $out/bin/minetest.wasm
    fi
  '';

}
