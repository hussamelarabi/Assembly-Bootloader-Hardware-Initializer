%define CODE_SEG     0x0008         ; Code segment selector in GDT
%define DATA_SEG     0x0010         ; Data segment selector in GDT


switch_to_long_mode:
    pusha
        ; This function need to be written by you.
        
        mov eax, 10100000b
        mov cr4, eax
        mov edi, PAGE_TABLE_EFFECTIVE_ADDRESS
        mov edx, edi
        mov cr3, edx
        mov ecx, 0xC0000080
        rdmsr
        
        or eax,  0x00000100
        wrmsr
        mov ebx,cr0
        or ebx,  0x80000001
        mov cr0, ebx

        lgdt [GDT64.Pointer]
        jmp CODE_SEG:LongModeEntry 

    popa
    ret