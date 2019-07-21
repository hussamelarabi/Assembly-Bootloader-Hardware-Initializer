;************************************** first_stage_data.asm **************************************
      boot_drive        db 0x0      ; A memory variable to store the boot drive number
      lba_sector        dw 0x1      ; A memory variable storing the next sector to read
                                    ; We store 0x1 because this sector is stored at lba 0x0 and it is already loaded by the hardware
      spt               dw 0x12     ; A memory variable storing the number of sectors/track. We initialize it to the default value of floppy
      hpc               dw 0x2      ; A memory variable storing the number of head/cylinder. We initialize it to the default value of floppy
      ; Three memory variables that we will use to store the conversion from LBA to CHS to use it with INT 0x13/fn2
      Cylinder          dw 0x0
      Head              db 0x0
      Sector            dw 0x0
      ; A number of string messages that we will use in our first stage boot loader
      disk_error_msg                db 'Disk Error', 13, 10, 0
      fault_msg                     db 'Unknown Boot Device', 13, 10, 0
      booted_from_msg               db 'Booted from ', 0
      floppy_boot_msg               db 'Floppy', 13, 10, 0
      drive_boot_msg                db 'Disk', 13, 10, 0
      greeting_msg                  db '1st Stage Loader', 13, 10, 0
      second_stage_loaded_msg       db 13,10,'2nd Stage loaded, press any key to resume!', 0
      dot                           db '.',0
      newline                       db 13,10,0
      disk_read_segment             dw 0
      disk_read_offset              dw 0

      ; Notice that we have added "13,10" as the carriage return character code "\r\n".
      ; Then we add a NULL character, "0", as an indication for the end of the string.
