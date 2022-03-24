         ;代码清单8-2
         ;文件名：c08.asm
         ;文件说明：用户程序 
         ;创建日期：2011-5-5 18:17
         
;===============================================================================
SECTION header vstart=0                     ;定义用户程序头部段 
    program_length  dd program_end          ;程序总长度[0x00],dd用来声明和初始化一个双字（32bits）
    
    ;用户程序入口点
    code_entry      dw start                ;偏移地址[0x04]
                    dd section.code_1.start ;段地址[0x06] 
    
    realloc_tbl_len dw (header_end-code_1_segment)/4
                                            ;段重定位表项个数[0x0a]
    
    ;段重定位表（32位，重定位前只有高20位有效，重定位后只有低16位有效代表段基地址）           
    code_1_segment  dd section.code_1.start ;[0x0c]
    code_2_segment  dd section.code_2.start ;[0x10]
    data_1_segment  dd section.data_1.start ;[0x14]
    data_2_segment  dd section.data_2.start ;[0x18]
    stack_segment   dd section.stack.start  ;[0x1c]
    
    header_end:                
    
;===============================================================================
SECTION code_1 align=16 vstart=0         ;定义代码段1（16字节对齐） 
put_string:                              ;显示串(0结尾)。
                                         ;输入：DS:BX=串地址
         mov cl,[bx]
         or cl,cl                        ;cl=0 ?串以0结尾，cl=cl | cl 结果是其本身，但是执行结果会影响ZF标志位
         jz .exit                        ;是的，返回主程序 
         call put_char
         inc bx                          ;下一个字符 
         jmp put_string

   .exit:
         ret

;-------------------------------------------------------------------------------
put_char:                                ;显示一个字符
                                         ;输入：cl=字符ascii
         push ax
         push bx
         push cx
         push dx
         push ds
         push es

         ;以下取当前光标位置，向0x3d4端口写入0x0e,然后读取该端口得到高8位的光标
         mov dx,0x3d4
         mov al,0x0e
         out dx,al
         mov dx,0x3d5
         in al,dx                        ;高8位 
         mov ah,al

         mov dx,0x3d4		;向0x3d4端口写入0x0f,然后读取该端口得到低8位的光标
         mov al,0x0f
         out dx,al
         mov dx,0x3d5
         in al,dx                        ;低8位 
         mov bx,ax                       ;BX=代表光标位置的16位数

         cmp cl,0x0d                     ;回车符？
         jnz .put_0a                     ;不是。看看是不是换行等字符 
         mov ax,bx                       ;ax/80 * 80 得到当前行的行首，并将之保存到BX寄存器中去 
         mov bl,80                       
         div bl
         mul bl
         mov bx,ax
         jmp .set_cursor

 .put_0a:
         cmp cl,0x0a                     ;换行符？
         jnz .put_other                  ;不是，那就正常显示字符 
         add bx,80						 ;是换行符，则光标位置向后移动80（一行80个字符）
         jmp .roll_screen

 .put_other:                             ;正常显示字符
         mov ax,0xb800					 ;显存对应的段地址
         mov es,ax
         shl bx,1						 ;光标的位置*2得到字符的偏移，以为字符对应两个字节，光标的偏移和字符的偏移有个2倍关系
         mov [es:bx],cl

         ;以下将光标位置推进一个字符
         shr bx,1						 ;恢复原来光标的位置（除以2），并向下移动一个位置
         add bx,1

 .roll_screen:							 ;一个屏幕共可以显示2000个字符
         cmp bx,2000                     ;光标超出屏幕？滚屏
         jl .set_cursor

         mov ax,0xb800					 ;进行滚屏操作，将屏幕2-25行整体上移，最后一行填充黑底白字的空白字符
         mov ds,ax						 ;设置显存的段基址
         mov es,ax
         cld							 ;方向位等于0，正向移动
         mov si,0xa0					 ;第二行第一列(160,因为每个字符占用两个字节) 源地址为 DS:SI
         mov di,0x00					 ;第一行第一列 目的地址为 ES:DI
         mov cx,1920					 ;重复执行1920次
         rep movsw
         mov bx,3840                     ;清除屏幕最底一行，3840为最后一行的起始偏移
         mov cx,80						 ;重复次数为80
 .cls:
         mov word[es:bx],0x0720			 ;黑底白字，空白字符
         add bx,2
         loop .cls

         mov bx,1920					 ;恢复光标位置
 ;光标的位置保存在BX中
 .set_cursor:
         mov dx,0x3d4		;向0x3d4端口写入0x0e,然后向0x3d5端口写入高8位的光标位置值
         mov al,0x0e
         out dx,al
         mov dx,0x3d5
         mov al,bh
         out dx,al
         mov dx,0x3d4		;向0x3d4端口写入0x0f,然后向0x3d5端口写入低8位的光标位置值
         mov al,0x0f
         out dx,al
         mov dx,0x3d5
         mov al,bl
         out dx,al

         pop es
         pop ds
         pop dx
         pop cx
         pop bx
         pop ax

         ret

;-------------------------------------------------------------------------------
  start:
         ;初始执行时，DS和ES指向用户程序头部段
         mov ax,[stack_segment]           ;设置到用户程序自己的堆栈 
         mov ss,ax
         mov sp,stack_end				  ;相当于：mov sp,256,该栈的大小为256个字节
         
         mov ax,[data_1_segment]          ;设置到用户程序自己的数据段
         mov ds,ax

         mov bx,msg0
         call put_string                  ;显示第一段信息 

         push word [es:code_2_segment]	  ;先压入代码段2的段地址，再压入代码段2的偏移地址
         mov ax,begin
         push ax                          ;可以直接push begin,80386+
         
         retf                             ;转移到代码段2执行，把刚才入栈的代码段2的偏移地址和段地址弹出到了eip,cs，于是处理器跳转到代码段2处开始执行
         
  continue:
         mov ax,[es:data_2_segment]       ;段寄存器DS切换到数据段2 
         mov ds,ax
         
         mov bx,msg1
         call put_string                  ;显示第二段信息 

         jmp $ 

;===============================================================================
SECTION code_2 align=16 vstart=0          ;定义代码段2（16字节对齐）

  begin:
         push word [es:code_1_segment]
         mov ax,continue
         push ax                          ;可以直接push continue,80386+
         
         retf                             ;转移到代码段1接着执行 
         
;===============================================================================
SECTION data_1 align=16 vstart=0
	;msg0的标号为0
    msg0 db '  This is NASM - the famous Netwide Assembler. '
         db 'Back at SourceForge and in intensive development! '
         db 'Get the current versions from http://www.nasm.us/.'
         db 0x0d,0x0a,0x0d,0x0a				;回车(0X0D)和换行符号(0X0A)
         db '  Example code for calculate 1+2+...+1000:',0x0d,0x0a,0x0d,0x0a
         db '     xor dx,dx',0x0d,0x0a
         db '     xor ax,ax',0x0d,0x0a
         db '     xor cx,cx',0x0d,0x0a
         db '  @@:',0x0d,0x0a
         db '     inc cx',0x0d,0x0a
         db '     add ax,cx',0x0d,0x0a
         db '     adc dx,0',0x0d,0x0a
         db '     inc cx',0x0d,0x0a
         db '     cmp cx,1000',0x0d,0x0a
         db '     jle @@',0x0d,0x0a
         db '     ... ...(Some other codes)',0x0d,0x0a,0x0d,0x0a
         db 0

;===============================================================================
SECTION data_2 align=16 vstart=0

    msg1 db '  The above contents is written by LeeChung. '
         db '2011-05-06'
         db 0

;===============================================================================
SECTION stack align=16 vstart=0
           
         resb 256				;用来保留256字节的内容，resb用来声明未初始化的数据

stack_end:  					;由于vstart=0，所以该标号相当于等于256

;===============================================================================
SECTION trail align=16
program_end:			;program_end代表的标号是从整个程序开头开始算起的，用于表示整个程序的大小