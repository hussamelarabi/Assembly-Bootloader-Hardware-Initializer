;*******************************************************************************************************************
%define CONFIG_ADDRESS  0xcf8
%define CONFIG_DATA     0xcfc

ata_device_msg db 'Found ATA Controller',13,10,0
pci_header times 512 db 0



struc PCI_CONF_SPACE 
.vendor_id          resw    1
.device_id          resw    1
.command            resw    1
.status             resw    1
.rev                resb    1
.prog_if            resb    1
.subclass           resb    1
.class              resb    1
.cache_line_size    resb    1
.latency            resb    1
.header_type        resb    1
.bist               resb    1
.bar0               resd    1
.bar1               resd    1
.bar2               resd    1
.bar3               resd    1
.bar4               resd    1
.bar5               resd    1
.reserved           resd    2
.int_line           resb    1
.int_pin            resb    1
.min_grant          resb    1
.max_latency        resb    1
.data               resb    192
endstruc

get_pci_device:
    ;Compose the Config Address Register (32-bis):
    ;  Bit 23-16 : bus (so we shift left 16 bits))
    ;  Bit 15-11 : device (so we shift left 11 bits))
    ;  Bit 10-8 : function (so we shift left 8 bits))
    ;  Bit 7-2 : so we clear the last two bytes by & 0xfc
    ;  Bit 31 : Enable bit, and to set it we | 0x80000000
    ;  ((bus << 16) | (device << 11) | (function << 8) | (offset & 0xfc) | ( 0x80000000))    



    ;(eax is the register that contains function,device & bus number in addition to the enable bit)
    ; This function need to be written by you.
    xor rax,rax ;clearing out the 2 registers rax and rbx 
    xor rbx,rbx 

    mov bl,[bus] ;moving the bus number and then we need to shift 16 bits to move the bus number to its correct position in bl register
    shl bl,16
    or eax,ebx
    xor rbx,rbx

    mov bl,[device] ;device number move to bl then we need to shift 11 to the left
        

    shl bl, 11

    
    or eax,ebx
    xor rbx,rbx

    mov bl, [function] 
    
    shl bl, 8 ;moving the function number to bit number (8) in the bl register 
    
    
    or eax,ebx 
    xor rbx,rbx 

    ;enabling bit 31 
    or eax,0x80000000 
    xor rsi,rsi 

ret


deviceloop:

push rax 
or rax,rsi 

and al,0xfc ;Setting the last 2 bits to 0s

mov dx,CONFIG_ADDRESS
out dx,eax ;writing to port 




