{
  pkgs,
  lib,
  ...
}:

{
  # https://devenv.sh/packages/
  packages = with pkgs; [
    git
    chromedriver # used by tests
    libyaml.dev # needed by psych / needed by rails
  ];

  # this is required by the pg gem
  env.LD_LIBRARY_PATH = lib.makeLibraryPath [
    pkgs.krb5
    pkgs.openldap
  ];

  services.postgres.enable = true;

  languages.ruby = {
    enable = true;
    versionFile = ./.ruby-version;
    bundler.enable = true;
  };

  languages.javascript = {
    enable = true;
    yarn.enable = true;
    yarn.install.enable = true;
  };

  git-hooks.hooks = {
    shellcheck.enable = true;
    nixfmt-rfc-style.enable = true;
  };
}
