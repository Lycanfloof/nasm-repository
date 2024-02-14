section .data
select_menu db 10, "Enter a plus sign (+) to add, otherwise enter a minus sign (-) to subtract.", 10, 10
select_digits db 10, "Write a TWO digit number to select the amount of digits (Example: 03). If you DON'T type the two digits EXPLICITLY, then the program WON'T WORK.", 10, 10
select_number db 10, "Write a number with the amount of digits you selected EXPLICITLY (Example: With three digits, write 013 to enter the number 13).", 10, 10
result db 10, "Result: "
slash_n db 10

; x86_64 NASM - Ariel Eduardo - A00368734
; (I used NASM because it was really hard to compile MASM on Linux).
section .text
global main
main:
    push rbp
    mov rbp, rsp
    sub rsp, 9
    
    ;
    lea rsi, [select_menu]
    mov rdx, 78
    call WRITE
    ;
    
    lea rsi, [rbp - 9]
    mov rdx, 2
    call READ
    
    ;
    lea rsi, [select_digits]
    mov rdx, 147
    call WRITE
    ;
    
    lea rsi, [rbp - 3]
    mov rdx, 3
    call READ
    
    lea rsi, [rbp - 3]
    mov rdx, 2
    call READ_NUMBER
    
    mov [rbp - 8], rax
    
    sub rsp, rax
    dec rsp
    
    ;
    lea rsi, [select_number]
    mov rdx, 131
    call WRITE
    ;
    
    lea rsi, [rsp]
    mov rdx, [rbp - 8]
    inc rdx
    call READ
    
    mov rax, [rbp - 8]
    sub rsp, rax
    dec rsp
    
    ;
    lea rsi, [select_number]
    mov rdx, 131
    call WRITE
    ;
    
    lea rsi, [rsp]
    mov rdx, [rbp - 8]
    inc rdx
    call READ
    
    mov rax, [rbp - 8]
    add rax, rsp
    inc rax
    
    mov rbx, rsp
    mov rcx, rax
    mov r8, [rbp - 8]
    
    mov r10b, [rbp - 9]
    cmp r10b, 2Bh
    je .SUM
    jne .SUB
    
    .SUM:
    call BCD_SUM
    jmp .END
    
    .SUB:
    call BCD_SUB
    
    .END:
    ;
    lea rsi, [result]
    mov rdx, 9
    call WRITE
    
    mov rsi, rsp
    mov rdx, [rbp - 8]
    call WRITE
    
    lea rsi, [slash_n]
    mov rdx, 1
    call WRITE
    
    lea rsi, [slash_n]
    mov rdx, 1
    call WRITE
    ;
    
    leave
    ret

; This procedure takes two String pointers and adds them together, assuming they represent numbers in the BCD format.
; Requires:
; - A String pointer in the register RBX.
; - A String pointer in the register RCX.
; - The Strings' lengths in the register R8.
; Modifies: The String pointer contained in RBX.
BCD_SUM:
    add rbx, r8
    dec rbx
    
    add rcx, r8
    dec rcx
    
    xor rax, rax
    xor rdx, rdx
    
    .THIS_LOOP:
        mov al, [rbx]
        add al, [rcx]
        sub al, 60h
        
        add al, ah
        xor ah, ah
        
        mov dl, al
        sub dl, 0Ah
        js .NO_CARRY
        
        mov al, dl
        mov ah, 1
        
        .NO_CARRY:
        add al, 30h
        mov [rbx], al
        
        dec rbx
        dec rcx
        dec r8
        
        cmp r8, 0
        jg .THIS_LOOP
    
    ret

; This procedure takes two String pointers and subtracts them (*RBX - *RCX), assuming they represent numbers in the BCD format.
; Requires:
; - A String pointer in the register RBX.
; - A String pointer in the register RCX.
; - The Strings' lengths in the register R8.
; Modifies: The String pointer contained in RBX.
BCD_SUB:
    add rbx, r8
    dec rbx
    
    add rcx, r8
    dec rcx
    
    xor rax, rax
    xor rdx, rdx
    
    .THIS_LOOP:
        mov al, [rcx]
        
        sub al, ah
        xor ah, ah
        
        sub al, [rbx]
        jns .NO_CARRY
        
        add al, 10
        mov ah, 1
        
        .NO_CARRY:
        add al, 30h
        mov [rbx], al
        
        dec rbx
        dec rcx
        dec r8
        
        cmp r8, 0
        jg .THIS_LOOP
    
    ret

; This procedure reads a String and converts it to its corresponding numeric value. It assumes that it only contains numbers in ASCII format.
; Requires:
; - A String pointer in the register RSI.
; - The String's length in the register RDX.
; Returns: The corresponding value in the register RAX.
READ_NUMBER:
    xor r9, r9
    mov r13, 10
    
    mov rax, 0; Accumulator.
    mov r10, 0; Power.
    mov r11, 0; Counter.
    
    mov r8, rsi
    add r8, rdx
    dec r8
    
    .THIS_LOOP:
        mov r9b, byte [r8]
        sub r9b, 30h
        
        .ANOTHER_LOOP:
            cmp r11, r10
            jge .ANOTHER_LOOP_END
            
            imul r9, r13
            inc r11
            
            jmp .ANOTHER_LOOP
        .ANOTHER_LOOP_END:
        
        add rax, r9
        
        xor r9, r9
        xor r11, r11
        inc r10
        
        dec r8
        cmp r8, rsi
        jge .THIS_LOOP
    
    ret

; This procedure reads the system's standard input and writes it into a String.
; Requires:
; - A String pointer in the register RSI.
; - The String's length in the register RDX.
READ:
    mov rax, 0
    mov rdi, 0
    syscall
    
    ret

; This procedure prints a String in the the system's standard output.
; Requires:
; - A String pointer in the register RSI.
; - The String's length in the register RDX.
WRITE:
    mov rax, 1
    mov rdi, 1
    syscall
    
    ret
