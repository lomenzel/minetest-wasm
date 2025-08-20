{ emscripten }:
emscripten.overrideAttrs (old: {

  patches = old.patches ++ [
    ./emsdk_dirperms.patch
    ./emsdk_file_packager.patch
    ./emsdk_openat.patch
  ];

})
