%define MASTER_PIC_COMMAND_PORT     0x20
%define SLAVE_PIC_COMMAND_PORT      0xA0
%define MASTER_PIC_DATA_PORT        0x21
%define SLAVE_PIC_DATA_PORT         0xA1


    configure_pic:
        pushaq
                  ; This function need to be written by you.
            mov al,11111111b                        ; mov value to al
            out MASTER_PIC_DATA_PORT, al            ; shutdown master and slave data ports by masking all bits
            out SLAVE_PIC_DATA_PORT, al             
            mov al,00010001b                        ;shutdown master and slave command ports
            out MASTER_PIC_COMMAND_PORT,al          
            out SLAVE_PIC_COMMAND_PORT,al           

            mov al,0x20                             ;
            out MASTER_PIC_DATA_PORT,al             ;
            mov al, 0x28                            ;
            out SLAVE_PIC_DATA_PORT,al              ;

            mov al,00000100b                        ;
            out MASTER_PIC_DATA_PORT, al            ;

            mov al,00000010b                        ;
            out SLAVE_PIC_DATA_PORT,al              ;

            mov al,00000001b                        ;
            out MASTER_PIC_DATA_PORT,al             ;
            out SLAVE_PIC_DATA_PORT,al              ;
            mov al,0x0                              ;
            ; Unmask all IRQs
            out MASTER_PIC_DATA_PORT,al
            out SLAVE_PIC_DATA_PORT,al
        popaq
        ret


    set_irq_mask:
        pushaq                              ;Save general purpose registers on the stack
        mov rdx,MASTER_PIC_DATA_PORT        ; Use the master data port
        cmp rdi,15                          ; If the IRQ is larger than 15 get out
        jg .out                             
        cmp rdi,8                           ; Else if the interrupt number is less than 8 then it is on the master
        jl .master
        sub rdi,8                           ; Else subtract 8 from the port number to make it relative to the slave
        mov rdx,SLAVE_PIC_DATA_PORT         ; Use the slave data port
        .master:                            ; If we are here we know which port we are going to use and the IRQ is set right
            in eax,dx                       ; Read the IMR into eax
            mov rcx,rdi                     ; Move rdi to rcx
            mov rdi,0x1                     ; Move ox1 to rdi
            shl rdi,cl                      ; Shift left the value in rdi with IRQ value
            or rax,rdi                      ; Mov back rdi to rax
            out dx,eax                      ; Write to the data port to save the IMR with the new mask
        .out:    
        popaq
        ret


    clear_irq_mask:
        pushaq
        mov rdx,MASTER_PIC_DATA_PORT
        cmp rdi,15
        jg .out
        cmp rdi,8
        jl .master
        sub rdi,8
        mov rdx,SLAVE_PIC_DATA_PORT
        .master:
            in eax,dx
            mov rcx,rdi
            mov rdi,0x1 
            shl rdi,cl
            not rdi
            or rax,rdi
            out dx,eax
        .out:    
        popaq
        ret
