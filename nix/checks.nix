forAllSystems: set-and-setting: src:
forAllSystems (
  pkgs:
  (set-and-setting.lib.checksFor {
    inherit pkgs src;
    fragments = [
      "base"
      "actions"
      "nix"
      "shell"
      "ascii"
      "bats"
      "markdown"
      "yaml"
      "toml"
    ];
  })
  // {
    actionlint = pkgs.runCommand "actionlint-check" { nativeBuildInputs = [ pkgs.actionlint ]; } ''
      actionlint ${src}/.github/workflows/*.{yml,yaml}
      touch $out
    '';
    default = pkgs.runCommand "checks" { } "touch $out";
  }
)
