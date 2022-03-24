         ;代码清单11-1
         ;文件名：c11_mbr.asm
         ;文件说明：硬盘主引导扇区代码 
         ;创建日期：2011-5-16 19:54

         ;设置堆栈段和栈指针,使得栈的逻辑段和代码段相同，并且初始化栈从0x7c00向下生长
         mov ax,cs      					;CS=0X0000,SS=0X0000
         mov ss,ax
         mov sp,0x7c00
      
         ;计算GDT所在的逻辑段地址,因为主引导程序的加载地址为0x0000:0x7c00,所以要加上偏移量0x7c00 
         mov ax,[cs:gdt_base+0x7c00]        ;低16位 
         mov dx,[cs:gdt_base+0x7c00+0x02]   ;高16位 
         mov bx,16        
         div bx            					;DX:AX / 16 = 商是逻辑段地址，余数是偏移地址
         mov ds,ax                          ;令DS指向该段以进行操作，令DS指向GDT所在的段
         mov bx,dx                          ;段内起始偏移地址 
      
         ;创建0#描述符，它是空描述符，这是处理器的要求
         mov dword [bx+0x00],0x00
         mov dword [bx+0x04],0x00  

         ;创建#1描述符，保护模式下的代码段描述符
         mov dword [bx+0x08],0x7c0001ff     
         mov dword [bx+0x0c],0x00409800     

         ;创建#2描述符，保护模式下的数据段描述符（文本模式下的显示缓冲区） 
         mov dword [bx+0x10],0x8000ffff     
         mov dword [bx+0x14],0x0040920b     

         ;创建#3描述符，保护模式下的堆栈段描述符
         mov dword [bx+0x18],0x00007a00
         mov dword [bx+0x1c],0x00409600

         ;初始化描述符表寄存器GDTR
         mov word [cs: gdt_size+0x7c00],31  ;描述符表的界限（总字节数减一）   
                                             
         lgdt [cs: gdt_size+0x7c00]			;低2字节是描述符表的界限，高4字节是描述符表的起始地址
      
         in al,0x92                         ;南桥芯片内的端口 
         or al,0000_0010B					
         out 0x92,al                        ;打开A20

         cli                                ;保护模式下中断机制尚未建立，应 
                                            ;禁止中断。另外保护模式下BIOS的中断都无法使用，因为其是实模式下的代码。
         mov eax,cr0
         or eax,1
         mov cr0,eax                        ;设置PE位（Protection Enable，保护模式允许位，PE=1将进入保护模式）
      
         ;以下进入保护模式... ...			;使用jmp远转移指令跳转到其下一条语句：1）清空流水线并串行化执行 2）重新加载段选择器CS，并刷新描述符高速缓存器中的内容
         jmp dword 0x0008:flush             ;16位的描述符选择子：32位偏移
                                            ;清流水线并串行化处理器 
         [bits 32] 							;使处理器按照32bits操作数进行译码

    flush:
         mov cx,00000000000_10_000B         ;加载数据段选择子(0x10)，请求特权级别为（00）
         mov ds,cx

         ;以下在屏幕上显示"Protect mode OK." 
         mov byte [0x00],'P'  				;默认使用数据段DS
         mov byte [0x02],'r'
         mov byte [0x04],'o'
         mov byte [0x06],'t'
         mov byte [0x08],'e'
         mov byte [0x0a],'c'
         mov byte [0x0c],'t'
         mov byte [0x0e],' '
         mov byte [0x10],'m'
         mov byte [0x12],'o'
         mov byte [0x14],'d'
         mov byte [0x16],'e'
         mov byte [0x18],' '
         mov byte [0x1a],'O'
         mov byte [0x1c],'K'

         ;以下用简单的示例来帮助阐述32位保护模式下的堆栈操作 
         mov cx,00000000000_11_000B         ;加载堆栈段选择子，索引为3，TI=0,RPL=00
         mov ss,cx
         mov esp,0x7c00

         mov ebp,esp                        ;保存堆栈指针 
         push byte '.'                      ;压入立即数（字节），处理器处理时实际压入的一个立即数是32位的
         
         sub ebp,4
         cmp ebp,esp                        ;判断压入立即数时，ESP是否减4 
         jnz ghalt                          
         pop eax
         mov [0x1e],al                      ;显示句点 
      
  ghalt:     
         hlt                                ;已经禁止中断，将不会被唤醒 

;-------------------------------------------------------------------------------
     
         gdt_size         dw 0
         gdt_base         dd 0x00007e00     ;GDT的物理地址 
                             
         times 510-($-$$) db 0
                          db 0x55,0xaa