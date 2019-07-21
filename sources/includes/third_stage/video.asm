video_ram_start dq 0x0B8000
video_ram_end dq 0x0B8FA0
line_size dq 0xA0
;*******************************************************************************************************************
video_print_hexa:  ; A routine to print a 16-bit value stored in di in hexa decimal (4 hexa digits)
pushaq
mov rbx,0x0B8000          ; set BX to the start of the video RAM
;mov es,bx               ; Set ES to the start of the video RAM
    add bx,[start_location] ; Store the start location for printing in BX
    mov rcx,0x10                                ; Set loop counter for 4 iterations, one for each digit
    ;mov rbx,rdi                                 ; DI has the value to be printed and we move it to bx so we do not change it
    loop_1:                                    ; Loop on all 4 digits

    mov rdx, qword[start_location]
    cmp rdx, 0xFA0
    jg scroll_1
    return_from_scroll_1:
            mov rsi,rdi                           ; Move current bx into si
            shr rsi,0x3C                          ; Shift SI 60 bits right 
            mov al,[hexa_digits+rsi]             ; get the right hexadcimal digit from the array           
            mov byte [rbx],al     ; Else Store the charcater into current video location
            inc rbx                ; Increment current video location
            mov byte [rbx],1Eh    ; Store Blue Backgroun, Yellow font color
            inc rbx                ; Increment current video location

            shl rdi,0x4                          ; Shift bx 4 bits left so the next digits is in the right place to be processed
            dec rcx                              ; decrement loop counter
            cmp rcx,0x0                          ; compare loop counter with zero.
            jg loop_1                            ; Loop again we did not yet finish the 4 digits
    add [start_location],word 0x20
    popaq
    ret
;*******************************************************************************************************************


video_print:
    pushaq
    mov rbx,0x0B8000          ; set BX to the start of the video RAM
    ;mov es,bx               ; Set ES to the start of the video RAM
    add bx,[start_location] ; Store the start location for printing in BX
    xor rcx,rcx
    
video_print_loop:           ; Loop for a character by charcater processing
    lodsb                   ; Load character pointer to by SI into al
    
    cmp rbx, 0xB8FA0
    je scroll_2
    return_from_scroll_2:
    cmp al,13               ; Check  new line character to stop printing
    je out_video_print_loop ; If so get out
    cmp al,0                ; Check  new line character to stop printing
    je out_video_print_loop1 ; If so get out
    mov byte [rbx],al     ; Else Store the charcater into current video location
    inc rbx                ; Increment current video location
    mov byte [rbx],1Eh    ; Store Blue Background, Yellow font color
    inc rbx                ; Increment current video location
                            ; Each position on the screen is represented by 2 bytes
                            ; The first byte stores the ascii code of the character
                            ; and the second one stores the color attributes
                            ; Foreground and background colors (16 colors) stores in the
                            ; lower and higher 4-bits
    inc rcx
    inc rcx
    jmp video_print_loop    ; Loop to print next character
out_video_print_loop:
    xor rax,rax
    mov ax,[start_location] ; Store the start location for printing in AX
    mov r8,160
    xor rdx,rdx
    add ax,0xA0             ; Add a line to the value of start location (80 x 2 bytes)
    div r8
    xor rdx,rdx
    mul r8
    mov [start_location],ax
    jmp finish_video_print_loop
out_video_print_loop1:
    mov ax,[start_location] ; Store the start location for printing in AX
    add ax,cx             ; Add a line to the value of start location (80 x 2 bytes)
    mov [start_location],ax
finish_video_print_loop:
    popaq
ret



scroll_1:
    pushaq
    xor rax, rax
    xor rbx, rbx
    mov rax, qword[video_ram_start]
    add rax, qword[line_size]
    mov rbx, qword[video_ram_start]
    .scroll_loop_1:
    mov cx, word[rax]
    mov word[rax], 0x0
    mov word[rbx], cx
    add rax, 0x2
    add rbx, 0x2
    cmp rax, qword[video_ram_end]
    jl .scroll_loop_1
.end_of_scroll_1:
    mov qword[start_location], 0xE60
    popaq
    jmp return_from_scroll_1


scroll_2:
    pushaq
    xor rax, rax
    xor rbx, rbx
    mov rax, qword[video_ram_start]
    add rax, qword[line_size]
    mov rbx, qword[video_ram_start]
    .scroll_loop_2:
    mov cx, word[rax]
    mov word[rax], 0x0
    mov word[rbx], cx
    add rax, 0x2
    add rbx, 0x2
    cmp rax, qword[video_ram_end]
    jl .scroll_loop_2
.end_of_scroll_2:
    mov qword[start_location], 0xDC0
    popaq
    jmp return_from_scroll_2

clear_video_buffer:
    pushaq
    mov rbx,[video_ram_start]
    
    .clear_video_buffer_loop:
        cmp rbx, qword[video_ram_end]
        jg .end_of_clear_buffer
        mov word[rbx], 0x0
        inc rbx
        inc rbx
        jmp .clear_video_buffer_loop

    .end_of_clear_buffer:
        mov qword[start_location], 0xA0
        popaq
        ret