# Copy into the project root; change GDB and ELF for that project.
[gdb]
path=arm-none-eabi-gdb
arguments=-nx build/firmware.elf

[commands]
# Start OpenOCD separately with this board's actual configuration first.
Connect=target extended-remote localhost:3333
# Separate, explicit programming operation. Never part of editor startup/save.
Program=load
