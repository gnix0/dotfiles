# Invoke: arm-none-eabi-gdb -nx build/firmware.elf -x embedded.gdb
# Start the appropriate OpenOCD configuration in another terminal first.
target extended-remote localhost:3333
# Target-specific reset/init commands belong here, selected for the board.
# No automatic load/flash command.
