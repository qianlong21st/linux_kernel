         ;�����嵥8-2
         ;�ļ�����c08.asm
         ;�ļ�˵�����û����� 
         ;�������ڣ�2011-5-5 18:17
         
;===============================================================================
SECTION header vstart=0                     ;�����û�����ͷ���� 
    program_length  dd program_end          ;�����ܳ���[0x00],dd���������ͳ�ʼ��һ��˫�֣�32bits��
    
    ;�û�������ڵ�
    code_entry      dw start                ;ƫ�Ƶ�ַ[0x04]
                    dd section.code_1.start ;�ε�ַ[0x06] 
    
    realloc_tbl_len dw (header_end-code_1_segment)/4
                                            ;���ض�λ�������[0x0a]
    
    ;���ض�λ��32λ���ض�λǰֻ�и�20λ��Ч���ض�λ��ֻ�е�16λ��Ч����λ���ַ��           
    code_1_segment  dd section.code_1.start ;[0x0c]
    code_2_segment  dd section.code_2.start ;[0x10]
    data_1_segment  dd section.data_1.start ;[0x14]
    data_2_segment  dd section.data_2.start ;[0x18]
    stack_segment   dd section.stack.start  ;[0x1c]
    
    header_end:                
    
;===============================================================================
SECTION code_1 align=16 vstart=0         ;��������1��16�ֽڶ��룩 
put_string:                              ;��ʾ��(0��β)��
                                         ;���룺DS:BX=����ַ
         mov cl,[bx]
         or cl,cl                        ;cl=0 ?����0��β��cl=cl | cl ������䱾������ִ�н����Ӱ��ZF��־λ
         jz .exit                        ;�ǵģ����������� 
         call put_char
         inc bx                          ;��һ���ַ� 
         jmp put_string

   .exit:
         ret

;-------------------------------------------------------------------------------
put_char:                                ;��ʾһ���ַ�
                                         ;���룺cl=�ַ�ascii
         push ax
         push bx
         push cx
         push dx
         push ds
         push es

         ;����ȡ��ǰ���λ�ã���0x3d4�˿�д��0x0e,Ȼ���ȡ�ö˿ڵõ���8λ�Ĺ��
         mov dx,0x3d4
         mov al,0x0e
         out dx,al
         mov dx,0x3d5
         in al,dx                        ;��8λ 
         mov ah,al

         mov dx,0x3d4		;��0x3d4�˿�д��0x0f,Ȼ���ȡ�ö˿ڵõ���8λ�Ĺ��
         mov al,0x0f
         out dx,al
         mov dx,0x3d5
         in al,dx                        ;��8λ 
         mov bx,ax                       ;BX=������λ�õ�16λ��

         cmp cl,0x0d                     ;�س�����
         jnz .put_0a                     ;���ǡ������ǲ��ǻ��е��ַ� 
         mov ax,bx                       ;ax/80 * 80 �õ���ǰ�е����ף�����֮���浽BX�Ĵ�����ȥ 
         mov bl,80                       
         div bl
         mul bl
         mov bx,ax
         jmp .set_cursor

 .put_0a:
         cmp cl,0x0a                     ;���з���
         jnz .put_other                  ;���ǣ��Ǿ�������ʾ�ַ� 
         add bx,80						 ;�ǻ��з�������λ������ƶ�80��һ��80���ַ���
         jmp .roll_screen

 .put_other:                             ;������ʾ�ַ�
         mov ax,0xb800					 ;�Դ��Ӧ�Ķε�ַ
         mov es,ax
         shl bx,1						 ;����λ��*2�õ��ַ���ƫ�ƣ���Ϊ�ַ���Ӧ�����ֽڣ�����ƫ�ƺ��ַ���ƫ���и�2����ϵ
         mov [es:bx],cl

         ;���½����λ���ƽ�һ���ַ�
         shr bx,1						 ;�ָ�ԭ������λ�ã�����2�����������ƶ�һ��λ��
         add bx,1

 .roll_screen:							 ;һ����Ļ��������ʾ2000���ַ�
         cmp bx,2000                     ;��곬����Ļ������
         jl .set_cursor

         mov ax,0xb800					 ;���й�������������Ļ2-25���������ƣ����һ�����ڵװ��ֵĿհ��ַ�
         mov ds,ax						 ;�����Դ�Ķλ�ַ
         mov es,ax
         cld							 ;����λ����0�������ƶ�
         mov si,0xa0					 ;�ڶ��е�һ��(160,��Ϊÿ���ַ�ռ�������ֽ�) Դ��ַΪ DS:SI
         mov di,0x00					 ;��һ�е�һ�� Ŀ�ĵ�ַΪ ES:DI
         mov cx,1920					 ;�ظ�ִ��1920��
         rep movsw
         mov bx,3840                     ;�����Ļ���һ�У�3840Ϊ���һ�е���ʼƫ��
         mov cx,80						 ;�ظ�����Ϊ80
 .cls:
         mov word[es:bx],0x0720			 ;�ڵװ��֣��հ��ַ�
         add bx,2
         loop .cls

         mov bx,1920					 ;�ָ����λ��
 ;����λ�ñ�����BX��
 .set_cursor:
         mov dx,0x3d4		;��0x3d4�˿�д��0x0e,Ȼ����0x3d5�˿�д���8λ�Ĺ��λ��ֵ
         mov al,0x0e
         out dx,al
         mov dx,0x3d5
         mov al,bh
         out dx,al
         mov dx,0x3d4		;��0x3d4�˿�д��0x0f,Ȼ����0x3d5�˿�д���8λ�Ĺ��λ��ֵ
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
         ;��ʼִ��ʱ��DS��ESָ���û�����ͷ����
         mov ax,[stack_segment]           ;���õ��û������Լ��Ķ�ջ 
         mov ss,ax
         mov sp,stack_end				  ;�൱�ڣ�mov sp,256,��ջ�Ĵ�СΪ256���ֽ�
         
         mov ax,[data_1_segment]          ;���õ��û������Լ������ݶ�
         mov ds,ax

         mov bx,msg0
         call put_string                  ;��ʾ��һ����Ϣ 

         push word [es:code_2_segment]	  ;��ѹ������2�Ķε�ַ����ѹ������2��ƫ�Ƶ�ַ
         mov ax,begin
         push ax                          ;����ֱ��push begin,80386+
         
         retf                             ;ת�Ƶ������2ִ�У��Ѹղ���ջ�Ĵ����2��ƫ�Ƶ�ַ�Ͷε�ַ��������eip,cs�����Ǵ�������ת�������2����ʼִ��
         
  continue:
         mov ax,[es:data_2_segment]       ;�μĴ���DS�л������ݶ�2 
         mov ds,ax
         
         mov bx,msg1
         call put_string                  ;��ʾ�ڶ�����Ϣ 

         jmp $ 

;===============================================================================
SECTION code_2 align=16 vstart=0          ;��������2��16�ֽڶ��룩

  begin:
         push word [es:code_1_segment]
         mov ax,continue
         push ax                          ;����ֱ��push continue,80386+
         
         retf                             ;ת�Ƶ������1����ִ�� 
         
;===============================================================================
SECTION data_1 align=16 vstart=0
	;msg0�ı��Ϊ0
    msg0 db '  This is NASM - the famous Netwide Assembler. '
         db 'Back at SourceForge and in intensive development! '
         db 'Get the current versions from http://www.nasm.us/.'
         db 0x0d,0x0a,0x0d,0x0a				;�س�(0X0D)�ͻ��з���(0X0A)
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
           
         resb 256				;��������256�ֽڵ����ݣ�resb��������δ��ʼ��������

stack_end:  					;����vstart=0�����Ըñ���൱�ڵ���256

;===============================================================================
SECTION trail align=16
program_end:			;program_end����ı���Ǵ���������ͷ��ʼ����ģ����ڱ�ʾ��������Ĵ�С