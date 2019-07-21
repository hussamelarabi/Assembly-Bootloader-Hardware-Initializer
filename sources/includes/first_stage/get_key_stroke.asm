;************************************** get_key_stroke.asm **************************************      
        get_key_stroke: ; A routine to print a confirmation message and wait for key press to jump to second boot stage
            pusha                               ; Save all general purpose registers on the stack
                mov ah,0x0        
                int 0x16                        ;interrupt 16 with value 0 in AH is the bios interrupt is
                                                ;the read key press the processor waits for the user to press a key
                                                ;and the value of the key pressed is stored in AH
            popa                                ; Restore all general purpose registers from the stack
            ret 