         ;�����嵥7-1
         ;�ļ�����c07_mbr.asm
         ;�ļ�˵����Ӳ����������������
         ;�������ڣ�2011-4-13 18:02
         
         jmp near start			;����û��ָ���������
	
 message db '1+2+3+...+100='
        
 start:
         mov ax,0x7c0           ;�������ݶεĶλ���ַ 
         mov ds,ax

         mov ax,0xb800          ;���ø��Ӷλ�ַ����ʾ���������Կ��Ļ���ַ
         mov es,ax

         ;������ʾ�ַ��� 
         mov si,message          
         mov di,0
         mov cx,start-message	;'1+2+3+...+100='���ֽ���
     @g:
         mov al,[si]			;ȡ��ds:[si]�е�����
         mov [es:di],al			;�����ݸ��Ƶ�es:[di]��ȥ
         inc di
         mov byte [es:di],0x07
         inc di
         inc si
         loop @g				;cx������0ʱ����ѭ��

         ;���¼���1��100�ĺ� 
         xor ax,ax				;ax����
         mov cx,1
     @f:
         add ax,cx
         inc cx
         cmp cx,100
         jle @f					;cx<=100ʱ����ѭ��

         ;���¼����ۼӺ͵�ÿ����λ 
         xor cx,cx              ;���ö�ջ�εĶλ���ַ
         mov ss,cx				;CS��SS����ͬһ�����жλ���ַΪ0
         mov sp,cx				;��ջָ��SP=0,����ջ�����������ģ��ʵ�һ����ջʱ��λ��Ϊ0X00000-2=0XFFFFE,�Ҳ���ʹ���β�����ͻ

         mov bx,10				;BX=10,����
         xor cx,cx				;CX=0��CX���ڱ�ǹ��м�λ����
     @d:
         inc cx
         xor dx,dx
         div bx					;DX:AX / BX  = ��(AX) ����(DX)
         or dl,0x30				;ת���ɸ����ֶ�Ӧ��ASCII��
         push dx				;����ջ���λ�����֣������ջ�������λ����
         cmp ax,0
         jne @d					;AX!=0ʱ����ѭ����Ҳ�����̲�Ϊ0ʱ�Ž��зֽ�

         ;������ʾ������λ 
     @a:
         pop dx					;�ȳ�ջ�������λ������
         mov [es:di],dl
         inc di
         mov byte [es:di],0x07
         inc di
         loop @a				;CX!=0����ѭ��
       
         jmp near $ 
       

times 510-($-$$) db 0
                 db 0x55,0xaa