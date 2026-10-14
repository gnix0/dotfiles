cmake_minimum_required(VERSION 3.20)
project(@NAME@ LANGUAGES @LANG@)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
add_executable(@NAME@ main.@EXT@)
