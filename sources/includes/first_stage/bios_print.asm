;************************************** bios_print.asm **************************************      
      bios_print:       ; A subroutine to print a string on the screen using the bios int 0x10.
                        ; Expects si to have the address of the string to be printed.
                        ; Will loop on the string characters, printing one by one. 
                        ; Will Stop when encountering character 0.
            pusha                   ; Save all general purpose registers on the stack
            .print_loop:            ; Loop local label
                  xor ax,ax         ; Initialize ax to zero
                  lodsb             ; Load byte/char pointed to by si to al and increment si
                  or al, al         ; Check of al contains the value zero; if yes the zero flag will be set.
                  jz .done          ; Check the zero flag and jump to the label "done" if set
                                    ; Else print the character in al
                  mov ah, 0x0E      ; INT 0x10 print character function
                  int 0x10          ; Print character loaded in al. al is already loaded with the character
                  jmp .print_loop   ; Loop to process next character
                  .done:            ; Loop exit label
                        popa        ; Restore all general purpose registers from the stack
                        ret        
