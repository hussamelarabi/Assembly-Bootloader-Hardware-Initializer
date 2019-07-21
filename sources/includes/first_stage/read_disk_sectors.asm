 ;************************************** read_disk_sectors.asm **************************************
      read_disk_sectors: ; This function will read a number of 512-sectors stored in DI 
                         ; The sectors should be loaded at the address starting at [disk_read_segment:disk_read_offset]
            pusha                         ; Save all general purpose registers on the stack

                  ; This function need to be written by you.

                  add di,[lba_sector]                 ;set destination index to value stored in memory pointed to by lba_sector (last sector)
                  mov ax,[disk_read_segment]          ;move value pointed to by disk_read_segment to ax
                  mov es,ax                           ;set ES to value of AX (cannot load value to ES from memory directly)
                  add bx,[disk_read_offset]           ;set bx to value pointed to by disk_read_offset
                  mov dl,[boot_drive]                 ;set dl to value pointed to by boot_drive
                  .read_sector_loop:
                  call lba_2_chs                      ;call to lba_2_chs function
                  mov ah, 0x2                         ;set AH to 2 hexa (with int 13 will read sectors)
                  mov al,0x1                          ;set AL to 1 hexa (number of sectors to read)
                  mov cx,[Cylinder]                   ;move value stored in Cylinder to cx      
                  shl cx,0xA                          ;shift cx 10 bits to the left (A hexa = 10 decimal)
                  or cx,[Sector]                      ;store sector value in first 6 bits of cx
                  mov dh,[Head]                       ;store in dh the value stored in head
                  int 0x13                            ;bios interrupt 13 (with AH = 2) will read sectors (quantity to read stored in AL)
                  jc .read_disk_error                 ;jump to read_disk_error if carry flag is set
                  mov si,dot                          ;set the source index to dot location
                  call bios_print                     ;call bios print function
                  inc word [lba_sector]               ;increment lba_sector to point to the next sector
                  add bx,0x200                        ;move to the next memory location
                  cmp word[lba_sector],di             ;check if value in lba_sector is less, greater or equal to di and sets the zero flag or sign flag accordingly
                  jl .read_sector_loop                ;jump to read_sector_loop if sign flag is set (from the previous cmp instruction)
                  jmp .finish                         ;jump to finish label
                  .read_disk_error:
                  mov si,disk_error_msg               ;set source index to beginning of disk_error_msg
                  call bios_print                     ;call bios_print function
                  jmp hang                            ;jump to hang loop
                  .finish:
            popa                    ; Restore all general purpose registers from the stack
            ret
