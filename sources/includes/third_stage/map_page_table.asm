%define PAGE_PRESENT_WRITE 0x3  ;011b
%define PML4_ADDRESS 0x100000
%define PDP_ADDRESS  0x101000
%define PD_ADDRESS   0x102000
%define PTE_ADDRESS  0x103000
%define PTR_MEM_REGIONS_TABLE  0x21018
%define PTR_MEM_REGIONS_COUNT  0x21000




;variables
pml4_ptr dq PML4_ADDRESS
pdp_ptr dq PDP_ADDRESS
pd_ptr dq PD_ADDRESS
pte_ptr dq PTE_ADDRESS
current_ptr dq PTE_ADDRESS

;address pointers
physical_addr dq 0x0
region_count dq 0x0
max_size dq 0x0
mem_region_address dq 0x0

;counters for table entries
pml4_counter dq 0x0
pdp_counter dq 0x0
pd_counter dq 0x0
pte_counter dq 0x0

map_page_table:
    pushaq
        call .get_max_size          ;set the max size 
        mov rax, qword[pml4_ptr]    ;set rax to current pml4 pointer
        mov rbx, qword[pdp_ptr]     ;set rbx to current pdp_ptr value
        or rbx, PAGE_PRESENT_WRITE  ;set the present and read/write bits to 1
        mov [rax], rbx              ;store the pdp address to the pml4 entry location
        add qword[pml4_counter], 0x1    ;increment pml4 counter by 1
        
        mov rax, qword[pdp_ptr]     ;set rax to current pdp pointer
        mov rbx, qword[pd_ptr]      ;set rbx to current pd_ptr value
        or rbx, PAGE_PRESENT_WRITE  ;set the present and read/write bits to 1
        mov [rax], rbx              ;store the pd address to the pdp entry location
        add qword[pdp_counter], 0x1 ;increment pdp counter by 1

        mov rax, qword[pd_ptr]      ;set rax to current pd pointer
        mov rbx, qword[pte_ptr]     ;set rbx to current pte_ptr value
        or rbx, PAGE_PRESENT_WRITE  ;set the present and read/write bits to 1
        mov [rax], rbx              ;store the pte address to the pd entry location
        add qword[pd_counter], 0x1  ;increment pd counter by 1
        jmp .pte_loop               ;jmp to pte loop
        
        .pml4_loop:
            add qword[current_ptr], 0x1000 ;shift current pointer by 1000 hexa to point to the next empty region where the new table will be created
            mov qword[pdp_counter], 0x0     ;reset the counter to the bottom layer to zero
            mov rax, qword[current_ptr]     ;store the address of the empty layer to rax
            mov qword[pdp_ptr], rax         ;update the pdp_ptr value
            or rax, PAGE_PRESENT_WRITE      ;set the pdp_ptr value's present and r/w bits to 1
            add qword[pml4_ptr], 0x8        ;point to the next entry in the pml4
            mov rbx, qword[pml4_ptr]        ;store the address of that entry
            mov[rbx], rax                   ;save the address of the new pdp table in location of pml4 entry in rbx
            add qword[pml4_counter], 0x1    ;increment pml4 counter by 1
            
            .pdp_loop:
                add qword[current_ptr], 0x1000 ;shift current pointer by 1000 hexa to point to the next empty region where the new table will be created
                mov qword[pd_counter], 0x0  ;reset the counter to the bottom layer to zero
                mov rax, qword[current_ptr] ;store the address of the empty layer to rax
                mov qword[pd_ptr], rax      ;update the pd_ptr value
                or rax, PAGE_PRESENT_WRITE  ;set the pd_ptr value's present and r/w bits to 1
                add qword[pdp_ptr], 0x8     ;point to the next entry in the pdp
                mov rbx, qword[pdp_ptr]     ;store the address of that entry
                mov[rbx], rax               ;save the address of the new pd table in location of pdp entry in rbx
                add qword[pdp_counter], 0x1 ;increment pdp counter by 1
                
                .pd_loop: 
                    call .unlock_memory             ;unlock memory mapped after completing a full pte table
                    add qword[current_ptr], 0x1000  ;shift current pointer by 1000 hexa to point to the next empty region where the new table will be created
                    mov qword[pte_counter], 0x0     ;reset the counter to the bottom layer to zero
                    mov rax, qword[current_ptr]     ;store the address of the empty layer to rax
                    mov qword[pte_ptr], rax         ;update the pte_ptr value
                    or rax, PAGE_PRESENT_WRITE      ;set the pte_ptr value's present and r/w bits to 1
                    add qword[pd_ptr], 0x8          ;point to the next entry in the pd
                    mov rbx, qword[pd_ptr]          ;store the address of that entry
                    mov[rbx], rax                   ;save the address of the new pte table in location of pd entry in rbx
                    add qword[pd_counter], 0x1      ;increment pdp counter by 1
                    .pte_loop:
                            xor rax, rax    ;set rax to zero
                            mov rax, qword[physical_addr]   ;store current physical address to map to rax
                            cmp rax, qword[max_size]        ;compare to max size and jumpt to exit label if equal
                            je .finish_mapping
                            cmp qword[physical_addr], 0xFFFFF ;check if address is in 1MB region and ignore check region type if true
                            jle .ignore
                            jmp .check_address_type ;check the type of the address
                            .ignore:
                            .store:
                            xor rax, rax        ;set rax and rbx to zero
                            xor rbx, rbx
                            mov rax, qword[pte_ptr]         ;put current pte_ptr in rax
                            mov rbx, qword[physical_addr]   ;put physical address to be mapped in rbx
                            or rbx, PAGE_PRESENT_WRITE      ;set the present and r/w bits to 1
                            mov [rax], rbx                  ;store in pte entry
                            add qword[physical_addr], 0x1000   ;increment the physicall address by 1000 hexa = 4096 bytes
                            add qword[pte_ptr], 0x8             ;point to next pte entry
                            add qword[pte_counter], 0x1         ;increment pte counter
                            cmp qword[pte_counter], 0x200   ;check if table is full
                            jl .pte_loop
                            
                            cmp qword[pml4_counter], 0x4 ;check if page table is completely full
                            je .finish_mapping

                            cmp qword[pdp_counter], 0x200   ;check if pdp layer is full and jump to label to create a new entry in pml4 if true
                            je .pml4_loop
                            
                            cmp qword[pd_counter], 0x200    ;check if pd layer is full and jump to label to create a new entry in pdp if true
                            je .pdp_loop
                                            
                            jmp .pd_loop    ;jmp to pd loop to create a new pd entry for a new pte table

 
.finish_mapping:

   call .unlock_memory ;unlock mapped memory
    popaq
    ret

.unlock_memory:
    pushaq
    ;move location of pml4 table to cr3 to parse the page table and unlock newly mapped memory
        xor rdx, rdx
        mov rdx, qword[pml4_ptr]
        mov cr3, rdx  
    popaq
    ret


.check_address_type:

mov r8, PTR_MEM_REGIONS_TABLE ;set r8 to contain address of mem regions table
.check_address_type_loop:
mov rax, qword[r8]      ;get initial address of region
mov rbx, qword[r8+8]    ;get size of the region
add rbx, rax            ;add them together to get the ending address of the region
cmp  rax,qword[physical_addr]   ;check if the physical address is less than the max of that region and if true then its in that region 
                                ;and we jump to the check the type in that region
jle .check_region
add r8, 0x18                ;else add to the pointer to the table 24 bytes to point to the next entry in the table and loop on it again
jmp .check_address_type_loop    

.check_region:
xor ecx, ecx            ;get the type and return to store label if it is type 1
mov ecx, dword[r8+16]
cmp ecx, 0x1
je .region_1_found

                                ;else increment the physical address and check its type again
.region_1_not_found:
add qword[physical_addr], 0x1000
jmp .check_address_type
.region_1_found:        ;if region type is 1 we jump to store label to store physical address in page table
jmp .store


.get_max_size:
pushaq
    mov rax, qword[PTR_MEM_REGIONS_COUNT]   ;get the address where the number of entries is stored
    mov qword[region_count], rax            ;get the value pointed to by that address
    sub rax, 0x1                            ;subtract the number of regions by 1 to know how many lines we should jump over
    mov rbx, 24                             ;multiply the number of lines to jump over by 24 bytes to get number of bytes to skip
    mul rbx
    add rax, PTR_MEM_REGIONS_TABLE          ;add the number of bytes to skip to the starting address of the table

    mov r8, qword[rax]              ;store the address of the final region in r8
    add rax, 0x8                    ;point rax to the next entry (size)
    add r8, qword[rax]              ;add to start address of final region the size of that region

    mov qword[max_size], r8         ;store the max size found in memory
popaq
ret