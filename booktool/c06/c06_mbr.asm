         ;代码清单6-1
         ;文件名：c06_mbr.asm
         ;文件说明：硬盘主引导扇区代码
         ;创建日期：2011-4-12 22:12 
      
         jmp near start		;跳过非指令的数据区，相对近转移
  ;声明要显示的内容，\是续行符
  mytext db 'L',0x07,'a',0x07,'b',0x07,'e',0x07,'l',0x07,' ',0x07,'o',0x07,\
            'f',0x07,'f',0x07,'s',0x07,'e',0x07,'t',0x07,':',0x07
  number db 0,0,0,0,0
  
  start:
         mov ax,0x7c0                  ;设置数据段基地址，该程序要加载到内存中的地址为0x07c0,设置数据段寄存器，为此
         mov ds,ax
         
         mov ax,0xb800                 ;设置附加段基地址，显存的起始地址
         mov es,ax
         
         cld							;DF=0，进行串传递时是正向传递
         mov si,mytext                 	;DS:SI---> ES:DI
         mov di,0
         mov cx,(number-mytext)/2      	;实际上等于 13
         rep movsw						;DS:SI---> ES:DI 传递13个字，传递显示数据到显卡的内存地址中
     
         ;得到标号所代表的偏移地址
         mov ax,number
         
         ;计算各个数位
         mov bx,ax						;bx指向标号处的偏移地址
         mov cx,5                      	;循环次数 
         mov si,10                     	;除数 
  digit: 
         xor dx,dx						;dx-ax / si  = 商（ax) ,余数（dx）
         div si
         mov [bx],dl                  	;保存数位,余数 ，保存dl中的一个字节数据到ds:[bx]，注意只能使用寄存器来提供偏移地址时只能使用BX（Basic Address Regiseter）,SI(Source Index Regiseter）),DI(Destionation Index Regiseter）),BP寄存器
         inc bx 
         loop digit						;将CX寄存器的值减1，如果CX不为0，则跳转到digit处执行（循环5次）
         
         ;显示各个数位
         mov bx,number 
         mov si,4                      
   show:
         mov al,[bx+si]
         add al,0x30					;数字加上'0'得到其ASCILL码值
         mov ah,0x04					;显示属性，黑底红字，无加亮，无闪烁
         mov [es:di],ax					;复制数据到显示缓冲区
         add di,2
         dec si							;先显示的最高位
         jns show						;如果SF=0则循环，如果SF=1则退出循环，执行下一条命令
         
         mov word [es:di],0x0744		;显示区最后显示一个'D'

         jmp near $						;$可看成隐藏在当前行首的标号

  times 510-($-$$) db 0					;为了得到正好512字节的编译结果，$-$$代表当前程序的大小，510减去当前程序的大小，代表要填充的字节数
                   db 0x55,0xaa