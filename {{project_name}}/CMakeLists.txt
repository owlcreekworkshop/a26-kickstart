cmake_minimum_required(VERSION 3.10)



set(CMAKE_TOOLCHAIN_FILE "atari2600.toolchain.cmake")
set(CMAKE_ASM_FLAGS "--debug-info")
set(CMAKE_EXE_LINKER_FLAGS "--config ${CMAKE_CURRENT_SOURCE_DIR}/atari2600.cfg --dbgfile ${CMAKE_PROJECT_NAME}.dbg")

set(SOURCES
    src/main.asm)

project(test ASM)

add_executable(${CMAKE_PROJECT_NAME}.a26 ${SOURCES})

set_target_properties(${CMAKE_PROJECT_NAME}.a26 
    PROPERTIES 
    ADDITIONAL_CLEAN_FILES ${CMAKE_PROJECT_NAME}.dbg)
