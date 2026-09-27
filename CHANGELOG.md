# Changelog

All notable changes to this project are documented here.

## Unreleased

### Fixed

- Refresh `set-and-setting` to get its `bats` and `toml` fragments, and set
  `switch_case_indent` for `*.sh` in `.editorconfig` (as the standard's own
  `.editorconfig` does) so the refreshed `shfmt` check keeps the existing
  case-indent style.
