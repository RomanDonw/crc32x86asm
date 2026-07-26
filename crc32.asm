default rel
global main

section .rodata

unsuppsse42__string db "SSE 4.2 extension doesn't supported by this CPU.", 0
scanffmt__string db "%llu", 0
printCRC32resultfmt__string db "'crc32' instruction result of %llu is 0x%llX.", 10, 0
failedreadval__string db "Failed to parse value.", 0
usage__string db "Usage:", 10, "    ./crc32 <unsigned 64-bit integer for CRC32 calculation>", 0

section .text
    extern printf
    extern puts
    extern sscanf

main:
    push rbx

    cmp edi, 2
    jae .hasminreqargcount
        lea rdi, [usage__string]
        call puts
    jmp .errorquit
    .hasminreqargcount:
    mov rbx, [rsi + 8]

    ; check is SSE 4.2 supported through CPUID instruction.
    mov eax, 1
    push rbx
        cpuid
    pop rbx
    test ecx, 1 << 20
    jnz .sse42supported
        lea rdi, [unsuppsse42__string]
        call puts
    jmp .errorquit
    .sse42supported:

    sub rsp, 16
        mov rdi, rbx
        lea rsi, [scanffmt__string]
        mov rdx, rsp
        call sscanf
        mov rbx, [rsp]
    add rsp, 16
    cmp eax, 1 ; checks strictly on 1 because if use 'test' -1 also passed as correct result.
    jz .successreadval
        lea rdi, [failedreadval__string]
        call puts
    jmp .errorquit
    .successreadval:
    
    xor rdx, rdx
    crc32 rdx, rbx

    lea rdi, [printCRC32resultfmt__string]
    mov rsi, rbx
    call printf

    .quit:
    pop rbx
    xor rax, rax
    ret

    .errorquit:
    pop rbx
    mov rax, 1
    ret
