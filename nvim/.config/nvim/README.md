# Neovim development handbook

This is a keyboard-driven LazyVim setup for source editing, navigation, diagnostics,
and project tasks. Build tools and debuggers remain usable directly from the shell.
The editor uses the **Nightfox** colorscheme; Alacritty imports the Nightfox palette.

## Contents

- [Starting a session](#starting-a-session)
- [Editing and completion](#editing-and-completion)
- [Keymap reference](#keymap-reference)
- [Plugins and their jobs](#plugins-and-their-jobs)
- [Language support](#language-support)
- [Building and testing](#building-and-testing)
- [Native C and C++ projects](#native-c-and-c-projects)
- [STM32 projects](#stm32-projects)
- [ESP-IDF projects](#esp-idf-projects)
- [Rust, Go, Python, and Java](#rust-go-python-and-java)
- [Assembly, linker scripts, and device trees](#assembly-linker-scripts-and-device-trees)
- [Debugging with gf and GDB](#debugging-with-gf-and-gdb)
- [Maintenance and troubleshooting](#maintenance-and-troubleshooting)

## Starting a session

The Stow package is `nvim/.config/nvim`, linked to `~/.config/nvim`. Edit the
files in the repository to change your configuration.

1. Open a shell in your project root.
2. Activate the project's environment, if required: Python virtualenv, ESP-IDF,
   or a toolchain-specific PATH.
3. Configure/build once if the project needs generated headers or a compilation database.
4. Run `nvim .` for the directory or `nvim path/to/file` for a file.
5. Use `Space ff` to find source, `Space fg` to search its contents, and `Space oo`
   to choose a build/test task.

Neovim inherits the shell's environment when it starts. Existing sessions do not
inherit later shell changes. Use separate processes for projects using different
SDKs or compiler environments.

LazyVim's project root can differ from the current directory. `:pwd` shows the
current directory; `:lua print(LazyVim.root())` shows the detected root. Root-based
file search and tasks should operate on the project you intend.

A project may have a `.lazy.lua` containing editor plugin overrides. Read it before
accepting Neovim's trust prompt: it is executable Lua. Launch from that project
root. Changing `:cd` is not a substitute for restarting with another project's
startup overrides.

## Editing and completion

**Saving never invokes a formatter, import organizer, or automatic source fix.**
There is no formatter integration. External tools such as clang-format and rustfmt
remain available when you explicitly run them in a shell. Review their changes
with Git before committing.

Native Vim indentation is available:

- `==`: indent the current line.
- Visual selection followed by `=`: indent the selection.
- `gg=G`: indent the entire buffer; this changes indentation and is explicit.

Fallback indentation is four spaces. Project `.editorconfig` indentation takes
precedence; Make recipes use literal tabs. EditorConfig's save-time whitespace
trimming, encoding/end-of-line conversion, and final-newline edits are suppressed.
Treesitter indentation is disabled; native filetype indentation remains available.

Completion is manual in insert mode and the command line:

1. Press `Ctrl-Space` to open candidates.
2. Use `Ctrl-n` / `Ctrl-p` to select next/previous.
3. Press `Ctrl-y` to accept the selected candidate, or `Ctrl-e` to dismiss.
4. Use `Ctrl-f` / `Ctrl-b` to scroll completion documentation.

No candidate is preselected or inserted automatically. Enter inserts a newline
or executes the command line; Tab remains a normal key. Sources are LSP, paths,
and buffer words. Snippet-only suggestions are filtered out. There are no snippet
expansions, automatic bracket/quote pairs, automatic closing tags, or ghost text.

Diagnostics may update after editing/saving, and Rust may run `cargo check`.
Those checks report problems without rewriting source. Errors appear as signs
and underlines, not inline text. Use `gl` for the message and provider.

Folds are manual: `zf` creates a fold over a motion or selection, `zo` opens,
`zc` closes, and `za` toggles. Inlay hints begin disabled; `Space uh` toggles them
when the attached server supports them.

## Keymap reference

`Space` is the leader. Sequences such as `Space ff` mean press Space, f, f.
Pause after a prefix for which-key help. Language actions require an attached
server and its corresponding capability.

### Files, buffers, and navigation

| Keys / command | Action |
| --- | --- |
| `Space ff` | Find files from the project root |
| `Space fg` | Search project text with Telescope/ripgrep |
| `Space fb` | Select an open buffer |
| `Space fr` | Recently opened files |
| `Space bb` | Switch to the alternate buffer |
| `Space bd` | Delete the current buffer while retaining the window where possible |
| `/`, `?` | Search forward/backward in the current buffer |
| `n`, `N` | Repeat search and center the result |
| `Ctrl-d`, `Ctrl-u` | Half-page movement and center the view |
| `Esc` in normal mode | Clear search highlighting |
| `Ctrl-o`, `Ctrl-i` | Older/newer locations in the jump list |
| `:Telescope lsp_document_symbols` | Symbols in the current document |
| `:Telescope lsp_workspace_symbols` | Search workspace symbols |
| `:Telescope help_tags` | Search installed help |

Telescope accepts `Ctrl-n/p` for selection and Enter to open. Picker behavior can
be inspected with `:help telescope`. Arrow keys are disabled in normal, insert,
and visual modes; use Vim motions or the configured completion/picker controls.

### Splits

| Keys | Action |
| --- | --- |
| `Space sv`, `Space sh` | Vertical / horizontal split |
| `Ctrl-w h/j/k/l` | Focus left / below / above / right window |
| `Space se` | Equalize split sizes |
| `Space sx` | Close the current split |
| `Space sj`, `Space sk` | Decrease / increase height |
| `Space s<`, `Space s>` | Decrease / increase width by ten columns |

`Space s` is the split group. The usual LazyVim search menu under that prefix has
been removed; use the file mappings above or `:Telescope` for other pickers.

### Code and diagnostics

| Keys | Action |
| --- | --- |
| `gd` | Definition |
| `gr` | References |
| `gI` | Implementation |
| `gy` | Type definition |
| `K` | Hover/type documentation |
| `Space ca` | Explicit code action |
| `Space cr` | Rename a symbol through the language server |
| `Space ch` | C/C++ source/header switch |
| `Space ce` in Rust | Explain the diagnostic |
| `gl` | Diagnostics on the current line |
| `[d`, `]d` | Previous / next diagnostic |
| `[e`, `]e` | Previous / next error |
| `[w`, `]w` | Previous / next warning |
| `Space uh` | Toggle inlay hints |

Rename and code actions can edit several files. Inspect the resulting diff.
Formatting mappings such as `Space cf` and autoformat toggles are removed.

### Tasks, Git, and explicit surrounding edits

| Keys / command | Action |
| --- | --- |
| `Space oo` | Select and run an Overseer task |
| `Space ow` | Open/close the task list |
| `Space ot` | Task actions, including available restart/stop actions |
| `Space gg` | GitUI at the project root |
| `Space gG` | GitUI in the current directory |
| `gsa` + motion + surrounding character | Add surroundings; e.g. `gsaiw)` |
| `gsd` + surrounding character | Delete surroundings; e.g. `gsd)` |
| `gsr` + old + new surrounding character | Replace surroundings; e.g. `gsr)"` |
| `gsf`, `gsF` | Find surrounding characters right / left |
| `gsh` | Highlight surroundings |

Mini-surround edits happen only when requested. `:help MiniSurround` explains its
motions and selection behavior. GitUI has its own on-screen key reference.
Use shell `git status`, `git diff`, and `git diff --cached` to review work.

## Plugins and their jobs

| Component | What you use it for |
| --- | --- |
| Lazy / LazyVim | Plugin loading, default editor behavior, language extras |
| Nightfox | Syntax and UI colors |
| Blink | Manual completion and completion documentation |
| Telescope | Files, text, buffers, symbols, help, and other fuzzy pickers |
| Snacks | LazyVim utility UI, terminals, and supporting pickers/explorer functionality |
| which-key | Discover mappings by pausing after a prefix |
| nvim-lspconfig | Language server integration for most languages |
| Mason | Manage missing supported language servers and selected tools |
| Treesitter | Syntax structure/highlighting; indentation and automatic folds are disabled |
| treesitter-context | Keep enclosing source context visible while scrolling |
| illuminate | Highlight references to the symbol under the cursor |
| navic | Symbol breadcrumb/context information when supported by the server |
| mini.diff | Git change signs and optional diff overlay |
| mini.surround | Explicitly add/delete/replace surrounding characters |
| mini.hipatterns | Highlight configured textual patterns/color literals |
| Overseer | Run project tasks and retain their output/status |
| nvim-lint | Additional diagnostics such as ShellCheck |
| cmake-tools | CMake commands/project integration; save-time regeneration disabled |
| rustaceanvim | Rust-specific language server commands and Cargo checking |
| nvim-jdtls | Java project-aware language support |
| GitUI / gh extras | Terminal Git workflows and available GitHub CLI integration |
| dotfile extra | Additional dotfile syntax/filetype support |

Explore a plugin through `:Lazy` and `:help`; use `:LazyExtras` to inspect enabled
extras. No AI completion plugin or Neovim DAP integration is enabled.

## Language support

System-installed language servers are preferred when found before Mason's PATH
changes. Mason provides missing supported generic servers. Node/npm are required
for several servers; Java's server requires a compatible JDK.

| Language | Main tools / behavior |
| --- | --- |
| C/C++ | clangd, compile_commands.json, source/header switch |
| Rust | rust-analyzer through rustaceanvim/rustup; `cargo check` on save |
| Go | gopls, project go.mod; no second global golangci-lint pipeline |
| Python | Pyright type analysis and Ruff diagnostics |
| Java | jdtls; per-project workspace; no save-time import organization |
| CMake | neocmakelsp and cmake-tools |
| Shell | bash-language-server and ShellCheck |
| Assembly | asm-lsp only for projects with .asm-lsp.toml |
| JSON / YAML | JSON and YAML language servers |
| TOML | Taplo |
| Markdown | Marksman and available markdownlint diagnostics |
| Lua | lua-language-server |
| Linker scripts / Make / DTS | Filetype and Treesitter support |

Linker-script and DTS syntax highlighting does not guarantee semantic checking.
An optional DTS server is not installed by this setup. HDL support is deferred.
LSP completion, diagnostics, and navigation depend on server/project support.

## Building and testing

The normal loop is **edit → save → build/test → inspect output → navigate errors**.
Saving itself does not build, flash, or launch a debugger.

Overseer discovers supported project commands, including Make/Cargo and
`.vscode/tasks.json`. This file format is also useful without using VS Code.
Existing examples are under [examples](examples/); copy the relevant task file
into a project and adjust paths, names, and arguments. Never overwrite existing
project tasks: merge the entries you want.

Use `Space oo` to run, `Space ow` to inspect output, and `Space ot` for task actions.
Task error extraction depends on the problem matcher/output format. If tasks
are missing, confirm the detected project root and inspect `:OverseerRun`.
The same commands can always be run directly in a terminal.

Common shell commands:

```sh
cmake -S . -B build -G Ninja -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
cmake --build build
ctest --test-dir build --output-on-failure
make                 # or a documented target from the project's Makefile
ninja -C build       # requires an already configured Ninja build
cargo check
cargo test
go test ./...
python -m pytest
```

Use CMake configure/build/test presets when a project supplies them. Do not
replace project build conventions with the generic commands above.

## Native C and C++ projects

For a new project, define targets, include directories, defines, and language
standards in its build system. For an existing project, follow its build instructions.

1. Configure with compilation database export; choose a Debug build when needed:

   ```sh
   cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Debug \
     -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
   cmake --build build
   ```

2. Tell clangd where the database lives with a project `.clangd`:

   ```yaml
   CompileFlags:
     CompilationDatabase: build
   ```

3. Start `nvim` in the project root and open a translation unit. Use `K`, `gd`,
   and `gl` to inspect types, definitions, and diagnostics.
4. Run the project's tests before debugging or committing.

[examples/native/.clangd](examples/native/.clangd) supplies that database setting.
For Make projects, use the project's compilation database generator; if none
exists, an installed capture tool such as Bear can capture actual compiler commands.
Bear is a separate dependency. Regenerate the database after changing build flags.
Neovim does not copy/symlink it or run CMake on save.

clangd needs actual compile commands, not a global pile of include paths. Header
files can inherit a nearby source command; investigate the selected command when
a header's diagnostics differ from its owning translation unit.
See [clangd's compilation database guide](https://clangd.llvm.org/installation#project-setup).

## STM32 projects

For a new STM32F446RE project, choose a board-specific starting point: an existing
firmware repository, a compatible STM32Cube-generated project, or a deliberate
bare-metal build. Neovim does not generate the clock setup, startup assembly,
interrupt table, linker memory regions, HAL, or RTOS configuration.

1. Confirm the exact MCU, board, probe, and build system.
2. Confirm the cross compiler is on PATH:

   ```sh
   arm-none-eabi-gcc --version
   arm-none-eabi-gdb --version
   openocd --version
   ```

3. Configure using the project's toolchain file/preset, for example:

   ```sh
   cmake -S . -B build -G Ninja \
     -DCMAKE_TOOLCHAIN_FILE=cmake/arm-none-eabi.cmake \
     -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
   cmake --build build
   ```

   The toolchain filename is illustrative: use the project's real file. With Make,
   use its targets and compilation database capture instead.
4. Copy/adapt [embedded .clangd](examples/embedded/.clangd) and
   [embedded .lazy.lua](examples/embedded/.lazy.lua) into the project. The latter
   allows clangd to query only the selected compiler executables for target/includes.
5. Confirm compile commands contain the intended CPU, ABI, FPU flags, defines,
   and include paths. STM32F446RE is Cortex-M4F, but floating-point ABI and library
   choices must agree across the complete project. Keep these decisions in the build.
6. Open Neovim from this root and inspect diagnostics on a representative source file.
7. Inspect the linked ELF before programming:

   ```sh
   arm-none-eabi-size -A build/firmware.elf
   arm-none-eabi-readelf -h -S build/firmware.elf
   arm-none-eabi-nm -n -S build/firmware.elf
   arm-none-eabi-objdump -d -S build/firmware.elf > /tmp/firmware.asm
   nvim /tmp/firmware.asm
   ```

Replace `firmware.elf` with the produced target. Sections show memory usage,
symbols locate objects/functions, and mixed source/disassembly helps inspect
what the compiler emitted. A linker map generated by the build is also useful.

For an ST-Link-equipped Nucleo-F4 board, this installed OpenOCD script is a
starting point to check against the physical board:

```sh
openocd -f board/st_nucleo_f4.cfg
```

Then, in another terminal at the project root:

```sh
arm-none-eabi-gdb -nx build/firmware.elf
```

```gdb
target extended-remote localhost:3333
monitor reset halt
break main
# Only when you explicitly intend to program this connected board:
load
continue
```

Reset behavior is target/server-specific. `load` writes the image; omit it when
attaching to firmware already programmed. Other boards need their own OpenOCD
configuration, connection method, and reset strategy. Hardware connection and
flashing examples have not been exercised by this editor setup.
[OpenOCD's GDB guide](https://openocd.org/doc/html/GDB-and-OpenOCD.html) explains the connection.

RISC-V follows the same separation: correct compiler/database, compatible GDB,
server configuration, ELF, and target initialization. Do not reuse ARM debugger
paths or STM32 reset/configuration files.

## ESP-IDF projects

Use a dedicated shell for the selected SDK. Your shell has `get_idf`, equivalent
to sourcing `~/esp/esp-idf/export.sh`; it does not activate automatically.

For a new project:

```sh
get_idf
mkdir -p ~/projects
cd ~/projects
idf.py create-project my_esp_app
cd my_esp_app
idf.py --list-targets
idf.py set-target esp32     # replace with the actual chip, e.g. esp32c3
idf.py menuconfig
idf.py build
```

For an existing project, activate its required IDF version and run its documented
configuration/build steps. Do not casually run `set-target`: it clears the build
and regenerates sdkconfig. Keep sdkconfig.defaults and board choices deliberate.
See the [IDF command reference](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-guides/tools/idf-py.html).

For editor support:

1. Locate the Espressif clangd executable for the installed SDK. This machine's
   previously validated path was:

   ```sh
   export ESP_CLANGD="$HOME/.espressif/tools/esp-clangd/esp-21.1.3_20260408/esp-clangd/bin/clangd"
   test -x "$ESP_CLANGD"
   ```

   Check it after SDK upgrades. This export belongs in the project shell.
2. Copy/adapt [ESP .clangd](examples/esp-idf/.clangd) and
   [ESP .lazy.lua](examples/esp-idf/.lazy.lua) to the project. Select compiler names
   matching the actual chip: the supplied example uses xtensa-esp32-elf; C3/C6 use
   riscv32-esp-elf, while S3 uses xtensa-esp32s3-elf.
3. Confirm `build/compile_commands.json` exists after building. If not, configure
   database export with the project's IDF/CMake settings, for example
   `idf.py -DCMAKE_EXPORT_COMPILE_COMMANDS=ON reconfigure`.
4. Launch `nvim` from this activated shell. Approve the project Lua only after review.
5. Optionally merge [ESP tasks](examples/esp-idf/.vscode/tasks.json) into the
   project's `.vscode/tasks.json`; choose them using `Space oo`.

Build, programming, and serial monitoring are separate choices:

```sh
idf.py build
idf.py -p /dev/ttyUSB0 flash     # explicitly programs the selected device
idf.py -p /dev/ttyUSB0 monitor
```

Select the actual device (`/dev/ttyACM0` is also common). Exit IDF Monitor with
`Ctrl-]`. Flash can build first when needed. No editor task flashes automatically.
For JTAG debugging, use the selected IDF target's GDB and Espressif OpenOCD
configuration; do not substitute the STM32 example. SDK-specific hardware setup
is outside what has been validated here.

For a normal Linux project afterward, open a fresh shell and a new Neovim process.
This avoids leaking IDF PATH and SDK variables into unrelated work.

## Rust, Go, Python, and Java

### Rust

```sh
cargo new my_app
cd my_app
cargo check
nvim
cargo test
rust-gdb target/debug/my_app
```

Rustaceanvim manages rust-analyzer. Background diagnostics use `cargo check`, not
forced Clippy or all features. Use `:RustLsp` completion/help to discover actions;
`Space ce` explains errors. Code actions remain explicit.

For firmware, set the build target/linker in `.cargo/config.toml`, install the
required rustup target deliberately, and align rust-analyzer's target/features
using [the Rust project override](examples/rust/.lazy.lua). Its example is
`thumbv7em-none-eabihf` with default features disabled. Adapt it to your crate;
no global target is selected. Runner/probe-rs settings belong to the project.
Do not assume a `rust-analyzer.json` is read by this installed integration.

### Go

```sh
mkdir my_go_app
cd my_go_app
go mod init example.com/my_go_app
nvim
go test ./...
go build ./...
```

Gopls reads the module. Merge [Go tasks](examples/go/.vscode/tasks.json) if desired.
Delve is the language-specific debugger; it was not found on PATH during this
session. No Go debugger was installed as part of the editor setup.

### Python

```sh
mkdir my_python_app
cd my_python_app
python -m venv .venv
source .venv/bin/activate
# Install the project's declared dependencies/test tools using its chosen manager.
nvim
python -m pytest
python -m pdb path/to/script.py
```

Pyright and Ruff supply diagnostics. Set interpreter/configuration through the
project's pyproject.toml or supported Pyright configuration as needed; activating
a virtualenv alone should not be treated as proof that the server chose it.
Inspect server diagnostics and imports. Pytest must exist in the selected
environment. [Python tasks](examples/python/.vscode/tasks.json) prompt for an
interpreter. Debugpy was not importable in the system Python at the last check.

### Java

Open the project root with its Maven/Gradle files. Jdtls supplies navigation,
completion, and diagnostics. Use the project wrapper (`./gradlew test`, `./mvnw test`)
when provided. Its JDT workspace is kept distinct per project. Java formatting,
import organization on save, and editor debug/test adapters are disabled.

## Assembly, linker scripts, and device trees

`.S` is recognized as assembly; `.ld`/`.lds` as linker scripts; `.dtsi`/`.overlay`
as device tree. Treesitter covers asm/nasm, linker scripts, Make, and device tree.

Asm-lsp attaches only with `.asm-lsp.toml` in the project. Start from
[the assembly example](examples/assembly/.asm-lsp.toml) and choose the instruction
set (`arm`, `riscv`, or `x86-64`), assembler dialect, and matching compiler.
Its example disables host-compiler fallback diagnostics. Highlighting is not
proof the assembler accepts the source: assemble/build it with the real toolchain.
See [asm-lsp](https://github.com/bergercookie/asm-lsp) for supported configuration.

Linker scripts and generated disassembly are useful alongside readelf/nm/objdump.
DTS semantic validation still comes from the project's compiler/build tools.
Do not manually format generated files or vendor code as part of unrelated edits.

## Debugging with gf and GDB

`gf` is installed at `~/gf/gf2`, built from [nakst/gf](https://github.com/nakst/gf).
The zsh alias `gf` launches that binary from any current directory and forwards
arguments without changing directory. Open a new zsh, or enable it immediately:

```sh
alias gf='"$HOME/gf/gf2"'
```

For native debugging:

```sh
cd /path/to/project
gf --args ./build/app argument1 argument2
```

Build with debug information. GCC `-g -Og` is a useful development starting point;
keep the actual optimization settings when investigating optimization-dependent
bugs. Debugging a stripped binary or an ELF from another build makes source
inspection unreliable.

GF provides source, console, watches, breakpoints, stack, registers, data/memory,
and threads. Default execution shortcuts in the installed source are:

| Keys | Action |
| --- | --- |
| `Shift-F5` | Run the program |
| `Ctrl-F5` | Start and pause at entry |
| `F5` | Continue |
| `F10` | Step over |
| `F11` | Step into |
| `Shift-F10` | Step out of the current block |
| `Shift-F11` | Step out of the current function |

Its default F4 connection targets port 1234. For OpenOCD on port 3333, use the
project's Connect command or the GDB console instead. Its console accepts ordinary
GDB commands:

| Command | Purpose |
| --- | --- |
| `break main`, `break file.c:42` | Stop at a function or line |
| `run`, `continue` | Start/resume native execution |
| `next`, `step`, `finish` | Step over, into, or out of a function |
| `bt`, `frame 2` | Stack trace / select stack frame |
| `print value`, `print /x value` | Evaluate a value / hexadecimal display |
| `watch value` | Stop when a value changes, subject to target support |
| `info threads`, `thread 2` | Inspect/select threads |
| `info registers` | Register values |
| `x/16wx address` | Inspect 16 hexadecimal words in memory |
| `disassemble /s function` | Mixed source/disassembly |

The UI supports configurable keyboard shortcuts; the upstream README describes
Shift-F10 for stepping out of a block, Shift-F11 out of a function, and watch
format changes with `/`. Evaluate its interface tomorrow; compilation alone does
not validate GUI behavior or a hardware session. On Hyprland, this X11 application
uses XWayland. Keep standard GDB prompts/output: prompt-changing dashboard plugins
can interfere with GF's communication.

GF reads `~/.config/gf2_config.ini` and then the current directory's `.project.gf`.
A native project can select its ELF explicitly:

```ini
[gdb]
path=/usr/bin/gdb
arguments=-nx build/app
```

For ARM, adapt [the project GF example](examples/debugging/.project.gf):

```ini
[gdb]
path=/usr/bin/arm-none-eabi-gdb
arguments=-nx build/firmware.elf

[commands]
Connect=target extended-remote localhost:3333
Program=load
```

Start OpenOCD separately with the actual board configuration, then select Connect.
Use the console for target-specific initialization; Program is an explicit flash
operation, not a connection prerequisite. `.project.gf` is not automatically
created or loaded by Neovim. Launch GF from the firmware project root.

The reusable [embedded.gdb](examples/debugging/embedded.gdb) connects without
programming. Terminal alternative:

```sh
arm-none-eabi-gdb -nx build/firmware.elf -x embedded.gdb
```

GDB itself also offers `gdb -tui ./build/app`. Rust uses `rust-gdb`; selecting a
Rust wrapper in GF should be tested against the installed wrapper and project.
QEMU debugging requires an emulated machine compatible with your firmware; the
presence of QEMU does not imply STM32F446 peripherals are emulated.

To rebuild GF later, review upstream changes, then run `git pull --ff-only` and
`./build.sh` in `~/gf`. It builds with system G++, X11, and optional FreeType;
no sudo installation is required.

## Maintenance and troubleshooting

| Symptom | First checks |
| --- | --- |
| No language features | `:checkhealth vim.lsp`, `:lua vim.print(vim.lsp.get_clients({bufnr=0}))`, `:Mason`; confirm filetype/root/server executable |
| Wrong C/C++ includes or architecture | Inspect compile_commands.json, `.clangd`, selected compiler, and query-driver paths; rebuild generated headers |
| ESP project override fails at startup | Activate the correct SDK, verify ESP_CLANGD and target compiler executables, then restart Neovim |
| Wrong Python import/type information | Verify project interpreter/config and virtualenv dependencies |
| Missing tasks | Verify root, build manifests, and `.vscode/tasks.json`; try the shell command directly |
| No completion popup | Press Ctrl-Space; if LSP candidates are missing, check server attachment |
| No snippet suggestion | Intentional: snippets are disabled and snippet-only candidates filtered |
| Formatter command/key absent | Intentional: use native `=` or explicitly run an external formatter |
| GF fails to open | Confirm graphical session/XWayland and `~/gf/gf2`; inspect terminal error output |
| GDB cannot connect | Confirm server is running, port, probe permissions, board configuration, and matching debugger |
| Thin strip below Neovim | Alacritty draws whole text cells; leftover pixels retain terminal background, independent of the editor grid |

Use `:Lazy` to inspect plugin versions/loading, `:Mason` for tool status, `:messages`
for recent errors, and `:checkhealth` for diagnostics. Language/task integrations
load lazily, so an empty startup does not exercise every tool.

Update plugins deliberately through Lazy, review changes, and restart. Preserve
`lazy-lock.json` for reproducible plugin revisions. SDK/compiler upgrades are
separate from plugin upgrades. Check project-local compiler paths afterward.

After changing the editor configuration, the existing behavioral suite can run
from `~/.config/nvim`:

```sh
nvim --headless -i NONE '+lua dofile("tests/verify.lua")'
```

It uses temporary fixtures and exercises editing/completion/save behavior; it
does not program hardware. [VALIDATION.md](VALIDATION.md) records earlier machine
checks and their limits. Real board connection, flashing, and GF interaction must
be checked on the actual target. Use the compiler/build results as the authority
for firmware correctness, and review `git diff` before each commit.
