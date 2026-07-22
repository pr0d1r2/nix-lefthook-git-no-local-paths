pkgs:
pkgs.bats.withLibraries (p: [
  p.bats-support
  p.bats-assert
  p.bats-file
])
