         ;代码清单9-2
         ;文件名：c09_2.asm
         ;文件说明：用于演示BIOS中断的用户程序 
         ;创建日期：2012-3-28 20:35
         
;===============================================================================
SECTION header vstart=0                     ;定义用户程序头部段 
    program_length  dd program_end          ;程序总长度[0x00]
    
    ;用户程序入口点
    code_entry      dw start                ;偏移地址[0x04]
                    dd section.code.start   ;段地址[0x06] 
    
    realloc_tbl_len dw (header_end-realloc_begin)/4
                                            ;段重定位表项个数[0x0a]
    
    realloc_begin:
    ;段重定位表           
    code_segment    dd section.code.start   ;[0x0c]
    data_segment    dd section.data.start   ;[0x14]
    stack_segment   dd section.stack.start  ;[0x1c]
    
header_end:                
    
;===============================================================================
SECTION code align=16 vstart=0           ;定义代码段（16字节对齐） 
start:
      mov ax,[stack_segment]			 ;初始化段寄存器SS,SP,DS
      mov ss,ax
      mov sp,ss_pointer
      mov ax,[data_segment]
      mov ds,ax
      
      mov cx,msg_end-message			 ;数据区字符串的长度
      mov bx,message					 ;数据区字符串的起始地址
      
 .putc:									 ;BIOS中的0x10中断，用于显示器功能调用，在int 0x10指令之前需要使用AH显示属性
      mov ah,0x0e						 ;当AH=0xe时,在光标处写字符并移动光标入口参数：AL=字符的ASCII码，BL=字符的颜色值（图形方式），BH=页号（字符方式）
      mov al,[bx]						 
      int 0x10
      inc bx							 ;下一字符的偏移地址
      loop .putc

 .reps:									 ;从键盘中读取按下的那个键，并将其显示到屏幕上
      mov ah,0x00						 ;BIOS中的0x10中断，用于键盘，设置AH=00H时表示读取键值
      int 0x16
      
      mov ah,0x0e						 ;显示器功能调用，显示出键盘的ASCII码值
      mov bl,0x07						 ;设置字符的颜色值
      int 0x10

      jmp .reps

;===============================================================================
SECTION data align=16 vstart=0

    message       db 'Hello, friend!',0x0d,0x0a
                  db 'This simple procedure used to demonstrate '
                  db 'the BIOS interrupt.',0x0d,0x0a
                  db 'Please press the keys on the keyboard ->'
    msg_end:
                   
;===============================================================================
SECTION stack align=16 vstart=0
           
                 resb 256
ss_pointer:
 
;===============================================================================
SECTION program_trail
program_end: