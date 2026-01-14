{stdenv, minetest, zstd, games ? [], cacert }: 
stdenv.mkDerivation {
  name = "luanti-web-fsroot";
  src = minetest;
  nativeBuildInputs = [ zstd  ];
  buildPhase = ''
    mkdir -p fsroot
    cd fsroot

 
    ${
      builtins.concatStringsSep "\n" (map (game: ''
        mkdir -p games/${game.pname}
        cp -r ${game}/* games/${game.pname}/
      '') games)
    }

    mkdir -p minetest
    cp -r ${minetest}/* minetest/

    chmod -R +w minetest

    rm -rf minetest/bin minetest/unix
    mkdir -p minetest/bin
    echo "This file exists to prevent bin directory from being empty." > minetest/bin/README.txt
    mkdir -p minetest/cache
    cat > minetest/cache/common.conf << EOF
    update_last_checked = disabled
    no_mtg_notification = true
    no_keycode_migration_warning = true
    EOF

    mkdir -p etc/ssl/certs

    cat ${cacert}/etc/ssl/certs/ca-bundle.crt > etc/ssl/certs/ca-certificates.crt

    tar cf ../fsroot.tar .

    cd ..



    zstd --ultra -22 fsroot.tar
  '';
  installPhase = ''
    mkdir -p $out

    ls -lah
    cp fsroot.tar.zst $out/
  '';
}