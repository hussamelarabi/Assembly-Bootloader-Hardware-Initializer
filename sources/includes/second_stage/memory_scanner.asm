%define MEM_REGIONS_SEGMENT    0x2000
%define PTR_MEM_REGIONS_COUNT  0x1000
%define PTR_MEM_REGIONS_TABLE  0x1018
%define MEM_MAGIC_NUMBER       0x0534D4150
    memory_scanner:
            pusha                                       ; Save all general purpose registers on the stack

                ; This function need to be written by you.
                mov ax,MEM_REGIONS_SEGMENT                  ;load address to MEM_REGIONS_SEGMENT to ax
                mov es,ax                                   ;copy ax to es
                xor ebx,ebx                                 ;set ebx to zero
                mov [es:PTR_MEM_REGIONS_COUNT], word 0x0    ;set word pointed to by es:PTR_MEM_REGIONS_COUNT to 0 
                mov di,PTR_MEM_REGIONS_TABLE                ;move address of PTR_MEM_REGIONS_TABLE to di
            
                .memory_scanner_loop:
                    mov edx,MEM_MAGIC_NUMBER            ;load address of MEM_MAGIC_NUMBER to edx
                    mov word [es:di+20],0x1             ;set 0x1 to the word pointed to by es:di+20
                    mov eax,0xE820                      ;set eax to E820 hexa
                    mov ecx,0x18                        ;set ecx to 18 hexa
                    int 0x15                            ;start bios interrupt 15
                    jc .memory_scan_failed              ;jump to memory_scan_failed if carry flag is set
                    cmp eax,MEM_MAGIC_NUMBER            ;cmp eax to MEM_MAGIC_NUMBER
                    jnz .memory_scan_failed             ;jump to label if zero flag is not set
                    add di,0x18                         ;add 18 hexa to contents of di
                    inc word[es:PTR_MEM_REGIONS_COUNT]  ;increment word pointed to es:PTR_MEM_REGIONS_COUNT by one
                    cmp ebx,0x0                         ;compare ebx to 0x0
                    jne .memory_scanner_loop            ;jump to label if zero flag is set
                    jmp .finish_memory_scan             ;unconditional jump to finish_memory_scan
                .memory_scan_failed:                
                    mov si,memory_scan_failed_msg       ;load address of memory_scan_failed_msg to si
                    call bios_print                     ;call bios_print function
                    jmp hang                            ;jump to hang label upon failure
            .finish_memory_scan:
            popa                                       ; Restore all general purpose registers from the stack
            ret

    print_memory_regions:
            pusha
            mov ax,MEM_REGIONS_SEGMENT                  ; Set ES to 0x0000 (it is not recommended to directly set ES so we use AX as buffer)
            mov es,ax                                   
            xor edi,edi                                 ;set edi to zero
            mov di,word [es:PTR_MEM_REGIONS_COUNT]      ;set di to word pointed to by es:PTR_MEM_REGIONS_COUNT
            call bios_print_hexa                        ;call function bios_print_hexa
            mov si,newline                              ;load address of newline into si
            call bios_print                             ;call to function bios_print
            mov ecx,[es:PTR_MEM_REGIONS_COUNT]          ;set content pointed to es:PTR_MEM_REGIONS_COUNT to ecx
            mov si,0x1018                               ;set si to 1018 hexa
            .print_memory_regions_loop:
                mov edi,dword [es:si+4]                 ;move the double word pointed to by es:si+4 to edi
                call bios_print_hexa_with_prefix        ;call function bios_print_hexa_with_prefix 
                mov edi,dword [es:si]                   ;move the double word pointed to by es:si to edi
                call bios_print_hexa                    ;call function bios_print_hexa
                push si                                 ;push si on the stack
                mov si,double_space                     ;move address of string double space to si
                call bios_print                         ;call to function bios_print
                pop si                                  ;pop value of si from the stack

                mov edi,dword [es:si+12]                ;load double word stored at es:si+12 to edi
                call bios_print_hexa_with_prefix        ;call to function bios_print_hexa_with_prefix
                mov edi,dword [es:si+8]                 ;move double word stored at es:si+8 to edi
                call bios_print_hexa                    ;call to function bios_print_hexa

                push si                                 ;push si onto the stack
                mov si,double_space                     ;load address of string onto si
                call bios_print                         ;call to function bios_print
                pop si                                  ;pop value of si from the stack

                mov edi,dword [es:si+16]                ;move the double word stored at es:si+16 to edi
                call bios_print_hexa_with_prefix        ;call to function bios_print_hexa_with_prefix


                push si                                 ;push value of si onto the stack
                mov si,newline                          ;move address of string to si
                call bios_print                         ;call function bios_print
                pop si                                  ;pop value of si from stack
                add si,0x18                             ;increment value in si by 18 hexa

                dec ecx                                 ;decrement ecx by one
                cmp ecx,0x0                             ;compare ecx to zero and set the flags accordingly
                jne .print_memory_regions_loop          ;jump to local label if zero flag is not set
            popa                                        ;pop general purpose register values from stack back to their respective registers
            ret                                         ;return to caller