 ;************************************** lba_2_chs.asm **************************************
 lba_2_chs:  ; Convert the value store in [lba_sector] to its equivelant CHS values and store them in [Cylinder],[Head], and [Sector]
                  ; [Sector] = Remainder of [lba_sector]/[spt] +1
                  ; [Cylinder] = Quotient of (([lba_sector]/[spt]) / [hpc])
                  ; [Head] = Remainder of (([lba_sector]/[spt]) / [hpc])
            pusha                               ; Save all general purpose registers on the stack

                  ; This function need to be written by you.
                  xor dx,dx                     ;set dx to zero
                  mov ax, [lba_sector]          ;load value stored in memory pointed to lba_sector to register ax
                  div word [spt]                ;divide value in AX by word value stored in [spt] and store the quotient in AX and remainder in DX
                  inc dx                        ;increment dx by 1
                  mov [Sector], dx              ;store sector value calculated in dx to memory pointed to by Sector
                  xor dx,dx                     ;clear dx by setting it to zero
                  div word [hpc]                ;divide AX by word value stored in hpc and store the quotient in AX and remainder in DX
                  mov [Cylinder], ax            ;move the quotient in AX to memory pointed to by Cylinder
                  mov [Head], dl                ;store remainder value in dl in memory pointed to by Head
            popa                                ; Restore all general purpose registers from the stack
            ret