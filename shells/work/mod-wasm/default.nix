{
  mkShell,
  apacheHttpd,
  apr,
  aprutil,
  pkg-config,
}:
mkShell {
  nativeBuildInputs = [apacheHttpd apacheHttpd.dev apr apr.dev aprutil pkg-config];
  shellHook = ''
    export PATH="${apr.dev}/share/build:$PATH"
    export LIBTOOL="${apr.dev}/share/build/libtool"
  '';
}
