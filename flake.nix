{
  description = "CHANGEME";

  nixConfig = {
    extra-substituters = [ "https://pr0d1r2.cachix.org" ];
    extra-trusted-public-keys = [ "pr0d1r2.cachix.org-1:NfWjbhgAj41byXhCKiaE+av3Vnphm1fTezHXEGsiQIM=" ];
  };

  inputs = {
    nixpkgs-lock.url = "github:pr0d1r2/nixpkgs-lock/1e6ffb1960305718ccd8935fcedd353d2b35a387";
    nixpkgs.follows = "nixpkgs-lock/nixpkgs";

    set-and-setting = {
      url = "github:pr0d1r2/set-and-setting";
      inputs.nixpkgs-lock.follows = "nixpkgs-lock";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      set-and-setting,
      ...
    }:
    set-and-setting.lib.mkConsumerFlake {
      inherit self nixpkgs set-and-setting;
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
      src = ./.;
    }
    // {
      devShells =
        nixpkgs.lib.mapAttrs
          (
            system: shells:
            builtins.mapAttrs (
              _name: shell:
              shell.overrideAttrs (old: {
                nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [
                  (import ./nix/bats-with-libs.nix nixpkgs.legacyPackages.${system})
                ];
                BATS_LIB_PATH = "${(import ./nix/bats-with-libs.nix nixpkgs.legacyPackages.${system})}/share/bats";
              })
            ) shells
          )
          (set-and-setting.lib.mkConsumerFlake {
            inherit self nixpkgs set-and-setting;
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
            src = ./.;
          }).devShells;
      apps = nixpkgs.lib.genAttrs (import ./nix/systems.nix) (
        system:
        (set-and-setting.lib.mkConsumerFlake {
          inherit self nixpkgs set-and-setting;
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
          src = ./.;
        }).apps.${system}
        // {
          # The reusable guardrails workflow invokes this app outside the dev
          # shell, so its coherence check needs the fragment wrappers itself.
          confirm = {
            type = "app";
            program = "${
              nixpkgs.legacyPackages.${system}.writeShellApplication {
                name = "confirm";
                runtimeInputs =
                  (set-and-setting.lib.materializationFor {
                    pkgs = nixpkgs.legacyPackages.${system};
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
                  }).packages
                  ++ [
                    nixpkgs.legacyPackages.${system}.coreutils
                    nixpkgs.legacyPackages.${system}.diffutils
                    nixpkgs.legacyPackages.${system}.findutils
                    nixpkgs.legacyPackages.${system}.gawk
                    nixpkgs.legacyPackages.${system}.git
                    nixpkgs.legacyPackages.${system}.gnugrep
                    (nixpkgs.legacyPackages.${system}.writeShellApplication {
                      name = "lefthook-actionlint";
                      runtimeInputs = [ nixpkgs.legacyPackages.${system}.actionlint ];
                      text = "exec actionlint \"$@\"";
                    })
                  ];
                text =
                  builtins.replaceStrings
                    [
                      "@FRAGMENTS_DIR@"
                      "@ASSEMBLE_SCRIPT@"
                      "@DETECT_SCRIPT@"
                      "@SETTING_SRC@"
                      "@CONFIRM_SCRIPT@"
                      "@CONFIRM_REV@"
                    ]
                    [
                      "${set-and-setting}/setting/integrations/lefthook"
                      "${set-and-setting}/setting/lib/assemble-lefthook.sh"
                      "${set-and-setting}/setting/lib/detect-fragments.sh"
                      "${self.packages.${system}.setting}"
                      "${set-and-setting}/lib/confirm.sh"
                      (set-and-setting.rev or "unknown")
                    ]
                    (builtins.readFile ./nix/confirm.sh);
              }
            }/bin/confirm";
          };
        }
      );
    };
}
