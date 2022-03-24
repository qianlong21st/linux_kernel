         ;代码清单7-1
         ;文件名：c07_mbr.asm
         ;文件说明：硬盘主引导扇区代码
         ;创建日期：2011-4-13 18:02
         
         jmp near start			;跳过没有指令的数据区
	
 message db '1+2+3+...+100='
        
 start:
         mov ax,0x7c0           ;设置数据段的段基地址 
         mov ds,ax

         mov ax,0xb800          ;设置附加段基址到显示缓冲区，显卡的基地址
         mov es,ax

         ;以下显示字符串 
         mov si,message          
         mov di,0
         mov cx,start-message	;'1+2+3+...+100='的字节数
     @g:
         mov al,[si]			;取出ds:[si]中的数据
         mov [es:di],al			;将数据复制到es:[di]中去
         inc di
         mov byte [es:di],0x07
         inc di
         inc si
         loop @g				;cx不等于0时进行循环

         ;以下计算1到100的和 
         xor ax,ax				;ax清零
         mov cx,1
     @f:
         add ax,cx
         inc cx
         cmp cx,100
         jle @f					;cx<=100时进行循环

         ;以下计算累加和的每个数位 
         xor cx,cx              ;设置堆栈段的段基地址
         mov ss,cx				;CS和SS处于同一个段中段基地址为0
         mov sp,cx				;堆栈指针SP=0,由于栈是向下增长的，故第一次入栈时的位置为0X00000-2=0XFFFFE,且不会和代码段产生冲突

         mov bx,10				;BX=10,除数
         xor cx,cx				;CX=0，CX用于标记共有几位数字
     @d:
         inc cx
         xor dx,dx
         div bx					;DX:AX / BX  = 商(AX) 余数(DX)
         or dl,0x30				;转化成该数字对应的ASCII码
         push dx				;先入栈最低位的数字，最后入栈的是最高位数字
         cmp ax,0
         jne @d					;AX!=0时进行循环，也就是商不为0时才进行分解

         ;以下显示各个数位 
     @a:
         pop dx					;先出栈的是最高位的数字
         mov [es:di],dl
         inc di
         mov byte [es:di],0x07
         inc di
         loop @a				;CX!=0进行循环
       
         jmp near $ 
       

times 510-($-$$) db 0
                 db 0x55,0xaa