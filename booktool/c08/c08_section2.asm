

jmp code

a dw 0,0,0,0

section data1 align=16 vstart=0
	lba db 'A','B'
section data2 align=16 vstart=0
	lbb db 'C','D'
	lbc dw 0xf000
section data3 align=16
	lbd dw 0xfff0,0xfffc
	
code: 
mov bx,a
mov word [bx],lba
mov word [bx+1],lbb
mov word [bx+2],lbc
mov word [bx+3],lbd
	
	