check_a20_gate:
    pusha                                   ; Save all general purpose registers on the stack

            ; This function need to be written by you.
        .check_gate:
            mov ax,0x2402                           ;load 0x2402 to ax (function number to check a20 gate when int 0x15 is issued)
            int 0x15                                ;issue bios interrupt
            jc .error                               ;jump to label if carry flag is set
            cmp al,0x0                              ;compare register to 0x0 and set corresponding flags
            je .enable_a20                          ;jump to label if zero flag is set
            mov si,a20_enabled_msg                  ;move string address to si
            call bios_print                         ;calll function bios_print
            jmp .enabled                            ;unconditional jump to label
            
        .enable_a20:
            mov ax,0x2401                           ;load 0x2401 to ax (function number to enable a20 gate when int 0x15 is issued)
            int 0x15                                ;issue bios interrupt
            jc .error                               ;jump to label if carry flag is set
            jmp .check_gate                         ;unconditional jump to label
            
        .error:
            cmp ah, 0x1                             ;compare register to 0x1
            je .error_controller                    ;jump to label if zero flag is set (register is equal to value)
            jmp .error_not_supported                ;unconditional jump to label
        .error_controller:
            mov si, keyboard_controller_error_msg   ;move string address to si
            call bios_print                         ;call function bios_print
            jmp hang                                ;jump to hang label
        .error_not_supported:
            mov si, a20_function_not_supported_msg  ;move string address to si
            call bios_print                         ;call function bios_print
            jmp hang                                ;jump to hang label
        .enabled:
    popa                                ; Restore all general purpose registers from the stack
    ret                                 ;return to function caller