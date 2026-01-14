{
  #uses very old nixpkgs rev because it has emscripten 4.0.12 which is used by upstream minetest-wasm
  inputs.nixpkgs-emscripten.url = "github:NixOS/nixpkgs/ee09932";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { nixpkgs, ... }@inputs:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
      pkgs-emscripten = import inputs.nixpkgs-emscripten { system = "x86_64-linux"; };
      pkgs-emscripten-cross = import inputs.nixpkgs-emscripten-cross { system = "x86_64-linux"; };
    in
    {
      packages."x86_64-linux" = rec {
        default = minetest;

        emscripten = pkgs-emscripten.callPackage ./packages/emscripten { };

        sdl = pkgs.callPackage ./packages/sdl { inherit emscripten; };
        zlib = pkgs.callPackage ./packages/zlib { inherit emscripten; };
        libjpeg = pkgs.callPackage ./packages/libjpeg { inherit emscripten; };
        libpng = pkgs.callPackage ./packages/libpng { inherit emscripten zlib; };
        libogg = pkgs.callPackage ./packages/libogg { inherit emscripten; };
        libvorbis = pkgs.callPackage ./packages/libvorbis { inherit emscripten libogg; };
        freetype = pkgs.callPackage ./packages/freetype { inherit emscripten libpng zlib; };
        zstd = pkgs.callPackage ./packages/zstd { inherit emscripten; };
        libarchive = pkgs.callPackage ./packages/libarchive { inherit emscripten zstd; };
        sqlite = pkgs.callPackage ./packages/sqlite { inherit emscripten; };
        webshims = pkgs.callPackage ./packages/webshims { inherit emscripten; };
        openssl = pkgs.callPackage ./packages/openssl { inherit emscripten webshims; };
        curl = pkgs.callPackage ./packages/curl {
          inherit
            emscripten
            webshims
            openssl
            zlib
            ;
        };
        fsroot = pkgs.callPackage ./packages/fsroot { inherit minetest; };
        www = pkgs.callPackage ./packages/www { inherit minetest fsroot; static = ./static; };
        minetest = pkgs.callPackage ./packages/minetest {
          inherit
            emscripten
            zlib
            libjpeg
            libpng
            libogg
            libvorbis
            freetype
            zstd
            libarchive
            sqlite
            webshims
            openssl
            curl
            sdl
            ;
        };


      };
    };
}
