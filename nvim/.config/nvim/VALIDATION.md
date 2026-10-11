# Validation — 2026-10-11

## Environment

- Neovim 0.12.6; LazyVim 16.0.1 (`99970099`). Neither was upgraded.
- Nordic installed and selected; its revision is recorded in `lazy-lock.json`.
- System clangd 23.1.1 selected explicitly instead of the existing Mason copy.
- Rustup stable toolchain present, with rust-analyzer; system Go and OpenJDK 25 present.
- ARM GCC/GDB, OpenOCD, ST-Link tools, probe-rs, QEMU, CMake, Ninja, and Make present.
- ESP-IDF 6.1 activates successfully in a separate shell. Its Xtensa/RISC-V
  compilers and Espressif clangd are installed outside the normal PATH.
- Node.js 26.11.1 and npm 12.2.0 were installed by the user during this session.
- Mason installed asm-lsp, Pyright, bash-language-server, JSON/YAML servers,
  and markdownlint-cli2. Existing system packages and previously installed
  Mason tools were preserved. No system packages were installed by this work.

## Results

| Check | Result |
| --- | --- |
| Lua parsing | All 15 Lua files, including project examples and the test harness, passed |
| JSON/TOML parsing | Configuration and task/example files passed |
| Headless startup | Passed with no startup error; one empty-buffer run recorded 38.7 ms before `NVIM STARTED` |
| Editing behavior suite | 128 checks passed, zero failed |
| Save policy | Exact content preservation across 16 filetypes, including trailing spaces and absent final newlines |
| Encoding/line endings | CRLF preserved despite conflicting EditorConfig encoding/line-ending/save-edit properties |
| Indentation | Four-space fallback, two-space EditorConfig override, Make tabs, and native `gg=G` verified |
| Completion/pairing | Manual-only menus, snippet filtering, Enter/Tab policy, no ghost text; typed brackets/quotes inserted only the typed character |
| Plugin configuration | Conform, snippet plugins, mini.pairs, autotag, and DAP absent from the active plugin specification |
| Mappings/display | Telescope grep, split mappings, `gl`, arrow disabling, manual folds, and diagnostics policy verified |
| Treesitter | asm, nasm, linkerscript, make, and devicetree parsers installed and loaded |
| Live LSP checks | Attachment, successful requests, and unchanged saves verified for C/C++, Go, Python, Java, Rust, CMake, JSON, YAML, TOML, Markdown, shell, assembly, and Lua fixtures |
| LSP editing policy | Attached clients advertised no snippet support, exposed no formatting/save-edit methods, and left `formatexpr` empty; Ruff attachment/policy also checked |
| Native/ARM/RISC-V/ESP32 | Each minimal fixture compiled using its actual compiler and passed clangd's `--check` |
| Project isolation | Separate Neovim processes loaded the correct `.lazy.lua` overrides and answered clangd requests; native process had no cross-toolchain allowlist |
| Actual ESP-IDF example | Passed with SDK export activated only in the test shell and the SDK's clangd selected explicitly |
| CMake save behavior | Regeneration disabled and compilation-database copying/symlinking disabled |
| Tasks | All 14 example task definitions converted through Overseer; interpreter/serial inputs resolved |
| Native build tasks | CMake configure, build, test, and clean executed successfully against a temporary project |

The initial CMake symbol request exceeded an 8-second timeout; a focused retry
with a 20-second timeout passed. Cold language-server readiness may take longer
than editor startup. The headless startup timing excludes UI attachment and
language-server initialization and is not an interactive performance benchmark.

## Repeat the editing suite

From this configuration directory:

```sh
nvim --headless -i NONE '+lua dofile("tests/verify.lua")'
```

The harness creates temporary fixtures, simulates the UI startup event, loads
the relevant plugins, and writes results to `/tmp/nvim-verification.txt`.
Missing servers/parsers should be installed before using it as an upgrade check.
The broader LSP, compiler, and task checks were performed with separate temporary
fixtures; no production project source files were modified.

## Remaining limits

- Restart existing Neovim processes to clear their old loaded plugins/hooks.
- No physical target was connected; OpenOCD target initialization, flashing,
  ST-Link/probe-rs operations, and board-specific debug behavior remain untested.
- No complete STM32 or ESP-IDF firmware project was built. The cross-compilation
  checks used minimal target-specific C fixtures, not SDK-wide builds.
- gf is not installed or GUI-tested. Its examples follow upstream documentation;
  they do not establish whether its UI fits every debugging need.
- System Python lacks pytest. Use a project interpreter with pytest installed.
- Delve/debugpy and optional dts-lsp remain external dependencies when needed.
- JSON server completion may require snippet support, which is deliberately
  disabled. JSON diagnostics/schema validation and ordinary buffer/path completion
  remain available; no snippet exception was added.
- The plain RISC-V GCC/GDB toolchain names in the generic embedded example are
  not on PATH; adapt them to the project's installed toolchain. The installed
  ESP-IDF RISC-V compiler was used for the actual RISC-V fixture.
- Project `.lazy.lua` settings load at startup. Changing `:cd` does not switch
  toolchain environments; use a separate editor process for each environment.
- Revalidate after LazyVim/Neovim upgrades, particularly formatting entrypoints,
  LSP save edits, completion capabilities, and EditorConfig save behavior.

## File inventory

Modified existing files:

- `lua/config/options.lua`: explicit editing defaults and policy initialization.
- `lua/config/keymaps.lua`: previous navigation/splits/diagnostics and removal of
  formatter/search-menu/snippet mappings.
- `lazy-lock.json`: Nordic revision and removal of disabled feature entries.
- `README.md`: workflow, keymap, dependency, and project-local configuration reference.

Created:

- `lua/config/editing.lua`: save/format/snippet capability policy and indentation handling.
- `lua/plugins/editing.lua`: completion, excluded plugins, and parser configuration.
- `lua/plugins/languages.lua`: server selection, diagnostics, Rust/Java/CMake setup.
- `lua/plugins/navigation.lua`: Telescope and split-menu configuration.
- `lua/plugins/colorscheme.lua`: Nordic configuration.
- `examples/`: native/embedded/ESP-IDF compiler settings, Rust target settings,
  assembly settings, project tasks, and external GDB/gf examples.
- `tests/verify.lua`: repeatable editing-policy and startup checks.
- `VALIDATION.md`: this report.

The existing extras list, bootstrap configuration, example plugin file, and
unrelated repository changes were preserved. Existing inactive plugin/tool caches
were not cleaned. Temporary project trust entries created for testing were removed.
