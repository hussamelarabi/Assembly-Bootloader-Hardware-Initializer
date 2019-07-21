;************************************** bios_cls.asm **************************************      
      bios_cls:   ; A routine to initialize video mode 80x25 which also clears the screen
            pusha       ; Save all general purpose registers on the stack      
            mov ah,0x0  ; Set Video Mode Function
            mov al,0x3  ; 80x25 16 color text mode
            int 0x10    ; Issue INT 0x10
            popa        ; Restore all general purpose registers from the stack
            ret
