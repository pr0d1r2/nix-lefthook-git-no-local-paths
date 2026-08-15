forAllSystems: set-and-setting: src:
forAllSystems (
  pkgs:
  (set-and-setting.lib.checksFor {
    inherit pkgs src;
    fragments = [
      "base"
      "nix"
      "shell"
      "ascii"
      "markdown"
      "yaml"
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
