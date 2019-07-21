        check_long_mode:
            pusha                           ; Save all general purpose registers on the stack
            call check_cpuid_support        ; Check if cpuid instruction is supported by the CPU
            call check_long_mode_with_cpuid ; check long mode using cpuid
            popa                            ; Restore all general purpose registers from the stack
            ret

        check_cpuid_support:
            pusha               ; Save all general purpose registers on the stack

                  ; This function need to be written by you.
                pushfd                                      ;push flags on stack, once to restore flags after subroutine ends,  
                pushfd                                      ;second one for comparison purposes later in
                pushfd                                      ;the code and third to move flags to register below
                pop eax                                     ;pop flags to register eax
                xor eax, 0x0200000                          ;xor eax with 0x0200000 to flip bit 21 of the eflags to opposite of whatever it is set to
                push eax                                    ;push flags in eax to stack
                popfd                                       ;set flags to same values but with bit 21 flipped
                pushfd                                      ;push flags on stack
                pop eax                                     ;push current flags on eax
                pop ecx                                     ;push old flags to ecx
                xor eax,ecx                                 ;set all bits to zero except bit 21 which will always give 1
                and eax,0x0200000                           

                cmp eax,0x0                                 ;compare eax to 0x0
                jne .cpuid_supported                        ;jump to label if zero flag is not set (indicating that cpuid is supported)
                mov si,cpuid_not_supported                  ;load string address to si
                call bios_print                             ;call bios_print function
                jmp hang                                    ;jump to hang label

                .cpuid_supported:
                    mov si,cpuid_supported                  ;load string address to si
                    call bios_print                         ;call function bios_print
                    popfd                                   ;restore all flags from stack
            popa                ; Restore all general purpose registers from the stack
            ret                 ;return to function caller

        check_long_mode_with_cpuid:
            pusha                                   ; Save all general purpose registers on the stack

                ; This function need to be written by you.
                    mov eax,0x80000000                      ;set eax to 0x80000000 
                    cpuid                                   ;call cpuid (with function ID in eax, returns highest calling parameter in eax)
                    cmp eax,0x80000001                      ;compare eax to value
                    jl .long_mode_not_supported             ;jump to label if eax is less than 0x80000001
                    mov eax,0x80000001                      ;set eax to 0x80000001
                    cpuid                                   ;call cpuid (with fuunction ID in eax, this stores processor extended features bits in ecx and edx)
                    and edx,0x20000000                      ;set all bits except bit 29 (LONG MODE BIT) to zero
                    cmp edx,0                               ;compare edx to zero
                    je .long_mode_not_supported             ;jump to label if zero flag is set
                    mov si,long_mode_supported_msg          ;move string address to si
                    call bios_print                         ;call bios_print function
                    jmp .exit_check_long_mode_with_cpuid    ;unconditional jump to label
                
                .long_mode_not_supported:
                    mov si,long_mode_not_supported_msg      ;move string address to si
                    call bios_print                         ;call to function bios_print
                    jmp hang                                ;jump to hang label

                .exit_check_long_mode_with_cpuid: 
            popa                                ; Restore all general purpose registers from the stack
            ret                                 ;return to function caller