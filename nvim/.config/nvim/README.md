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
- [Templates and maintenance](#templates-and-maintenance)

## Starting a session

Run **`fwdev`**, choose new/existing and a project type, then follow its short
next-step report. Enter the project, review and allow `.envrc` if one was created,
and start `nvim` there. After that, use the project's normal build/debug commands.

```sh
fwdev                 # interactive setup
fwdev --dry-run       # same questions; no files or SDK activation
fwdev --help
```

The executable lives at `~/.local/bin/fwdev`, linked through the `dev` Stow package
to `dev/.local/bin/fwdev` in this repository. It is already executable. On another
machine, from the dotfiles root run `stow --no-folding --target="$HOME" dev nvim`.
The Zsh configuration adds `~/.local/bin` to PATH. Core requirements are Bash and
GNU coreutils; each project type checks its own toolchain. No system packages or
project dependencies are silently installed.

One-time shell integration is already in `.zshrc`:

```zsh
command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"
```

Open a new shell after changing it. For an environment-bearing project:

```sh
cd /path/to/project
cat .envrc             # review the selected SDK/environment code
direnv allow          # explicit approval; fwdev never does this
nvim
```

Direnv activates at the next shell prompt and restores the previous environment
when you leave. A subprocess such as fwdev cannot change its parent shell's
environment. `direnv exec /path/to/project COMMAND` supplies an authorized
environment to a command but **does not change the command's working directory**;
`cd` into the project first when the command relies on its working directory.

New tmux panes each run their own shell hook. Enter the desired project in each
pane; use independent Neovim sessions for different SDKs/virtualenvs. A running
Neovim process does not receive later shell environment changes. Restart it after
changing SDK or target. A host workspace opened in an IDF-started Neovim process
still selects system clangd when outside that IDF project.

New scaffolding is generated only into an empty/new directory. Rerunning with
New on a nonempty directory behaves as preparation: existing files are kept.
Existing CMake/preset/Make/Cargo/Go/Java/Python files and `.envrc` are never
executed or replaced by the initializer. Existing `.envrc` needs your own review
and any necessary merge; the initializer cannot infer its behavior safely.
Choose the same project type when rerunning. All interactive choices and required
dependency checks occur before writes. A failed external scaffolding command can
leave partial files; inspect these before retrying.

LazyVim's root may differ from `:pwd`; use `:lua print(LazyVim.root())` to inspect
it. File pickers/tasks use the detected root. Ordinary language support no longer
requires project-local Neovim Lua. Optional `.lazy.lua` files still require trust
and should be reserved for actual project-specific settings.

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

Initialization and development are separate. fwdev does not build, choose an MCU,
flash, monitor, run tests, or start a debugger. The normal loop is
**edit → save → build/test in a shell → inspect output → navigate diagnostics**.

Overseer remains optional: `Space oo` selects a task, `Space ow` opens its output
list, and `Space ot` provides task actions. It discovers supported Make/Cargo
commands and existing `.vscode/tasks.json`. No task files are generated by fwdev.
If you want custom tasks, create them using your real project commands; no task
runner is required to use this environment.

```sh
cmake --build build
ctest --test-dir build --output-on-failure
make                  # choose the project's documented target
ninja -C build        # requires a configured Ninja build
cargo check
cargo test
go test ./...
python -m pytest
```

Presets and project-native build commands take precedence over these generic
examples. Saving never runs a build or source-modifying action.

## Native C and C++ projects

Choose Native C/C++ in fwdev. For a new project, select C or C++; it creates only
`CMakeLists.txt` and `main.c`/`main.cpp`. Compilation database export is enabled
in the generated CMake file. No `.envrc`, `.clangd`, `.lazy.lua`, or tasks are needed.

```sh
cd /path/to/new_project
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Debug
cmake --build build
nvim
```

For an existing project, fwdev preserves all build files and reports whether it
found presets, CMake, or Make. It does not run existing project configuration code.
Select the appropriate preset/toolchain yourself. Enable
`CMAKE_EXPORT_COMPILE_COMMANDS=ON` through that build's existing configuration.
For an ordinary CMake project without presets:

```sh
cmake -S . -B build -G Ninja -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
```

clangd discovers a database at the project root or conventional `build/` directory;
there is no generated `.clangd` just to point at `build/`. For a nonstandard build
location, intentionally expose its database at the project root or configure its
location in your own `.clangd`. Existing configuration always remains yours.

For Make, use the project's database generator or an explicitly installed Bear:
`bear -- make <target>`. Capture a real compilation; an already up-to-date build
may produce no useful commands. fwdev does not clean the project for you.

The central module `lua/config/toolchains.lua` reads the conventional database
without executing its commands. It permits clangd to query exact installed
`/usr/bin/arm-none-eabi-*` or supported RISC-V GCC/G++ paths only when the database
names those compilers. It never grants a wildcard covering a repository or PATH.
CPU, ABI, include paths and defines come from the real database.

[clangd project setup](https://clangd.llvm.org/installation#project-setup) and
[system-header discovery](https://clangd.llvm.org/guides/system-headers) explain
why the compile command and the compiler's headers both matter.

## STM32 projects

Choose STM32 / ARM bare-metal in fwdev. It checks ARM GCC and reports missing
clangd/GDB/OpenOCD tools. New creates a workspace directory; existing inspects
build metadata. It does not generate firmware or replace your build system.

Bring your board-specific project into that directory: an existing firmware
repository, an appropriate Cube-generated project, or your own bare-metal setup.
You choose the MCU, CPU/FPU ABI, linker memory regions, startup/vector table,
clock configuration, HAL/RTOS and probe settings. Those choices belong in the
firmware project and are never guessed by fwdev.

For a project that already supplies a CMake toolchain file, for example:

```sh
cmake -S . -B build -G Ninja \
  -DCMAKE_TOOLCHAIN_FILE=cmake/arm-none-eabi.cmake \
  -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
cmake --build build
nvim
```

Use the project's actual toolchain filename or preset. No per-project Lua or
query-driver flags in `.clangd` are needed for the supported system compilers.
The database supplies all substantive target settings. Nonstandard compiler
installations require deliberate extension of the trusted paths in
`config/toolchains.lua`; unknown compiler paths are never auto-approved.

Inspect the linked ELF (replace its name with your real output):

```sh
arm-none-eabi-size -A build/firmware.elf
arm-none-eabi-readelf -h -S build/firmware.elf
arm-none-eabi-nm -n -S build/firmware.elf
arm-none-eabi-objdump -d -S build/firmware.elf > /tmp/firmware.asm
nvim /tmp/firmware.asm
```

For an ST-Link-equipped Nucleo-F4, check that `board/st_nucleo_f4.cfg` matches your
board before using it. Start its server separately:

```sh
openocd -f board/st_nucleo_f4.cfg
arm-none-eabi-gdb -nx build/firmware.elf  # in another terminal
```

```gdb
target extended-remote localhost:3333
monitor reset halt
break main
# Only if you intend to program the connected board:
load
continue
```

Connecting, resetting and programming are distinct operations. Other boards
require their own server/probe/reset configuration. RISC-V follows the same
workflow with its actual compiler, GDB, ELF and server configuration.
Hardware flashing/debugging is not part of the initializer's tests.

## ESP-IDF projects

This is the reference workflow:

```sh
fwdev                 # New → ESP-IDF → name → parent → trusted SDK directory
cd /path/to/project
cat .envrc
cat .clangd
direnv allow          # activates the selected SDK at the shell prompt
idf.py set-target esp32c6   # YOUR selection; only when creating/changing a target
idf.py reconfigure         # generates build/config and compile_commands.json
nvim
```

fwdev offers `$IDF_PATH` or `~/esp/esp-idf` as the SDK default; enter another
installed SDK path when needed. It validates the SDK location and uses its actual
`export.sh` in a subprocess, then official `idf.py create-project`. It does not
rely on `get_idf` or other interactive aliases. ESP-IDF project/SDK paths containing
whitespace are rejected before changes because the toolchain does not support them.
Native/Python paths with spaces are tested.

Only `.envrc` and a small ESP `.clangd` are added to the official scaffold:

- `.envrc` activates that SDK and exports a project-directory marker. Leaving
  restores the previous PATH and SDK variables through direnv. It does not
  select a target, configure, build or install anything.
- `.clangd` contains GCC compatibility fixes needed by the installed IDF 6.1 /
  Espressif clangd combination: use query-driver builtin headers and remove five
  unsupported GCC flags. It does not contain query-driver startup options,
  SDK paths, target flags or a database path. Existing `.clangd` is preserved;
  merge the compatibility entries if diagnostics show those known errors.

The central Neovim code uses the activated SDK's clangd from PATH under
`$IDF_TOOLS_PATH/tools/esp-clangd` (default `~/.espressif/tools`). It selects exact
SDK compiler paths present in the database, supporting unified and older
chip-specific Xtensa compiler names as well as RISC-V. It does not guess the chip
from a filename or hardcode a versioned tool directory. One clangd client handles
a workspace; its command is selected when that client starts.

For an existing project choose Existing → ESP-IDF. sdkconfig, components, build
files, selected target and existing environment/config files are preserved.
Review any existing `.envrc`: it must activate the intended SDK and export
`DEV_IDF_PROJECT="$PWD"` for the central selection. Do not copy a template over it.
If no database exists, run `idf.py reconfigure` in that authorized environment.
The database does not exist merely because the initializer completed.

`set-target` clears/reconfigures build settings: do not run it casually on an
existing project. fwdev never calls it. Restart Neovim after changing target or
SDK so the compiler allowlist is recalculated from the new database.

Continue with normal commands, each invoked intentionally:

```sh
idf.py build
idf.py -p /dev/ttyUSB0 flash
idf.py -p /dev/ttyUSB0 monitor
```

Choose the actual serial port. IDF Monitor exits with `Ctrl-]`; flash may build
first. JTAG debugging uses the selected SDK's GDB/OpenOCD and the board's actual
configuration, independently of Neovim. See the
[IDF command reference](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-guides/tools/idf-py.html).
If SDK clangd or compilers are missing, use the selected SDK's documented tools
installer yourself. fwdev never downloads a replacement SDK or toolchain.

## Rust, Go, Python, and Java

| fwdev choice | New project | Existing project |
| --- | --- | --- |
| Rust host | `cargo init --bin --vcs none` | Preserve Cargo metadata |
| Rust embedded | `cargo init --lib --vcs none`; library starting point only | Preserve target/runtime/features |
| Go | `go mod init` with the module path you supply | Preserve go.mod and source |
| Python | Small main.py; optional `.venv` and `.envrc` | Optionally reuse/create `.venv`; preserve files |
| Java | Plain src/Main.java | Preserve Maven/Gradle and source |

These languages receive no project Lua or task files. Rust, Go and Java need no
`.envrc` for ordinary system toolchains. No Git repository is created for you.

Rustaceanvim manages rust-analyzer and runs `cargo check`, without globally forcing
all features. Use `cargo check`, `cargo test`, `rust-gdb`, and `:RustLsp` as usual.
For embedded Rust, set the target/linker/runtime in the actual Cargo project;
creating a library is not a complete runnable firmware. Use standard
`.cargo/config.toml` target settings first. If rust-analyzer still requires distinct
feature/target overrides, the optional embedded Lua template is available for
manual adaptation and trust, never auto-installed.

Go uses gopls and go.mod. Add your packages, then `go test ./...` / `go build ./...`.
Delve remains an optional external dependency.

Python's optional `.venv` is created once using `python -m venv`. An existing
usable environment is reused; an unusable `.venv` is preserved and reported.
Review `.envrc`, run `direnv allow`, and install project dependencies through the
project's package manager. Leaving the directory restores the prior Python/PATH.
Pyright/Ruff remain configured; inspect the selected interpreter if imports are
wrong. `python -m pytest` needs pytest in that environment; `python -m pdb script.py`
needs no debug adapter. No packages are installed globally by fwdev.

Java uses jdtls. For an existing project use its Maven/Gradle wrapper after review.
For the new plain starter: `javac -d build src/Main.java`, then
`java -cp build Main`. fwdev does not assume Maven coordinates or Gradle plugins.
Jdtls workspaces remain separate per project; save-time import organization and
editor debug/test adapters remain disabled.

## Assembly, linker scripts, and device trees

`.S` is recognized as assembly; `.ld`/`.lds` as linker scripts; `.dtsi`/`.overlay`
as device tree. Treesitter covers asm/nasm, linker scripts, Make, and device tree.

Asm-lsp attaches only with `.asm-lsp.toml` in the project. Start from
[the optional assembly template](../../../dev/.local/share/fwdev/templates/optional/assembly/asm-lsp.toml) and choose the instruction
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

For ARM, adapt [the optional project GF template](../../../dev/.local/share/fwdev/templates/optional/debugging/project.gf):

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

The reusable [embedded.gdb](../../../dev/.local/share/fwdev/templates/optional/debugging/embedded.gdb) connects without
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
| ESP clangd fails at startup | Check `direnv status`, `IDF_PATH`, `DEV_IDF_PROJECT`, `command -v clangd`, SDK tool installation and the generated database; restart Neovim |
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

After changing the editor configuration, restart Neovim and review the changes.
Real board connection, flashing, and GF interaction must be checked on the actual
target. Use the compiler/build results as the authority for firmware correctness,
and review `git diff` before each commit.

## Templates and maintenance

Templates live in the Stow package at
[dev/.local/share/fwdev/templates](../../../dev/.local/share/fwdev/templates).
The old Neovim `examples/` tree has been replaced:

- `native/`: CMake and C/C++ source consumed by fwdev for new projects.
- `env/`: reviewed ESP-IDF/Python direnv files consumed by fwdev as needed.
- `esp-idf/clangd`: necessary ESP GCC/header compatibility configuration.
- `optional/`: assembly configuration, embedded Rust override, GF project config,
  and GDB connection commands. These are manual starting points, never copied by
  the initializer. Adapt names/settings before use.

There are no stored generic `.vscode` task collections or `.clangd` files solely
pointing at `build/`. Existing projects using the old `.lazy.lua` approach should
be reviewed: remove redundant clangd overrides after central detection works.
Do not change unrelated project-specific Lua. In particular, old overrides that
append flags to a table-valued `cmd` must be retired: central `cmd` now selects
one process command per workspace.

