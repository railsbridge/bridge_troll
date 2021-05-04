let
  sources = import ./nix/sources.nix { };
  pkgs = import sources.nixpkgs { };
in pkgs.mkShell {
  buildInputs = [
    # for nokogiri
    pkgs.zlib
    pkgs.libiconv
    #
    pkgs.ruby_2_7
  ];
}
