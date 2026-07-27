default rel
global @start

section .rodata

unableopenfile__rawstring:
    .start db "Unable to specified open file.", 10
    .end:

usage__rawstring:
    .start db "Usage:", 10, "    ./crc32 <unsigned 64-bit integer for CRC32 calculation>", 10
    .end:

unsuppsse42__rawstring:
    .start db "SSE 4.2 extension doesn't supported by this CPU.", 10
    .end:

section .text

%define BUFFER_SIZE 4096

@start:
    ; check is SSE 4.2 supported through CPUID instruction.
    mov eax, 1
    cpuid
    test ecx, 1 << 20
    jnz .sse42supported
        mov rax, 1
        mov rdi, rax
        lea rsi, [unsuppsse42__rawstring.start]
        mov rdx, unsuppsse42__rawstring.end - unsuppsse42__rawstring.start
        syscall
    jmp .errorquit
    .sse42supported:

    pop rdi
    mov rsi, rsp

    cmp edi, 2
    jae .hasminreqargcount
        mov rax, 1
        mov rdi, rax
        lea rsi, [usage__rawstring.start]
        mov rdx, usage__rawstring.end - usage__rawstring.start
        syscall
    jmp .errorquit
    .hasminreqargcount:

    mov rax, 2
    mov rdi, [rsi + 8]
    xor rsi, rsi
    mov rdx, rsi
    syscall
    cmp rax, 0
    jge .successopen
        mov rax, 1
        mov rdi, rax
        lea rsi, [unableopenfile__rawstring.start]
        mov rdx, unableopenfile__rawstring.end - unableopenfile__rawstring.start
        syscall
    jmp .errorquit
    .successopen:
    mov rdi, rax
    mov r8, rsi

    mov rbx, rsp
    mov rdx, BUFFER_SIZE
    sub rsp, rdx
    mov rsi, rsp
    .loop__start:
    xor rax, rax
    syscall
    cmp rax, 0
    jle .loop__end 

        xor rcx, rcx
        .loop2__start:
        cmp rcx, rax
        jae .loop2__end
            crc32 r8, byte [rsi + rcx]
        inc rcx
        jmp .loop2__start
        .loop2__end:

    cmp rax, rdx
    jz .loop__start
    .loop__end:
    mov rsp, rbx

    mov rdi, rax
    mov rax, 3
    syscall

    .quit:
    xor eax, eax
    call exit

    .errorquit:
    mov eax, 1
    call exit

; EAX - error code.
exit:
   movsx rdi, eax
   mov rax, 3Ch
   syscall
