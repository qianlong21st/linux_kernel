         ;�����嵥6-1
         ;�ļ�����c06_mbr.asm
         ;�ļ�˵����Ӳ����������������
         ;�������ڣ�2011-4-12 22:12 
      
         jmp near start		;������ָ�������������Խ�ת��
  ;����Ҫ��ʾ�����ݣ�\�����з�
  mytext db 'L',0x07,'a',0x07,'b',0x07,'e',0x07,'l',0x07,' ',0x07,'o',0x07,\
            'f',0x07,'f',0x07,'s',0x07,'e',0x07,'t',0x07,':',0x07
  number db 0,0,0,0,0
  
  start:
         mov ax,0x7c0                  ;�������ݶλ���ַ���ó���Ҫ���ص��ڴ��еĵ�ַΪ0x07c0,�������ݶμĴ�����Ϊ��
         mov ds,ax
         
         mov ax,0xb800                 ;���ø��Ӷλ���ַ���Դ����ʼ��ַ
         mov es,ax
         
         cld							;DF=0�����д�����ʱ�����򴫵�
         mov si,mytext                 	;DS:SI---> ES:DI
         mov di,0
         mov cx,(number-mytext)/2      	;ʵ���ϵ��� 13
         rep movsw						;DS:SI---> ES:DI ����13���֣�������ʾ���ݵ��Կ����ڴ��ַ��
     
         ;�õ�����������ƫ�Ƶ�ַ
         mov ax,number
         
         ;���������λ
         mov bx,ax						;bxָ���Ŵ���ƫ�Ƶ�ַ
         mov cx,5                      	;ѭ������ 
         mov si,10                     	;���� 
  digit: 
         xor dx,dx						;dx-ax / si  = �̣�ax) ,������dx��
         div si
         mov [bx],dl                  	;������λ,���� ������dl�е�һ���ֽ����ݵ�ds:[bx]��ע��ֻ��ʹ�üĴ������ṩƫ�Ƶ�ַʱֻ��ʹ��BX��Basic Address Regiseter��,SI(Source Index Regiseter��),DI(Destionation Index Regiseter��),BP�Ĵ���
         inc bx 
         loop digit						;��CX�Ĵ�����ֵ��1�����CX��Ϊ0������ת��digit��ִ�У�ѭ��5�Σ�
         
         ;��ʾ������λ
         mov bx,number 
         mov si,4                      
   show:
         mov al,[bx+si]
         add al,0x30					;���ּ���'0'�õ���ASCILL��ֵ
         mov ah,0x04					;��ʾ���ԣ��ڵ׺��֣��޼���������˸
         mov [es:di],ax					;�������ݵ���ʾ������
         add di,2
         dec si							;����ʾ�����λ
         jns show						;���SF=0��ѭ�������SF=1���˳�ѭ����ִ����һ������
         
         mov word [es:di],0x0744		;��ʾ�������ʾһ��'D'

         jmp near $						;$�ɿ��������ڵ�ǰ���׵ı��

  times 510-($-$$) db 0					;Ϊ�˵õ�����512�ֽڵı�������$-$$����ǰ����Ĵ�С��510��ȥ��ǰ����Ĵ�С������Ҫ�����ֽ���
                   db 0x55,0xaa