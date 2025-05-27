{
  pkgs,
  lib,
  ...
}:

let
  isCI = builtins.getEnv "CI" != "";
in
{
  packages = with pkgs; [
    git
    chromedriver # used by tests
    libyaml.dev # needed by psych / needed by rails
  ];

  # this is required by the pg gem on linux
  env = lib.mkIf (isCI) {
    LD_LIBRARY_PATH = lib.makeLibraryPath [
      pkgs.krb5
      pkgs.openldap
    ];
  };

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

  # don't enable git-hooks on CI
  # although this also disables being able to execute these checks with `devenv test`
  # it's ok because hooks are broken in CI anyways.
  #
  # If we have a dev that can't use hooks on linux we should change this conditional
  git-hooks.hooks = lib.mkIf (!isCI) {
    shellcheck.enable = true;
    nixfmt-rfc-style.enable = true;
  };
}
