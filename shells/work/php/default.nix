{
  mkShell,
  autoconf,
  bison,
  clang,
  coreutils,
  php,
  re2c,
}:
mkShell {
  buildInputs = [autoconf bison clang coreutils php re2c];
  shellHook = ''
    configure() {
       ./buildconf --force; ./configure --without-iconv --without-openssl --without-libxml --without-pear --disable-phar --disable-opcache --disable-zend-signals --without-pcre-jit --disable-pdo --disable-fiber-asm --disable-posix --without-sqlite3 --disable-dom --disable-xml --disable-simplexml --without-libxml --disable-xmlreader --disable-xmlwriter --disable-fileinfo --disable-session
    }

    configure-minimal() {
       ./buildconf --force; ./configure --without-openssl --without-libxml --without-pear --disable-phar --disable-opcache --disable-zend-signals --without-pcre-jit --disable-fiber-asm --disable-posix --disable-dom --disable-xml --disable-simplexml --without-libxml --disable-xmlreader --disable-xmlwriter --disable-fileinfo --disable-session --disable-all --disable-dom --disable-inifile --disable-flatfile --disable-ctype --disable-dom --disable-fileinfo --disable-filter --disable-mbregex --disable-opcache --disable-huge-code-pages --disable-opcache-jit --disable-phar --disable-posix --disable-session --disable-simplexml --disable-tokenizer --disable-xml --disable-xmlreader --disable-xmlwriter --disable-mysqlnd-compression-support --disable-fiber-asm --disable-zend-signals --without-cdb --without-sqlite3 --disable-pdo
    }

    genstubs() {
      find . -name '*_arginfo.h' | xargs -I{} make {}
    }

    build() {
      make -j cgi cli
    }

    build-all() {
      build/gen_stub.php --generate-optimizer-info -f
      make -j cgi cli
    }
  '';
}
