cmake_minimum_required(VERSION 3.10)

find_package (Python COMPONENTS Interpreter)

set(CMAKE_TOOLCHAIN_FILE "a26.toolchain.cmake")

set(SOURCES
    src/main.asm)

project({{project_name}} ASM)

add_executable(${CMAKE_PROJECT_NAME}.a26 ${SOURCES})

add_custom_command(TARGET ${CMAKE_PROJECT_NAME}.a26
    POST_BUILD
    COMMAND ${Python_EXECUTABLE} 
        ${PROJECT_SOURCE_DIR}/scripts/vice2dasm.py 
        ${PROJECT_SOURCE_DIR}/build/${CMAKE_PROJECT_NAME}.vice 
        ${PROJECT_SOURCE_DIR}/build/${CMAKE_PROJECT_NAME}.sym)

set(CMAKE_ASM_FLAGS "--cpu 6502X --debug-info -I ${CMAKE_CURRENT_SOURCE_DIR}/include")
set(CMAKE_EXE_LINKER_FLAGS "--config ${CMAKE_CURRENT_SOURCE_DIR}/a26.ld65.cfg --dbgfile ${CMAKE_PROJECT_NAME}.dbg -Ln ${CMAKE_PROJECT_NAME}.vice -m ${CMAKE_PROJECT_NAME}.map")

set_target_properties(${CMAKE_PROJECT_NAME}.a26 
    PROPERTIES 
    ADDITIONAL_CLEAN_FILES "${CMAKE_PROJECT_NAME}.dbg;${CMAKE_PROJECT_NAME}.sym;${CMAKE_PROJECT_NAME}.vice;${CMAKE_PROJECT_NAME}.map")

