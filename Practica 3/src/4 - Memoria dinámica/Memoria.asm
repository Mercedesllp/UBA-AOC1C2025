extern malloc
extern free
extern fprintf

NULL EQU 0
EQUALS EQU 0
A_BIGGER EQU -1
B_BIGGER EQU 1
INCREASE_IN_1BYTE EQU 1
INCREMENT_1 EQU 1
END_OF_STRING EQU 0

section .data
null_str: db 'NULL', 10				; 10 es el salto de linea concatenado a null

section .text

global strCmp
global strClone
global strDelete
global strPrint
global strLen

; ** String **

; int32_t strCmp(char* a, char* b)
; a[rdi], b[rsi]
strCmp:
	push rbp
	mov rbp, rsp

	; Seteo el resultado con equals
	mov rax, EQUALS
	
	; Limpio registros para iteradores visualizadores de a y b
	xor rdx, rdx
	xor rcx, rcx

loop_cmp:
	; Obtengo los chars apuntados
	mov dl, byte [rdi]
	mov cl, byte [rsi]

	cmp dl, cl
	jne end_not_equal_cmp

	cmp dl, END_OF_STRING
	je end_cmp

	; Cambio el iterador
	add rdi, INCREASE_IN_1BYTE
	add rsi, INCREASE_IN_1BYTE
	jmp loop_cmp

end_not_equal_cmp:
	; Si a < b
	cmp dl, cl
	jl end_b_is_bigger_cmp
	
	; Si a > b
	mov rax, A_BIGGER
	jmp end_cmp

end_b_is_bigger_cmp:
	mov rax, B_BIGGER

end_cmp:
	pop rbp
	ret

; char* strClone(char* a)
; a[rdi]
strClone:
	push rbp
	mov rbp, rsp
	push r15
	push r14

	; Cambio de registro al string
	mov r15, rdi

	; Obtengo el largo del string
	call strLen

	; Paso como parametro la longitud del sting al malloc(sizeof(a) * sizeof(char))
	; sizeof(char) == 1 entonces lo dejo igual
	mov	edi, eax
	; para el ultimo simbolo '\0'
	add edi, 1
	mov r14d, edi

	; Queda en rax mi puntero al clon
	call malloc
	mov rdi, rax

	; Para el char
	xor rdx, rdx
loop_clone:
	cmp r14d, 0
	je end_clone

	; Obtengo el char y lo ubico en el clon
	mov dl, byte [r15]
	mov byte [rdi], dl

	; Incremento punteros y decremento el contador de longitud
	add rdi, INCREASE_IN_1BYTE
	add r15, INCREASE_IN_1BYTE
	sub r14d, 1
	jmp loop_clone

end_clone:	
	pop r14
	pop r15
	pop rbp
	ret

; void strDelete(char* a)
strDelete:
	push rbp
	mov rbp, rsp

	call free

	pop rbp
	ret

; void strPrint(char* a, FILE* pFile)
strPrint:
	push rbp
	mov rbp, rsp
	push r15
	push r14

	; Muevo los datos a registros no volatiles
	mov r15, rdi	; str
	mov r14, rsi	; file

	; Obtengo el largo de la palabra
	call strLen

	cmp eax, NULL
	je print_NULL

continue_print:
	; Ubico al file como primer parametro
	mov rdi, r14
	; Ubico al string como el segundo
	mov rsi, r15

	call fprintf

end_print:
	pop r14
	pop r15
	pop rbp
	ret

print_NULL:
	; Cambio el string a printear por "NULL" 
	mov r15, null_str
	jmp continue_print

; uint32_t strLen(char* a)
; a[rdi]
strLen:
	push rbp
	mov rbp, rsp

	; Contador
	xor rax, rax
	; Iterador
	xor rcx, rcx

loop_len:
	mov cl, byte [rdi]

	cmp cl, END_OF_STRING
	je end_len

	add rax, INCREMENT_1
	add rdi, INCREASE_IN_1BYTE
	jmp loop_len

end_len:
	pop rbp
	ret


