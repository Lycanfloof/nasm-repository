section .text
global main
main:
    push rbp
    mov rbp, rsp
    sub rsp, 8
    
    mov rbx, 3030303030303030h
    mov rcx, 3030303030303030h
    call BCD_SUM
    mov [rbp - 8], rax
    
    lea rsi, [rbp - 8]
    mov rdx, 8
    call WRITE
    
    leave
    ret

BCD_SUM:
    push rbp
    mov rbp, rsp
    sub rsp, 16
    
    mov [rbp - 16], rbx
    mov [rbp - 8], rcx
    
    mov rbx, rbp
    mov rcx, rbp
    sub rcx, 8
    
    xor rax, rax
    xor rdx, rdx
    
    THIS_LOOP:
        mov al, [rbx - 9]
        add al, [rbx - 1]
        add al, ah
        xor ah, ah
        sub al, 60h
        
        mov dl, al
        sub dl, 0Ah
        js NO_CARRY
        
        mov al, dl
        mov ah, 1
        
        NO_CARRY:
        add al, 30h
        mov [rbx - 9], al
        
        dec rbx
        cmp rbx, rcx
        jg THIS_LOOP
    
    mov rax, [rbp - 16]
    
    leave
    ret

; This procedure reads the system's standard input and writes it into a String.
; It requires:
; - A String pointer in the register RSI.
; - The String's length in the register RDX.
READ:
    mov rax, 0
    mov rdi, 0
    syscall
    
    ret

; This procedure prints a String in the the system's standard output.
; It requires:
; - A String pointer in the register RSI.
; - The String's length in the register RDX.
WRITE:
    mov rax, 1
    mov rdi, 1
    syscall
    
    ret
