pkgs:
pkgs.writeShellApplication {
  name = "lefthook-git-no-local-paths";
  runtimeInputs = [ pkgs.gnugrep ];
  text = builtins.readFile ../lefthook-git-no-local-paths.sh;
}
