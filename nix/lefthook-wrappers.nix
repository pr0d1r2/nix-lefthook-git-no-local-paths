{ pkgs, inputs }:
let
  wrap =
    name: src: extra:
    pkgs.writeShellApplication (
      {
        inherit name;
        text = builtins.readFile "${src}/${name}.sh";
      }
      // extra
    );
in
[
  (wrap "lefthook-nixfmt" inputs.nix-lefthook-nixfmt-src {
    runtimeInputs = [ pkgs.nixfmt ];
  })
  (wrap "lefthook-shellcheck" inputs.nix-lefthook-shellcheck-src {
    runtimeInputs = [ pkgs.shellcheck ];
  })
  (wrap "lefthook-shfmt" inputs.nix-lefthook-shfmt-src {
    runtimeInputs = [ pkgs.shfmt ];
  })
  (wrap "lefthook-statix" inputs.nix-lefthook-statix-src {
    runtimeInputs = [ pkgs.statix ];
  })
  (wrap "lefthook-deadnix" inputs.nix-lefthook-deadnix-src {
    runtimeInputs = [ pkgs.deadnix ];
  })
  (wrap "lefthook-bats-parse" inputs.nix-lefthook-bats-parse-src {
    runtimeInputs = [ pkgs.bats ];
  })
  (wrap "lefthook-bats-unit" inputs.nix-lefthook-bats-unit-src {
    runtimeInputs = [
      pkgs.bats
      pkgs.coreutils
      pkgs.parallel
    ];
  })
  (wrap "lefthook-yamllint" inputs.nix-lefthook-yamllint-src {
    runtimeInputs = [ pkgs.yamllint ];
  })
  (wrap "lefthook-typos" inputs.nix-lefthook-typos-src {
    runtimeInputs = [ pkgs.typos ];
  })
  (wrap "lefthook-editorconfig-checker" inputs.nix-lefthook-editorconfig-checker-src {
    runtimeInputs = [ pkgs.editorconfig-checker ];
  })
  (wrap "lefthook-git-conflict-markers" inputs.nix-lefthook-git-conflict-markers-src {
    runtimeInputs = [ pkgs.gnugrep ];
  })
  (wrap "lefthook-missing-final-newline" inputs.nix-lefthook-missing-final-newline-src { })
  (wrap "lefthook-trailing-whitespace" inputs.nix-lefthook-trailing-whitespace-src {
    runtimeInputs = [ pkgs.gnugrep ];
  })
  (pkgs.writeShellApplication {
    name = "lefthook-nix-no-embedded-shell";
    runtimeInputs = [ pkgs.git ];
    text = ''
      SCANNER="${inputs.nix-lefthook-nix-no-embedded-shell-src}/scan-nix-no-embedded-shell.sh"
    ''
    + builtins.readFile "${inputs.nix-lefthook-nix-no-embedded-shell-src}/lefthook-nix-no-embedded-shell.sh";
  })
  (
    let
      get-file-size-limit = pkgs.writeShellApplication {
        name = "get-file-size-limit";
        runtimeInputs = [
          pkgs.gawk
          pkgs.gnugrep
        ];
        text = builtins.readFile "${inputs.nix-lefthook-file-size-check-src}/get-file-size-limit.sh";
      };
    in
    wrap "lefthook-file-size-check" inputs.nix-lefthook-file-size-check-src {
      runtimeInputs = [
        get-file-size-limit
        pkgs.gawk
        pkgs.gnugrep
        pkgs.coreutils
      ];
    }
  )
]
