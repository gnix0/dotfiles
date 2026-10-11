# Neovim development configuration

Stow package: `nvim/.config/nvim` → `~/.config/nvim`. Based on LazyVim 16.0.1,
validated against Neovim 0.12.6. Keep projects and their toolchains explicit.

## Editing policy

There is **no formatter integration**, automatic formatting, snippet expansion,
bracket/quote pairing, or automatic tag completion. `=` is native indentation:
`==` for a line, visual `=` for a selection, `gg=G` for the buffer. Run external
formatters yourself when wanted. Existing formatter packages are not uninstalled.

Fallback indentation is four spaces, including Go and other filetype defaults.
Repository `.editorconfig` indentation takes precedence. Make recipes retain
literal tabs. EditorConfig whitespace trimming and final-newline save actions
are ignored. Diagnostics and `cargo check` may run on save; they do not edit source.

Completion opens only on `Ctrl-Space`, in insert and command-line modes.
`Ctrl-n/p` select, `Ctrl-y` accepts a selected item, `Ctrl-e` dismisses.
Enter remains newline/execute, and Tab remains a normal key. LSP snippet items
are discarded rather than expanded. No AI source or ghost text is enabled.

Nightfox uses its normal background. Inlay hints start disabled, folds are manual,
and diagnostics use signs/underlines rather than inline messages.

## Keys

| Key | Action |
| --- | --- |
| `=` | Native indentation |
| `Ctrl-Space` / `Ctrl-n,p,y,e` | Open / select / accept / dismiss completion |
| `<Space>ff` / `fg` / `fb` / `fr` | Telescope files / project grep / buffers / recent |
| `/` / `?` | Native forward/backward buffer search |
| `gl` | Diagnostic details with source |
| `[d` / `]d`, `[e` / `]e`, `[w` / `]w` | Previous/next diagnostic, error, warning |
| `<Space>sv` / `sh` / `se` / `sx` | Vertical/horizontal split / equalize / close |
| `<Space>sj` / `sk` / `s<` / `s>` | Resize split |
| `<Space>oo` / `ow` / `ot` | Choose task / task list / task action (existing Overseer) |
| `<Space>ch` | C/C++ source/header switch (existing clangd extra) |
| `<Space>uh` | Toggle display-only inlay hints |
| `<Space>ca` / `cr` | Explicit code action / rename |

Arrow keys are disabled in normal, insert, and visual modes. `Ctrl-d/u` and `n/N`
center the view. `<Space>s` contains split controls, not a search menu. Other
Telescope operations remain available through `:Telescope`, including
`lsp_document_symbols` and `lsp_workspace_symbols`.

## Language tools

Existing extras remain enabled. clangd, rust-analyzer, gopls, Pyright/Ruff, jdtls,
neocmakelsp, JSON/YAML servers, Taplo, and Marksman provide the existing language
support. Bash gains bash-language-server and ShellCheck; assembly gains asm-lsp.
System servers are preferred; Mason supplies missing supported general servers.
Rust still uses rustaceanvim/rustup, not a second rust-analyzer client. Its
background command is `cargo check`, without forcing all features.

Mason's Pyright, Bash, JSON, and YAML packages need Node.js and npm. Those
prerequisites are now installed on this machine. On machines without them,
absent servers are gated until the prerequisites are installed and Neovim is
restarted. No system packages are installed by this configuration.

Assembly, linker scripts, Make, shell, and DTS have parser/filetype support.
asm-lsp attaches only when the project has `.asm-lsp.toml`; configure its
instruction set, assembler, and compiler there. The example uses ARM/GAS; use
`riscv` or `x86-64` for other projects. Do not let embedded diagnostics fall back
to host GCC. See the [asm-lsp documentation](https://github.com/bergercookie/asm-lsp).
`dts-lsp` is optional and not present in the current Mason registry; DTS syntax
support does not imply semantic diagnostics. HDL support is deferred.

## Project-local compiler configuration

Copy only the relevant files from `examples/` into **your project**, adapting
paths, target names, flags, and build directories. Examples are documentation;
they are never loaded from the editor configuration directory automatically.

Launch `nvim` from the project root. Lazy reads a trusted `.lazy.lua` there
(or in a parent directory). Its trust prompt is provided by Neovim. Use separate
Neovim processes for different project environments; changing `:cd` does not
unload startup plugin overrides or reset inherited environment variables.

Generate a real compilation database from the project's build system:

```sh
cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
cmake --build build
```

`examples/native/.clangd` tells clangd to read `build/compile_commands.json`.
For CMake presets, set `CMAKE_EXPORT_COMPILE_COMMANDS` in the relevant preset
and use the project's configure/build/test preset names. For Make or other
builders, use the project's existing database generator, or an explicitly
installed capture tool such as Bear. Neovim does not generate, copy, or symlink
databases automatically. CMake regeneration on save is disabled.

For STM32/ARM and RISC-V, use `examples/embedded/`. Its `.lazy.lua` allowlists
only the selected compiler executables with `--query-driver`. Architecture,
ABI, CPU/FPU flags, includes, and defines come from the compilation database.
Nothing adds architecture flags globally. If GCC-specific flags are rejected
by clangd, remove only the identified flags in that project's `.clangd`.
See [clangd cross-compiler/system-header guidance](https://clangd.llvm.org/guides/system-headers).

For **ESP-IDF only**, activate the selected SDK in the project's shell:

```sh
cd /path/to/esp-project
. "$HOME/esp/esp-idf/export.sh"
export ESP_CLANGD="$HOME/.espressif/tools/esp-clangd/esp-21.1.3_20260408/esp-clangd/bin/clangd"
idf.py build
nvim
```

The ESP_CLANGD path above exists on this machine; adjust it when changing SDK
versions. Copy `examples/esp-idf/.lazy.lua` and `.clangd`, selecting the compiler
names for the project's actual IDF target. The Espressif clangd build is important
for Xtensa; the ordinary system clangd remains the default outside this project.

For embedded Rust, configure build targets in `.cargo/config.toml` and Cargo
commands, and use `examples/rust/.lazy.lua` for rust-analyzer's target/features.
The installed rustaceanvim version does not load a project `rust-analyzer.json`.
No global embedded target is selected.

## Builds and tests

Overseer discovers Make targets, Cargo commands, and `.vscode/tasks.json`.
Copy the CMake, Go, Python, or ESP-IDF task example into the appropriate project.
Adapt CMake tasks to presets where the project uses them. Ninja tasks assume an
existing `build/build.ninja`, not a particular configuration/generator.
Python tests prompt for the project interpreter, which must have pytest installed.
Start Neovim from the activated virtual environment when appropriate.

Choose tasks with `<Space>oo`. ESP-IDF flash and monitor tasks are separate,
explicit operations and prompt for the board's serial device. No task runs on
startup or save, and no flash task is a dependency of a build task.

## ELF inspection and debugging outside Neovim

Use the project's matching tool prefix; these examples do not launch automatically:

```sh
arm-none-eabi-readelf -h -S build/firmware.elf
arm-none-eabi-nm -n -S build/firmware.elf
arm-none-eabi-objdump -d -S build/firmware.elf
arm-none-eabi-size -A build/firmware.elf
arm-none-eabi-objdump -d -S build/firmware.elf > /tmp/firmware.asm
```

Open generated `.asm` in Neovim for reading. Keep generated/vendor/build output
out of manual source-editing operations. Native GDB uses `gdb -nx ./build/app`;
Rust can use `rust-gdb ./target/debug/app`. Go/Delve and Python/pdb/debugpy remain
external tools; Delve/debugpy are not installed or configured by the editor.

For embedded debugging, start OpenOCD separately using the board/probe/target
configuration selected for the actual hardware. Then:

```sh
arm-none-eabi-gdb -nx build/firmware.elf -x embedded.gdb
```

Copy and adapt `examples/debugging/embedded.gdb`. RISC-V uses its own GDB executable.
The GDB executable, server command/config, ELF path, and reset/init commands are
independent choices. `load` programs the target and must be requested explicitly.

`gf` is an external GDB frontend, not a DAP adapter. Copy and adapt
`examples/debugging/.project.gf` to select a project GDB/ELF. Native projects use
`/usr/bin/gdb`; ARM and RISC-V projects use their matching debugger. Start the
server separately and select Connect; Program is a separate explicit `load`.
The frontend supports stack, registers, watches, and console views according to
its [documentation](https://github.com/nakst/gf). It is not installed or GUI-tested
here; there is no claim that its UI meets every hardware-debugging need.

## Validation

See `VALIDATION.md` for this machine's verification results and remaining
interactive/hardware checks. LazyVim's formatting entrypoints are disabled in
`config.editing` for the installed version; recheck save policy after a LazyVim
upgrade. Restart Neovim after these changes so old plugins/autocmds do not remain
in an existing process.
