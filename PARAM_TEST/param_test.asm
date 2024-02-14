section .text
global main
main:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
    
    mov WORD [rbp - 16], 9
    mov WORD [rbp - 14], -5
    
    call mulTss
    
    movsx eax, ax
    mov [rbp - 12], eax
    
    leave
    ret

mulTss:
    push rbp
    mov rbp, rsp
    
    xor rax, rax
    
    mov ax, [rbp + 16]
    imul ax, [rbp + 18]
    
    leave
    ret
