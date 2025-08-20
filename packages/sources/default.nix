{
  fetchFromGitHub,
  fetchurl,
  stdenv,
}:
let

  libogg = fetchurl {
    url = "https://downloads.xiph.org/releases/ogg/libogg-1.3.5.tar.gz";
    hash = "sha256-DrS0uUIKD1HbFCuj+cZLMz+CZTLcD0jGQQrlH0eZtmQ=";
  };
  libvorbis = fetchurl {
    url = "https://downloads.xiph.org/releases/vorbis/libvorbis-1.3.7.tar.gz";
    hash = "sha256-DpgkCanD/ILuBuCCBbE1XlxqpMNrylgUbvOZYhsM5as=";
  };
  sqlite = fetchurl {
    url = "https://www.sqlite.org/src/tarball/698edb77/SQLite-698edb77.tar.gz";
    hash = "sha256-saejBMWiU2SqzhkuQpaTUt1jagAjdgPLUekLDTMIK7Y=";
  };
  openssl = fetchurl {
    url = "https://www.openssl.org/source/openssl-1.1.1n.tar.gz";
    hash = "sha256-QNzrUaT2pSdb3g5r8g70uRv8Mu1XwFUuLo4VRjNysXo=";
  };
  curl = fetchurl {
    url = "https://curl.se/download/curl-7.82.0.tar.bz2";
    hash = "sha256-RtmgQAozQI/ZkncLBKRKdDSzA28ugImsKLV1c9WdNx8=";
  };

  libarchive = fetchurl {
    url = "https://www.libarchive.org/downloads/libarchive-3.6.1.tar.xz";
    hash = "sha256-WkEazrl49D5ibwwtGBLd2IB7ZF7YkkU6yr1TI3bBSOY=";
  };

in
stdenv.mkDerivation {
  src = null;
  dontUnpack = true;
  name = "sources";

  buildPhase = "true";

  installPhase = ''
    mkdir -p $out
    cp ${libogg} $out/libogg1.5.3.tar.gz
    cp ${libvorbis} $out/libvorbis-1.3.7.tar.gz
    cp ${sqlite} $out/SQLite-698edb77.tar.gz
    cp ${openssl} $out/openssl-1.1.1n.tar.gz
    cp ${curl} $out/curl-7.82.0.tar.bz2
    cp ${libarchive} $out/libarchive-3.6.1.tar.xz
  '';

}
