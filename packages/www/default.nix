{stdenv, fsroot, minetest, static}:
stdenv.mkDerivation {
  name = "luanti-web";
  src = fsroot;
  buildPhase = ''
    SEEDFILE=${fsroot}/fsroot.tar.zst

    md5sum -b "$SEEDFILE" > seedfile.hash

    RELEASE_UUID=`cut -b -12 seedfile.hash`
    rm seedfile.hash

    WWW_DIR=$(pwd)/www

    RELEASE_DIR="$WWW_DIR/$RELEASE_UUID"
    PACKS_DIR="$RELEASE_DIR/packs"
    mkdir -p "$PACKS_DIR"

    EMSCRIPTEN_FILES="luanti.js luanti.wasm"

    for I in $EMSCRIPTEN_FILES; do
      cp "${minetest}/bin/$I" "$RELEASE_DIR"
    done

    apply_substitutions() {
      local srcfile="$1"
      local dstfile="$2"

      sed "s/%__RELEASE_UUID__%/$RELEASE_UUID/g" "$srcfile" > "$dstfile"
    }

    apply_substitutions ${static}/htaccess_toplevel   "$WWW_DIR"/.htaccess
    apply_substitutions ${static}/index.html  "$WWW_DIR"/index.html
    apply_substitutions ${static}/htaccess_release "$RELEASE_DIR"/.htaccess
    apply_substitutions ${static}/launcher.js "$RELEASE_DIR"/launcher.js
    apply_substitutions ${static}/worker.js "$RELEASE_DIR"/worker.js
    apply_substitutions ${static}/htaccess_packs "$PACKS_DIR"/.htaccess

    cp fsroot.tar.zst "$PACKS_DIR"/base.pack

  '';
  installPhase = ''
    mkdir -p $out

    cp -r www/* $out/
  '';
}