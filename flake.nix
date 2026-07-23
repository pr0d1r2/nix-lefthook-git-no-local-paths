{
  description = "CHANGEME";

  nixConfig = {
    extra-substituters = [ "https://pr0d1r2.cachix.org" ];
    extra-trusted-public-keys = [ "pr0d1r2.cachix.org-1:NfWjbhgAj41byXhCKiaE+av3Vnphm1fTezHXEGsiQIM=" ];
  };

  inputs = {
    nixpkgs-lock.url = "github:pr0d1r2/nixpkgs-lock";
    nixpkgs.follows = "nixpkgs-lock/nixpkgs";

    set-and-setting.url = "github:pr0d1r2/set-and-setting";
  };

  outputs =
    {
      self,
      nixpkgs,
      set-and-setting,
      ...
    }:
    let
      fragments = [
        "base"
        "nix"
        "shell"
        "ascii"
        "markdown"
        "yaml"
      ];
      consumer = set-and-setting.lib.mkConsumerFlake {
        inherit
          self
          nixpkgs
          set-and-setting
          fragments
          ;
        src = ./.;
      };
    in
    consumer
    // {
      apps = nixpkgs.lib.genAttrs (import ./nix/systems.nix) (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          materialization = set-and-setting.lib.materializationFor {
            inherit pkgs fragments;
          };
        in
        consumer.apps.${system}
        // {
          # The reusable guardrails workflow invokes this app outside the dev
          # shell, so its coherence check needs the fragment wrappers itself.
          confirm = {
            type = "app";
            program = "${
              pkgs.writeShellApplication {
                name = "confirm";
                runtimeInputs = materialization.packages ++ [
                  pkgs.coreutils
                  pkgs.diffutils
                  pkgs.findutils
                  pkgs.gawk
                  pkgs.git
                  pkgs.gnugrep
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
                      "${consumer.packages.${system}.setting}"
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
