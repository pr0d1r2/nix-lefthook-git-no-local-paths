# Changelog

All notable changes to this project are documented here.

## Unreleased

### Fixed

- Use the standard's `confirm` app. The repository's own copy had a fixed
  fragment list without `bats`, so the guardrails workflow could not find the
  `lefthook-bats-parse` and `lefthook-bats-unit` wrappers it now needs.
- Drop the repo-local `lefthook-repo.yml` carried over from the vendored
  config: its bare `bats -c` and `taplo check` hooks exited 127 in the dev
  shell. The standard's `bats` fragment (auto-added for tracked specs) and the
  now-declared `toml` fragment provide `lefthook-bats-parse`,
  `lefthook-bats-unit`, `lefthook-tdd-order-bats` and `lefthook-taplo`.
- Refresh `set-and-setting` to get its `bats` and `toml` fragments, and set
  `switch_case_indent` for `*.sh` in `.editorconfig` (as the standard's own
  `.editorconfig` does) so the refreshed `shfmt` check keeps the existing
  case-indent style.
