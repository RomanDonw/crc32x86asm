# CRC32 hardware-accelerated calculator.
## Description
### Basic
This program on pure aseembly (NASM) calculates CRC32 checksum of file using `crc32` x86-64 instruction from SSE 4.2 SIMD extension. Also this program doesn't use C standard library and all I/O based on Linux kernel system calls.

### Algorithm info
`crc32` instruction uses 0x1EDC6F41 polynom, that not compatible with other more common polynom 0x04C11DB7, but also has more ability to find errors.

### ABI compatibility
This program can be compiled and wiil work only on Linux with System V ABI.

## Dependencies
- x86-64-compatible CPU with SSE 4.2 support.
- Bash or compatible with it shell.
- Netwide Assembler (NASM).
- GNU Linker (ld).

## Building an application
1. Clone this repo and go to it folder.
2. Run `build.sh` script.
3. Go to created `build/` folder in the root of repository.
4. Run obtained executeable (default current name - `crc32`) and pass the name of file for CRC32 calculation as first parameter.
5. Get the checksum in hexadecimal representation from output of program.

