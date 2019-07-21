%define PIT_DATA0       0x40
%define PIT_DATA1       0x41
%define PIT_DATA2       0x42
%define PIT_COMMAND     0x43

pit_counter dq    0x0               ; A variable for counting the PIT ticks
print_counter dq 0x0                ; variable for priting counter
handle_pit:
      pushaq
            cmp qword[print_counter], 0 ; compare the print counter to the starting posititon zero
            je .print_counter           ; for printing each 1000 intrupt
            cmp qword[print_counter], 100  ; comparing priting counter to 1000
            jl .dont_print_counter           ;got to dont print if it is less than 1000
            mov qword[print_counter], 0x0   ; put zeros in print counter
            .print_counter:
            mov rdi,[pit_counter]         ; move pit counter to rdi for printing in hexa 
            push qword [start_location]   ; 
            mov qword [start_location],0   ; put zero in the start locationput the start location on stack
            call video_print_hexa          ; Print pit_counter in hexa
            mov rsi, newline
            call video_print
            pop qword [start_location]   ; pop the start loction from the stack
            .dont_print_counter:
            inc qword[print_counter]      ; increment the print counter by 8 bytes
            inc qword [pit_counter]       ; Increment pit_counter
      popaq
      ret



configure_pit:
    pushaq
      ; This function need to be written by you
     mov rdi, 32   ;Writing to IRQ0 the first position in the master area in the PIC
     mov rsi, handle_pit ;when interrupt occurs, the handle_pit will take care of the interrupt 
     call register_idt_handler
     mov al,00110110b 
     out PIT_COMMAND, al ;writing to pit_command 
     xor rdx, rdx   ; put rdx to 0
     mov rcx, 50  ;   put 50 in rcx
     mov rax,1193180   ;  put the value of the frequency in rax
     div rcx ;   divide rax with rcx
     out PIT_DATA0,al   ;    write byte to channel 0
     mov al,ah    ;put the high byte in AL
     out PIT_DATA0, al   ;write the high byte to channel 0
    popaq
    ret