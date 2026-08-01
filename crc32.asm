default rel
global @start

section .rodata

unableopenfile__rawstring:
    .start db "Unable to specified open file.", 10
    .end:

usage__rawstring:
    .start db "Usage:", 10, "    ./crc32 <path to file for hardware CRC32 calculation>", 10
    .end:

unsuppsse42__rawstring:
    .start db "SSE 4.2 extension doesn't supported by this CPU.", 10
    .end:

readfileerror__rawstring:
    .start db "Reading file error.", 10
    .end:

hexprefix__rawstring:
    .start db "0x"
    .end:

fsobjisdir__rawstring:
    .start db "File system object by specified path is directory.", 10
    .end:

section .text

BUFFER_SIZE equ 4096

O_RDONLY equ 0
O_DIRECTORY equ 10000h

AT_FDCWD equ -100

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

    cmp rdi, 2
    jae .hasminreqargcount
        mov rax, 1
        mov rdi, rax
        lea rsi, [usage__rawstring.start]
        mov rdx, usage__rawstring.end - usage__rawstring.start
        syscall
    jmp .errorquit
    .hasminreqargcount:

    mov rax, 101h
    mov rdi, AT_FDCWD
    mov rsi, [rsi + 8]
    ;mov rdx, O_RDONLY
    xor rdx, rdx
    mov r10, rdx
    syscall
    cmp rax, 0
    jge .successopen
        cmp rax, -21
        jz .fsobjisdir

        mov rax, 1
        mov rdi, rax
        lea rsi, [unableopenfile__rawstring.start]
        mov rdx, unableopenfile__rawstring.end - unableopenfile__rawstring.start
        syscall
    jmp .errorquit
    .successopen:
    mov rdi, rax

    mov rbx, rsp
    mov rdx, BUFFER_SIZE
    sub rsp, rdx
    mov rsi, rsp
    .loop__start:
    xor rax, rax
    syscall
    cmp rax, 0
    jg .loop_noreaderror
    jz .loop__end
        mov rsp, rbx

        push rax
            mov rax, 3
            syscall
        pop rax

        cmp rax, -21
        jz .fsobjisdir

        mov rax, 1
        mov rdi, rax
        lea rsi, [readfileerror__rawstring.start]
        mov rdx, readfileerror__rawstring.end - readfileerror__rawstring.start
        syscall
    jmp .errorquit
    .loop_noreaderror:

        xor rcx, rcx
        .loop2__start:
        cmp rcx, rax
        jae .loop2__end
            crc32 r10d, byte [rsi + rcx]
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

    mov rdi, 1
    lea rsi, [hexprefix__rawstring.start]
    mov rdx, hexprefix__rawstring.end - hexprefix__rawstring.start
    mov rax, rdi
    syscall

    mov eax, r10d
    call writelinex32

    jmp .quit
    .fsobjisdir:
        mov rax, 1
        mov rdi, rax
        lea rsi, [fsobjisdir__rawstring.start]
        mov rdx, fsobjisdir__rawstring.end - fsobjisdir__rawstring.start
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

; EAX - value.
; RDI - descriptor.
writelinex32:
    push rax
    push rsi
    push rcx
    push rdx
    push r11
    push bx
    dec rsp
    
    mov rdx, 1
    mov rsi, rsp
    xor bl, bl
    .loop__start:
    cmp bl, 8
    jae .loop__end
    
        push rax
            shr eax, 28
    
            cmp al, 10
            jb .usedigits
                add al, 7
            .usedigits:
            add al, 30h
    
            mov byte [rsi], al
            mov rax, rdx
            syscall
        pop rax

    shl eax, 4
    inc bl
    jmp .loop__start
    .loop__end:

    mov byte [rsp], 10
    mov rax, rdx
    syscall

    inc rsp
    pop bx
    pop r11
    pop rdx
    pop rcx
    pop rsi
    pop rax

    ret
