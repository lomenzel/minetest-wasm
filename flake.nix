{
  #uses very old nixpkgs rev because it has emscripten 3.1.51 which is used by upstream minetest-wasm
  #  inputs.nixpkgs-emscripten.url = "github:NixOS/nixpkgs/67b4bf1df4ae54d6866d78ccbd1ac7e8a8db8b73";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { nixpkgs, ... }@inputs:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
      pkgs-emscripten = import inputs.nixpkgs-emscripten { system = "x86_64-linux"; };
    in
    {
      packages."x86_64-linux" = rec {
        default = minetest;
        irrlichtmt = pkgs.fetchFromGitHub {
          owner = "paradust7";
          repo = "irrlicht";
          rev = "b810648de489cf7f83d73635b7c6b83b94950a2e";
          hash = "sha256-qCsHVz+i8iYuRxHfA6ai5W59OgyHhVYYXgaF5chjdKQ=";
          name = "irrlichtmt";
        };
        emscripten = pkgs.callPackage ./packages/emscripten { };

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
            irrlichtmt
            ;
        };
      };
    };
}
