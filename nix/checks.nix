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
      "markdown"
      "yaml"
    ];
  })
  // {
    default = pkgs.runCommand "checks" { } "touch $out";
  }
)
