;*******************************************************************************************************************
%macro pushaq 0
   ;Save registers to the stack.
   ;--------------------------------
    push rax      ;save current rax
    push rbx      ;save current rbx
    push rcx      ;save current rcx
    push rdx      ;save current rdx
    push rbp      ;save current rbp
    push rsi      ;save current rsi
    push rdi      ;save current rdi
    push r8       ;save current r8
    push r9       ;save current r9
    push r10      ;save current r10
    push r11      ;save current r11
    push r12      ;save current r12
    push r13      ;save current r13
    push r14      ;save current r14
    push r15      ;save current r15
;    pushf
%endmacro

%macro popaq 0
   ;Restore registers from the stack.
   ;--------------------------------
 ;   popf            ;restore flags
    pop r15         ;restore current r15
    pop r14         ;restore current r14
    pop r13         ;restore current r13
    pop r12         ;restore current r12
    pop r11         ;restore current r11
    pop r10         ;restore current r10
    pop r9          ;restore current r9
    pop r8          ;restore current r8
    pop rdi         ;restore current rdi
    pop rsi         ;restore current rsi
    pop rbp         ;restore current rbp
    pop rdx         ;restore current rdx
    pop rcx         ;restore current rcx
    pop rbx         ;restore current rbx
    pop rax         ;restore current rax
%endmacro
