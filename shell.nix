{
  pkgs ? import <nixpkgs> { },
}:
pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    coreutils-full
    bashInteractive
    texliveFull
    imagemagick
    ghostscript
  ];
}
