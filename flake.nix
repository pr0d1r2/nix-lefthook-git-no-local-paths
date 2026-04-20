{
  description = "Lefthook-compatible local filesystem path detector";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };

  outputs =
    {
      self,
      nixpkgs,
    }:
    let
      supportedSystems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems =
        f: nixpkgs.lib.genAttrs supportedSystems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      packages = forAllSystems (pkgs: {
        default = pkgs.writeShellApplication {
          name = "lefthook-git-no-local-paths";
          runtimeInputs = [ pkgs.gnugrep ];
          text = builtins.readFile ./lefthook-git-no-local-paths.sh;
        };
      });

      devShells = forAllSystems (
        pkgs:
        let
          src-git-conflict-markers = builtins.fetchGit {
            url = "https://github.com/pr0d1r2/nix-lefthook-git-conflict-markers";
            ref = "main";
          };
          src-missing-final-newline = builtins.fetchGit {
            url = "https://github.com/pr0d1r2/nix-lefthook-missing-final-newline";
            ref = "main";
          };
          src-nix-no-embedded-shell = builtins.fetchGit {
            url = "https://github.com/pr0d1r2/nix-lefthook-nix-no-embedded-shell";
            ref = "main";
          };
          src-trailing-whitespace = builtins.fetchGit {
            url = "https://github.com/pr0d1r2/nix-lefthook-trailing-whitespace";
            ref = "main";
          };
          pkg-git-conflict-markers = pkgs.writeShellApplication {
            name = "lefthook-git-conflict-markers";
            runtimeInputs = [ pkgs.gnugrep ];
            text = builtins.readFile "${src-git-conflict-markers}/lefthook-git-conflict-markers.sh";
          };
          pkg-missing-final-newline = pkgs.writeShellApplication {
            name = "lefthook-missing-final-newline";
            text = builtins.readFile "${src-missing-final-newline}/lefthook-missing-final-newline.sh";
          };
          pkg-nix-no-embedded-shell = pkgs.writeShellApplication {
            name = "lefthook-nix-no-embedded-shell";
            text = ''
              SCANNER="${src-nix-no-embedded-shell}/scan-nix-no-embedded-shell.sh"
            ''
            + builtins.readFile "${src-nix-no-embedded-shell}/lefthook-nix-no-embedded-shell.sh";
          };
          pkg-trailing-whitespace = pkgs.writeShellApplication {
            name = "lefthook-trailing-whitespace";
            runtimeInputs = [ pkgs.gnugrep ];
            text = builtins.readFile "${src-trailing-whitespace}/lefthook-trailing-whitespace.sh";
          };
          batsWithLibs = pkgs.bats.withLibraries (p: [
            p.bats-support
            p.bats-assert
            p.bats-file
          ]);
        in
        {
          default = pkgs.mkShell {
            packages = [
              self.packages.${pkgs.stdenv.hostPlatform.system}.default
              pkg-git-conflict-markers
              pkg-missing-final-newline
              pkg-nix-no-embedded-shell
              pkg-trailing-whitespace
              batsWithLibs
              pkgs.coreutils
              pkgs.deadnix
              pkgs.editorconfig-checker
              pkgs.git
              pkgs.lefthook
              pkgs.nix
              pkgs.nixfmt
              pkgs.parallel
              pkgs.shellcheck
              pkgs.shfmt
              pkgs.statix
              pkgs.typos
              pkgs.yamllint
            ];
            shellHook = builtins.replaceStrings [ "@BATS_LIB_PATH@" ] [ "${batsWithLibs}" ] (
              builtins.readFile ./dev.sh
            );
          };
        }
      );
    };
}
