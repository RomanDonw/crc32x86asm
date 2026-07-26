#!/bin/sh
if [ ! -d "build" ]; then
    mkdir build
fi

nasm -f elf64 crc32.asm -o build/crc32.o
gcc -no-pie build/crc32.o -o build/crc32
