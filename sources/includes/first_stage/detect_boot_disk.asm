;************************************** detect_boot_disk.asm **************************************      
      detect_boot_disk: ; A subroutine to detect the the storage device number of the device we have booted from
                        ; After the execution the memory variable [boot_drive] should contain the device number
                        ; Upon booting the bios stores the boot device number into DL
            pusha                                     ; Save all general purpose registers on the stack


                  ; This function need to be written by you.
                  mov si,fault_msg              ;sets source index to fault_msg
                  xor ax,ax                     ;xor ax with itself (always zero) (setting AX to zero sets AH to zero since AH is a sub register of the bigger AX)
                  int 13h                       ;execute bios interrupt 13 (specific function is decided based on the value in AH which is zero here, i.e. reset disk)
                  jc .exit_with_error           ;checks the carry flag if it is set then prev interupt encountered an error and didnt execute correctly
                  mov si,booted_from_msg        ;sets source index to booted_from_msg
                  call bios_print               ;call to label bios_print in bios_print.asm
                  mov [boot_drive], dl          ;store the boot drive value in dl into memory pointed to by boot_drive
                  cmp dl,0                      ;compare value in dl with zero and if true, sets the zero flag
                  je .floppy                    ;jump to label if zero flag is set
                  call load_boot_drive_params   ;call to function load_boot_drive_params
                  mov si,drive_boot_msg         ;sets source index to drive_boot_msg
                  jmp .finish                   ;jump to finish label
                  .floppy:
                  mov si,floppy_boot_msg        ;set source index to floppy_boot_msg
                  jmp .finish                   ;jump to .finish label
                  .exit_with_error:
                  call bios_print               ;call print function to print error message before jumping to hang loop
                  jmp hang                      ;jump to hang loop
                  .finish:
                  call bios_print               ;call to print function
            popa                                ; Restore all general purpose registers from the stack
            ret