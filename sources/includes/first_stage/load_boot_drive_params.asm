;************************************** load_boot_drive_params.asm **************************************
      load_boot_drive_params: ; A subroutine to read the [boot_drive] parameters and update [hpc] and [spt]
            pusha                                     ; Save all general purpose registers on the stack

                        ; This function need to be written by you.
                  xor di,di            ; INT 0x13 Fn 0x8 mandates that es:di should be 0x0000:0x0000
                                    ; to overcome some buggy BIOSes
                  mov es,di
                  mov ah,0x8               ; Int 0x13 function 0x8 that fetches a disk parameters
                  mov dl,[boot_drive]      ; Set the disk number we want to fetch its parameters
                  int 0x13                 ; Issue BIOS interrupt 0x13
                  inc dh                   ; DH contains the last head base-zero,
                                          ; We increment its value by 1 to get the number of head/cylinder
                  mov word [hpc],0x0       ; Clear out [hpc]
                  mov [hpc+1],dh           ; Store dh into the lower byte of the of [hpc].
                                          ; We are defining [hpc] as a word to ease calculating the CHS from LBS
                  and cx,0000000000111111b ; Extract the 6 right most bits of CX that has the sectors/track
                  mov word [spt],cx        ; Store the Sector value into [spt]. We do not need to increment it as it is base 1


            popa                                      ; Restore all general purpose registers from the stack
            ret                                       
