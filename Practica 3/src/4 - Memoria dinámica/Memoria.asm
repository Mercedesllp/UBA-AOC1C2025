extern malloc
extern free
extern fprintf

EQUALS EQU 0
A_BIGGER EQU -1
B_BIGGER EQU 1
INCREASE_IN_1BYTE EQU 1
INCREMENT_1 EQU 1
END_OF_STRING EQU 0

section .data

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

	ret

; void strDelete(char* a)
strDelete:
	ret

; void strPrint(char* a, FILE* pFile)
strPrint:
	ret

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


