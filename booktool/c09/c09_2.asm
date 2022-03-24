         ;�����嵥9-2
         ;�ļ�����c09_2.asm
         ;�ļ�˵����������ʾBIOS�жϵ��û����� 
         ;�������ڣ�2012-3-28 20:35
         
;===============================================================================
SECTION header vstart=0                     ;�����û�����ͷ���� 
    program_length  dd program_end          ;�����ܳ���[0x00]
    
    ;�û�������ڵ�
    code_entry      dw start                ;ƫ�Ƶ�ַ[0x04]
                    dd section.code.start   ;�ε�ַ[0x06] 
    
    realloc_tbl_len dw (header_end-realloc_begin)/4
                                            ;���ض�λ�������[0x0a]
    
    realloc_begin:
    ;���ض�λ��           
    code_segment    dd section.code.start   ;[0x0c]
    data_segment    dd section.data.start   ;[0x14]
    stack_segment   dd section.stack.start  ;[0x1c]
    
header_end:                
    
;===============================================================================
SECTION code align=16 vstart=0           ;�������Σ�16�ֽڶ��룩 
start:
      mov ax,[stack_segment]			 ;��ʼ���μĴ���SS,SP,DS
      mov ss,ax
      mov sp,ss_pointer
      mov ax,[data_segment]
      mov ds,ax
      
      mov cx,msg_end-message			 ;�������ַ����ĳ���
      mov bx,message					 ;�������ַ�������ʼ��ַ
      
 .putc:									 ;BIOS�е�0x10�жϣ�������ʾ�����ܵ��ã���int 0x10ָ��֮ǰ��Ҫʹ��AH��ʾ����
      mov ah,0x0e						 ;��AH=0xeʱ,�ڹ�괦д�ַ����ƶ������ڲ�����AL=�ַ���ASCII�룬BL=�ַ�����ɫֵ��ͼ�η�ʽ����BH=ҳ�ţ��ַ���ʽ��
      mov al,[bx]						 
      int 0x10
      inc bx							 ;��һ�ַ���ƫ�Ƶ�ַ
      loop .putc

 .reps:									 ;�Ӽ����ж�ȡ���µ��Ǹ�������������ʾ����Ļ��
      mov ah,0x00						 ;BIOS�е�0x10�жϣ����ڼ��̣�����AH=00Hʱ��ʾ��ȡ��ֵ
      int 0x16
      
      mov ah,0x0e						 ;��ʾ�����ܵ��ã���ʾ�����̵�ASCII��ֵ
      mov bl,0x07						 ;�����ַ�����ɫֵ
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